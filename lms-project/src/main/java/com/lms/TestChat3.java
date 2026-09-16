package com.lms;

import com.lms.util.DBConnection;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

public class TestChat3 {
    public static void main(String[] args) throws Exception {
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
             System.out.println("Contacts schema:");
             ResultSet rs = stmt.executeQuery("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'contacts'");
             while (rs.next()) {
                 System.out.println(rs.getString(1) + " : " + rs.getString(2));
             }
             System.out.println("Constraints:");
             rs = stmt.executeQuery("SELECT conname, pg_get_constraintdef(c.oid) FROM pg_constraint c JOIN pg_namespace n ON n.oid = c.connamespace WHERE conrelid = 'contacts'::regclass");
             while (rs.next()) {
                 System.out.println(rs.getString(1) + " : " + rs.getString(2));
             }
        }
    }
}
