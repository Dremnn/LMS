package com.lms;

import com.lms.dao.UserDAO;
import com.lms.model.User;
import com.lms.util.DBConnection;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

public class TestChat2 {
    public static void main(String[] args) throws Exception {
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT id, email, full_name, role FROM users WHERE role='instructor'")) {
             System.out.println("Instructors:");
             while (rs.next()) {
                 System.out.println(rs.getInt(1) + " - " + rs.getString(2) + " - " + rs.getString(3));
             }
        }
    }
}
