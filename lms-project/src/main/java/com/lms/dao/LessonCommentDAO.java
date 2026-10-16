package com.lms.dao;

import com.lms.model.LessonComment;
import com.lms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class LessonCommentDAO {

    public List<LessonComment> findCommentsByLesson(int lessonId) {
        List<LessonComment> rootComments = new ArrayList<>();
        Map<Integer, LessonComment> commentMap = new HashMap<>();

        String sql = "SELECT c.id, c.lesson_id, c.user_id, c.parent_id, c.content, c.created_at, " +
                     "       u.full_name, u.avatar_url, u.role " +
                     "FROM lesson_comments c " +
                     "INNER JOIN users u ON c.user_id = u.id " +
                     "WHERE c.lesson_id = ? " +
                     "ORDER BY c.created_at ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, lessonId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    LessonComment comment = new LessonComment();
                    comment.setId(rs.getInt("id"));
                    comment.setLessonId(rs.getInt("lesson_id"));
                    comment.setUserId(rs.getInt("user_id"));

                    int parentId = rs.getInt("parent_id");
                    if (!rs.wasNull()) {
                        comment.setParentId(parentId);
                    }

                    comment.setContent(rs.getString("content"));
                    Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) {
                        comment.setCreatedAt(ts.toLocalDateTime());
                    }

                    comment.setUserName(rs.getString("full_name"));
                    comment.setUserAvatar(rs.getString("avatar_url"));
                    comment.setUserRole(rs.getString("role"));

                    commentMap.put(comment.getId(), comment);

                    if (comment.getParentId() == null) {
                        rootComments.add(comment);
                    } else {
                        LessonComment parent = commentMap.get(comment.getParentId());
                        if (parent != null) {
                            parent.getReplies().add(comment);
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return rootComments;
    }

    public boolean save(LessonComment comment) {
        String sql = "INSERT INTO lesson_comments (lesson_id, user_id, parent_id, content) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, comment.getLessonId());
            stmt.setInt(2, comment.getUserId());
            if (comment.getParentId() != null && comment.getParentId() > 0) {
                stmt.setInt(3, comment.getParentId());
            } else {
                stmt.setNull(3, Types.INTEGER);
            }
            stmt.setString(4, comment.getContent());

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        comment.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean delete(int commentId, int userId, boolean isAdminOrInstructor) {
        String sql;
        if (isAdminOrInstructor) {
            sql = "DELETE FROM lesson_comments WHERE id = ?";
        } else {
            sql = "DELETE FROM lesson_comments WHERE id = ? AND user_id = ?";
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, commentId);
            if (!isAdminOrInstructor) {
                stmt.setInt(2, userId);
            }
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
