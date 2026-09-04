package com.lms.dao;

import com.lms.model.Course;
import com.lms.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class CourseDAO {

    // =========================================================================
    // 1. TÌM KIẾM + FILTER + SORT (dùng cho trang Student browse khóa học)
    // =========================================================================
    // keyword: tìm theo tên khóa học (có thể null/rỗng = không lọc theo tên)
    // categoryId: lọc theo danh mục (null = tất cả danh mục)
    // sortBy: "newest" | "popular" | "rating" (mặc định "newest")
    // Chỉ lấy các khóa học có status = 'published', 'warning', 'appealed'
    // (Student vẫn thấy khóa học bị cảnh cáo nhưng sẽ thấy banner thông báo)
    public List<Course> search(String keyword, Integer categoryId, String sortBy) {
        List<Course> list = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
            "SELECT c.id, c.instructor_id, c.category_id, c.title, c.description, " +
            "c.thumbnail_url, c.price, c.pass_score, c.status, c.avg_rating, " +
            "c.total_students, c.total_lessons, c.created_at, " +
            "u.full_name AS instructor_name, cat.name AS category_name " +
            "FROM courses c " +
            "INNER JOIN users u ON c.instructor_id = u.id " +
            "LEFT JOIN categories cat ON c.category_id = cat.id " +
            "WHERE c.status IN ('published', 'warning', 'appealed') "
        );

        List<Object> params = new ArrayList<>();

        // Thêm điều kiện tìm theo tên (nếu có nhập từ khóa)
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND c.title LIKE ? ");
            params.add("%" + keyword.trim() + "%");
        }

        // Thêm điều kiện lọc theo danh mục (nếu có chọn)
        if (categoryId != null) {
            sql.append("AND c.category_id = ? ");
            params.add(categoryId);
        }

        // Sắp xếp theo tiêu chí được chọn
        if ("popular".equals(sortBy)) {
            sql.append("ORDER BY c.total_students DESC");
        } else if ("rating".equals(sortBy)) {
            sql.append("ORDER BY c.avg_rating DESC");
        } else {
            // Mặc định: mới nhất trước
            sql.append("ORDER BY c.created_at DESC");
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            // Gán tham số động theo đúng thứ tự đã thêm ở trên
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToCourse(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // =========================================================================
    // 2. LẤY DANH SÁCH KHÓA HỌC CỦA 1 INSTRUCTOR (bao gồm mọi status: draft/pending/published/rejected)
    // =========================================================================
    public List<Course> findByInstructor(int instructorId) {
        List<Course> list = new ArrayList<>();
        String sql = "SELECT c.id, c.instructor_id, c.category_id, c.title, c.description, " +
                     "c.thumbnail_url, c.price, c.pass_score, c.status, c.reject_reason, " +
                     "c.avg_rating, c.total_students, c.total_lessons, c.created_at, " +
                     "cat.name AS category_name " +
                     "FROM courses c " +
                     "LEFT JOIN categories cat ON c.category_id = cat.id " +
                     "WHERE c.instructor_id = ? " +
                     "ORDER BY c.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, instructorId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToCourse(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // =========================================================================
    // 3. LẤY TOÀN BỘ DANH SÁCH KHÓA HỌC (dùng cho trang Admin quản lý/xóa)
    // =========================================================================
    public List<Course> findAllCourses() {
        List<Course> list = new ArrayList<>();
        String sql = "SELECT c.id, c.instructor_id, c.category_id, c.title, c.description, " +
                     "c.thumbnail_url, c.price, c.pass_score, c.status, c.avg_rating, " +
                     "c.total_students, c.total_lessons, c.created_at, " +
                     "u.full_name AS instructor_name, cat.name AS category_name " +
                     "FROM courses c " +
                     "INNER JOIN users u ON c.instructor_id = u.id " +
                     "LEFT JOIN categories cat ON c.category_id = cat.id " +
                     "ORDER BY c.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                list.add(mapResultSetToCourse(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // =========================================================================
    // 4. TÌM 1 KHÓA HỌC THEO ID (kèm thông tin instructor + category)
    // =========================================================================
    public Course findById(int id) {
        String sql = "SELECT c.id, c.instructor_id, c.category_id, c.title, c.description, " +
                     "c.thumbnail_url, c.price, c.pass_score, c.status, c.reject_reason, " +
                     "c.avg_rating, c.total_students, c.total_lessons, c.created_at, " +
                     "u.full_name AS instructor_name, cat.name AS category_name " +
                     "FROM courses c " +
                     "INNER JOIN users u ON c.instructor_id = u.id " +
                     "LEFT JOIN categories cat ON c.category_id = cat.id " +
                     "WHERE c.id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToCourse(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // =========================================================================
    // 5. TẠO KHÓA HỌC MỚI (status mặc định = 'draft')
    // =========================================================================
    public boolean save(Course course) {
        String sql = "INSERT INTO courses (instructor_id, category_id, title, description, " +
                     "price, status, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, course.getInstructorId());

            if (course.getCategoryId() != null) {
                stmt.setInt(2, course.getCategoryId());
            } else {
                stmt.setNull(2, Types.INTEGER);
            }

            stmt.setString(3, course.getTitle());
            stmt.setString(4, course.getDescription());
            stmt.setBigDecimal(5, course.getPrice() != null ? course.getPrice() : BigDecimal.ZERO);
            stmt.setString(6, "draft");

            LocalDateTime now = LocalDateTime.now();
            stmt.setTimestamp(7, Timestamp.valueOf(now));

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        course.setId(generatedKeys.getInt(1));
                        course.setCreatedAt(now);
                        course.setStatus("draft");
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // =========================================================================
    // 6. CẬP NHẬT THÔNG TIN KHÓA HỌC (Instructor sửa title/description/price/category)
    // =========================================================================
    public boolean update(Course course) {
        String sql = "UPDATE courses SET category_id = ?, title = ?, description = ?, price = ? " +
                     "WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            if (course.getCategoryId() != null) {
                stmt.setInt(1, course.getCategoryId());
            } else {
                stmt.setNull(1, Types.INTEGER);
            }

            stmt.setString(2, course.getTitle());
            stmt.setString(3, course.getDescription());
            stmt.setBigDecimal(4, course.getPrice());
            stmt.setInt(5, course.getId());

            return stmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // =========================================================================
    // 7. CẬP NHẬT STATUS (dùng khi: Instructor gửi duyệt, hoặc Admin duyệt/từ chối)
    // =========================================================================
    public boolean updateStatus(int courseId, String status, String rejectReason) {
        String sql = "UPDATE courses SET status = ?, reject_reason = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setString(2, rejectReason);
            stmt.setInt(3, courseId);

            return stmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // =========================================================================
    // 8. XÓA KHÓA HỌC (chỉ nên cho phép xóa khi status = 'draft', kiểm tra ở Service)
    // =========================================================================
    public boolean delete(int courseId) {
        String sql = "DELETE FROM courses WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, courseId);
            return stmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // =========================================================================
    // Hàm phụ trợ: Map 1 dòng ResultSet -> đối tượng Course
    // =========================================================================
    private Course mapResultSetToCourse(ResultSet rs) throws SQLException {
        Course course = new Course();
        course.setId(rs.getInt("id"));
        course.setInstructorId(rs.getInt("instructor_id"));

        int categoryId = rs.getInt("category_id");
        course.setCategoryId(rs.wasNull() ? null : categoryId);

        course.setTitle(rs.getString("title"));
        course.setDescription(rs.getString("description"));
        course.setThumbnailUrl(rs.getString("thumbnail_url"));
        course.setPrice(rs.getBigDecimal("price"));
        course.setPassScore(rs.getBigDecimal("pass_score"));
        course.setStatus(rs.getString("status"));

        // reject_reason không phải lúc nào cũng có trong SELECT (tùy hàm gọi) -> kiểm tra tồn tại cột
        try {
            course.setRejectReason(rs.getString("reject_reason"));
        } catch (SQLException ignored) {}

        // appeal_message
        try {
            course.setAppealMessage(rs.getString("appeal_message"));
        } catch (SQLException ignored) {}

        course.setAvgRating(rs.getBigDecimal("avg_rating"));
        course.setTotalStudents(rs.getInt("total_students"));
        course.setTotalLessons(rs.getInt("total_lessons"));

        Timestamp timestamp = rs.getTimestamp("created_at");
        course.setCreatedAt(timestamp != null ? timestamp.toLocalDateTime() : null);

        try {
            course.setInstructorName(rs.getString("instructor_name"));
        } catch (SQLException ignored) {}

        try {
            course.setCategoryName(rs.getString("category_name"));
        } catch (SQLException ignored) {}

        return course;
    }

    // =========================================================================
    // 9. CẬP NHẬT NỘI DUNG KHÁNG CÁO (Instructor gửi appeal)
    // =========================================================================
    public boolean updateAppeal(int courseId, String appealMessage, String newStatus) {
        String sql = "UPDATE courses SET appeal_message = ?, status = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, appealMessage);
            stmt.setString(2, newStatus);
            stmt.setInt(3, courseId);

            return stmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}