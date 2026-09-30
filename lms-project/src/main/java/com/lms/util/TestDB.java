package com.lms.util;
import java.sql.*;
public class TestDB {
    public static void main(String[] args) {
        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement("SELECT notified_deadline FROM quizzes LIMIT 1");
            ResultSet rs = ps.executeQuery();
            System.out.println("Column exists!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}