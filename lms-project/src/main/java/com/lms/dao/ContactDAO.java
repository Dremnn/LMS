package com.lms.dao;

import com.lms.model.Contact;
import com.lms.model.User;
import com.lms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ContactDAO {

    public void addContactRequest(int senderId, int receiverId) throws SQLException {
        String sql = "INSERT INTO contacts (user_id, contact_id, status, created_at) VALUES (?, ?, 'pending', CURRENT_TIMESTAMP) ON CONFLICT (user_id, contact_id) DO NOTHING";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, senderId);
            ps.setInt(2, receiverId);
            ps.executeUpdate();
        }
    }

    public void updateContactStatus(int userId, int contactId, String status) throws SQLException {
        String sql = "UPDATE contacts SET status = ? WHERE (user_id = ? AND contact_id = ?) OR (user_id = ? AND contact_id = ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, userId);
            ps.setInt(3, contactId);
            ps.setInt(4, contactId);
            ps.setInt(5, userId);
            ps.executeUpdate();
        }
    }

    public void removeContact(int userId, int contactId) throws SQLException {
        String sql = "DELETE FROM contacts WHERE (user_id = ? AND contact_id = ?) OR (user_id = ? AND contact_id = ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, contactId);
            ps.setInt(3, contactId);
            ps.setInt(4, userId);
            ps.executeUpdate();
        }
    }

    public List<Integer> getAcceptedContacts(int userId) throws SQLException {
        String sql = "SELECT contact_id FROM contacts WHERE user_id = ? AND status = 'accepted' " +
                     "UNION " +
                     "SELECT user_id FROM contacts WHERE contact_id = ? AND status = 'accepted'";
        List<Integer> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getInt(1));
                }
            }
        }
        return list;
    }

    public List<Integer> getPendingRequests(int receiverId) throws SQLException {
        String sql = "SELECT user_id FROM contacts WHERE contact_id = ? AND status = 'pending'";
        List<Integer> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, receiverId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getInt(1));
                }
            }
        }
        return list;
    }
}
