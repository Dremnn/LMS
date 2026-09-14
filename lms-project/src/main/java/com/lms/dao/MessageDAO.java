package com.lms.dao;

import com.lms.model.Message;
import com.lms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MessageDAO {

    public void insertMessage(Message message) throws SQLException {
        String sql = "INSERT INTO messages (sender_id, receiver_id, content, sent_at, is_read) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, message.getSenderId());
            ps.setInt(2, message.getReceiverId());
            ps.setString(3, message.getContent());
            ps.setTimestamp(4, Timestamp.valueOf(message.getSentAt()));
            ps.setBoolean(5, message.isRead());
            ps.executeUpdate();
            
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    message.setId(rs.getInt(1));
                }
            }
        }
    }

    public List<Message> getConversation(int user1, int user2, int limit, int offset) throws SQLException {
        String sql = "SELECT * FROM messages WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?) " +
                     "ORDER BY sent_at DESC LIMIT ? OFFSET ?";
        List<Message> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, user1);
            ps.setInt(2, user2);
            ps.setInt(3, user2);
            ps.setInt(4, user1);
            ps.setInt(5, limit);
            ps.setInt(6, offset);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Message m = new Message();
                    m.setId(rs.getInt("id"));
                    m.setSenderId(rs.getInt("sender_id"));
                    m.setReceiverId(rs.getInt("receiver_id"));
                    m.setContent(rs.getString("content"));
                    m.setSentAt(rs.getTimestamp("sent_at").toLocalDateTime());
                    m.setRead(rs.getBoolean("is_read"));
                    list.add(0, m); // add to front so it's chronologically ordered
                }
            }
        }
        return list;
    }

    public void markAsRead(int senderId, int receiverId) throws SQLException {
        String sql = "UPDATE messages SET is_read = true WHERE sender_id = ? AND receiver_id = ? AND is_read = false";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, senderId);
            ps.setInt(2, receiverId);
            ps.executeUpdate();
        }
    }
    
    public int getUnreadCount(int receiverId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM messages WHERE receiver_id = ? AND is_read = false";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, receiverId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public void deleteMessage(int messageId, int userId) throws SQLException {
        // Only allow sender or receiver to delete it. To be safe, maybe just allow if it involves them.
        String sql = "DELETE FROM messages WHERE id = ? AND (sender_id = ? OR receiver_id = ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, messageId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);
            ps.executeUpdate();
        }
    }

    public void deleteConversation(int user1, int user2) throws SQLException {
        String sql = "DELETE FROM messages WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, user1);
            ps.setInt(2, user2);
            ps.setInt(3, user2);
            ps.setInt(4, user1);
            ps.executeUpdate();
        }
    }
}
