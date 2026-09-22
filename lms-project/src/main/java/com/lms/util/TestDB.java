package com.lms.util;
import java.sql.*;
public class TestDB {
    public static void main(String[] args) {
        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement("UPDATE contacts SET status = 'accepted' WHERE status = 'pending'");
            int rows = ps.executeUpdate();
            System.out.println("Updated " + rows + " pending contacts.");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}