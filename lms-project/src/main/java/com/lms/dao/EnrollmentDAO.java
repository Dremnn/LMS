package com.lms.dao;

import com.lms.model.Enrollment;
import com.lms.model.Quiz;
import com.lms.util.DBConnection;
import com.lms.model.Section;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class EnrollmentDAO {

    // 1. Kiểm tra Student đã ghi danh khóa học này chưa (tránh đăng ký trùng)
    public boolean isEnrolled(int studentId, int courseId) {
        String sql = "SELECT 1 FROM enrollments WHERE student_id = ? AND course_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, studentId);
            stmt.setInt(2, courseId);

            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 2. Tạo bản ghi ghi danh mới
    public boolean save(Enrollment enrollment) {
        String sql = "INSERT INTO enrollments (student_id, course_id, progress_percent, status, enrolled_at) " +
                     "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, enrollment.getStudentId());
            stmt.setInt(2, enrollment.getCourseId());
            stmt.setBigDecimal(3, BigDecimal.ZERO);
            stmt.setString(4, "in_progress");

            LocalDateTime now = LocalDateTime.now();
            stmt.setTimestamp(5, Timestamp.valueOf(now));

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        enrollment.setId(generatedKeys.getInt(1));
                        enrollment.setEnrolledAt(now);
                        enrollment.setProgressPercent(BigDecimal.ZERO);
                        enrollment.setStatus("in_progress");
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Integer> findStudentIdsByCourseOrSection(int courseId){

        List<Integer> StudentIds = new ArrayList<>();
        String sql = "Select student_id from enrollments where course_id = ?";

        try (Connection conn = DBConnection.getConnection();
            PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, courseId);
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        StudentIds.add(rs.getInt("student_id"));
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            return StudentIds;
    }

    // 3. Lấy 1 enrollment cụ thể theo student + course
    // Dùng để: kiểm tra quyền xem bài học, lấy enrollmentId khi đánh dấu hoàn thành
    public Enrollment findByStudentAndCourse(int studentId, int courseId) {
        String sql = "SELECT id, student_id, course_id, progress_percent, status, enrolled_at, completed_at, " +
                     "warning_message, warning_at, appeal_message, warning_status " +
                     "FROM enrollments WHERE student_id = ? AND course_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, studentId);
            stmt.setInt(2, courseId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToEnrollment(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 4. Lấy toàn bộ khóa học 1 Student đã ghi danh (kèm thông tin khóa học qua JOIN)
    // Dùng cho trang "Khóa học của tôi" / lịch sử tham gia
    public List<Enrollment> findByStudent(int studentId) {
        List<Enrollment> list = new ArrayList<>();
        String sql = "SELECT e.id, e.student_id, e.course_id, e.progress_percent, e.status, " +
                     "e.enrolled_at, e.completed_at, e.warning_message, e.warning_at, e.appeal_message, e.warning_status, " +
                     "c.title AS course_title, c.thumbnail_url AS course_thumbnail_url, c.total_lessons " +
                     "FROM enrollments e " +
                     "INNER JOIN courses c ON e.course_id = c.id " +
                     "WHERE e.student_id = ? " +
                     "ORDER BY e.enrolled_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, studentId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Enrollment e = mapResultSetToEnrollment(rs);
                    e.setCourseTitle(rs.getString("course_title"));
                    e.setCourseThumbnailUrl(rs.getString("course_thumbnail_url"));
                    e.setTotalLessons(rs.getInt("total_lessons"));
                    list.add(e);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 5. Đọc lại 1 enrollment theo ID (dùng sau khi Trigger DB đã cập nhật progress,
    // để lấy giá trị progress_percent MỚI NHẤT từ DB - không dùng object cũ trong bộ nhớ)
    public Enrollment findById(int id) {
        String sql = "SELECT id, student_id, course_id, progress_percent, status, enrolled_at, completed_at, " +
                     "warning_message, warning_at, appeal_message, warning_status " +
                     "FROM enrollments WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToEnrollment(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 5b. Lấy danh sách học viên trong 1 khóa học (kèm thông tin user, nhóm, tiến độ & cảnh cáo)
    // Dành riêng cho Giảng viên theo dõi học sinh và cảnh cáo
    public List<Enrollment> findEnrollmentsByCourse(int courseId) {
        List<Enrollment> list = new ArrayList<>();
        java.util.Set<Integer> seenStudentIds = new java.util.HashSet<>();
        String sql = "SELECT e.id, e.student_id, e.course_id, e.progress_percent, e.status, " +
                     "e.enrolled_at, e.completed_at, e.warning_message, e.warning_at, e.appeal_message, e.warning_status, " +
                     "u.full_name AS student_name, u.email AS student_email, u.avatar_url AS student_avatar, " +
                     "grp.group_name " +
                     "FROM enrollments e " +
                     "INNER JOIN users u ON e.student_id = u.id " +
                     "LEFT JOIN (" +
                     "    SELECT gm.student_id, sg.course_id, MAX(sg.name) AS group_name " +
                     "    FROM group_members gm " +
                     "    JOIN study_groups sg ON gm.group_id = sg.id " +
                     "    GROUP BY gm.student_id, sg.course_id" +
                     ") grp ON grp.student_id = e.student_id AND grp.course_id = e.course_id " +
                     "WHERE e.course_id = ? " +
                     "ORDER BY e.enrolled_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, courseId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    int studentId = rs.getInt("student_id");
                    if (seenStudentIds.contains(studentId)) {
                        continue;
                    }
                    seenStudentIds.add(studentId);

                    Enrollment e = mapResultSetToEnrollment(rs);
                    e.setStudentFullName(rs.getString("student_name"));
                    e.setStudentEmail(rs.getString("student_email"));
                    e.setStudentAvatarUrl(rs.getString("student_avatar"));
                    e.setGroupName(rs.getString("group_name"));
                    list.add(e);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 5c. Cảnh cáo học viên
    public boolean warnStudent(int enrollmentId, String warningMessage) {
        String sql = "UPDATE enrollments SET warning_message = ?, warning_at = CURRENT_TIMESTAMP, " +
                     "warning_status = 'warning', appeal_message = NULL WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, warningMessage);
            stmt.setInt(2, enrollmentId);

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 5d. Học viên gửi kháng cáo / phản hồi cảnh cáo
    public boolean appealWarning(int enrollmentId, String appealMessage) {
        String sql = "UPDATE enrollments SET appeal_message = ?, warning_status = 'appealed' WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, appealMessage);
            stmt.setInt(2, enrollmentId);

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 5e. Giảng viên gỡ cảnh cáo / chấp thuận kháng cáo
    public boolean removeWarning(int enrollmentId) {
        String sql = "UPDATE enrollments SET warning_message = NULL, warning_at = NULL, " +
                     "appeal_message = NULL, warning_status = 'none' WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, enrollmentId);

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Enrollment mapResultSetToEnrollment(ResultSet rs) throws SQLException {
        Enrollment e = new Enrollment();
        e.setId(rs.getInt("id"));
        e.setStudentId(rs.getInt("student_id"));
        e.setCourseId(rs.getInt("course_id"));
        e.setProgressPercent(rs.getBigDecimal("progress_percent"));
        e.setStatus(rs.getString("status"));

        Timestamp enrolledAt = rs.getTimestamp("enrolled_at");
        e.setEnrolledAt(enrolledAt != null ? enrolledAt.toLocalDateTime() : null);

        Timestamp completedAt = rs.getTimestamp("completed_at");
        e.setCompletedAt(completedAt != null ? completedAt.toLocalDateTime() : null);

        try {
            e.setWarningMessage(rs.getString("warning_message"));
            Timestamp warningAt = rs.getTimestamp("warning_at");
            e.setWarningAt(warningAt != null ? warningAt.toLocalDateTime() : null);
            e.setAppealMessage(rs.getString("appeal_message"));
            e.setWarningStatus(rs.getString("warning_status"));
        } catch (SQLException ignored) {}

        return e;
    }

    // =========================================================================
    // 6. Hủy đăng ký khóa học (Unenroll)
    // =========================================================================
    public boolean delete(int studentId, int courseId) {
        String sql = "DELETE FROM enrollments WHERE student_id = ? AND course_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, studentId);
            stmt.setInt(2, courseId);

            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    public List<Integer> findStudentIdsByInstructor(int instructorId) {
        List<Integer> studentIds = new ArrayList<>();
        String sql = "SELECT DISTINCT e.student_id FROM enrollments e " +
                     "INNER JOIN courses c ON e.course_id = c.id " +
                     "WHERE c.instructor_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, instructorId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    studentIds.add(rs.getInt("student_id"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return studentIds;
    }
}
