package com.lms;

import com.lms.dao.UserDAO;
import com.lms.dao.ContactDAO;
import com.lms.model.User;
import com.lms.util.DBConnection;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

public class TestChat {
    public static void main(String[] args) throws Exception {
        UserDAO userDAO = new UserDAO();
        User user = userDAO.findByEmail("ndv@gmail.com");
        if (user == null) {
            System.out.println("ndv@gmail.com NOT FOUND!");
        } else {
            System.out.println("FOUND: " + user.getId() + " - " + user.getFullName() + " - Role: " + user.getRole());
        }
        
        // Also check if there is any unique constraint on contacts
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT user_id, contact_id, status FROM contacts LIMIT 5")) {
             System.out.println("Contacts:");
             while (rs.next()) {
                 System.out.println(rs.getInt(1) + " - " + rs.getInt(2) + " : " + rs.getString(3));
             }
        }
    }
}
