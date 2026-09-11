package com.lms.dao;

import com.lms.model.Review;
import com.lms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO {

    /**
     * Thêm mới hoặc Cập nhật đánh giá của học viên (PostgreSQL UPSERT).
     */
    public boolean saveOrUpdate(Review review) {
        String sql = "INSERT INTO reviews (student_id, course_id, rating, comment, created_at) " +
                     "VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP) " +
                     "ON CONFLICT (student_id, course_id) " +
                     "DO UPDATE SET rating = EXCLUDED.rating, comment = EXCLUDED.comment, created_at = CURRENT_TIMESTAMP";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, review.getStudentId());
            stmt.setInt(2, review.getCourseId());
            stmt.setInt(3, review.getRating());
            stmt.setString(4, review.getComment());

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Xóa đánh giá của học viên cho một khóa học cụ thể.
     */
    public boolean delete(int studentId, int courseId) {
        String sql = "DELETE FROM reviews WHERE student_id = ? AND course_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, studentId);
            stmt.setInt(2, courseId);

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách đánh giá của khóa học (kèm thông tin học viên), sắp xếp mới nhất lên đầu.
     */
    public List<Review> findByCourseId(int courseId) {
        List<Review> reviews = new ArrayList<>();
        String sql = "SELECT r.id, r.student_id, r.course_id, r.rating, r.comment, r.created_at, " +
                     "       u.full_name AS student_name, u.avatar_url AS student_avatar " +
                     "FROM reviews r " +
                     "JOIN users u ON r.student_id = u.id " +
                     "WHERE r.course_id = ? " +
                     "ORDER BY r.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, courseId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    reviews.add(mapResultSetToReview(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reviews;
    }

    /**
     * Lấy đánh giá của một học viên cụ thể cho khóa học.
     */
    public Review findByStudentAndCourse(int studentId, int courseId) {
        String sql = "SELECT r.id, r.student_id, r.course_id, r.rating, r.comment, r.created_at, " +
                     "       u.full_name AS student_name, u.avatar_url AS student_avatar " +
                     "FROM reviews r " +
                     "JOIN users u ON r.student_id = u.id " +
                     "WHERE r.student_id = ? AND r.course_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, studentId);
            stmt.setInt(2, courseId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToReview(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Tính toán lại và cập nhật avg_rating của khóa học vào bảng courses.
     */
    public boolean updateCourseAvgRating(int courseId) {
        String sql = "UPDATE courses " +
                     "SET avg_rating = COALESCE((SELECT ROUND(AVG(rating), 2) FROM reviews WHERE course_id = ?), 0.00) " +
                     "WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, courseId);
            stmt.setInt(2, courseId);

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Review mapResultSetToReview(ResultSet rs) throws SQLException {
        Review review = new Review();
        review.setId(rs.getInt("id"));
        review.setStudentId(rs.getInt("student_id"));
        review.setCourseId(rs.getInt("course_id"));
        review.setRating(rs.getInt("rating"));
        review.setComment(rs.getString("comment"));

        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) {
            review.setCreatedAt(ts.toLocalDateTime());
        }

        review.setStudentName(rs.getString("student_name"));
        review.setStudentAvatar(rs.getString("student_avatar"));
        return review;
    }
}
