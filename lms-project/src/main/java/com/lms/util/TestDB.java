package com.lms.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class TestDB {
    public static void main(String[] args) {
        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM issue_reports LIMIT 1");
            ResultSet rs = ps.executeQuery();
            System.out.println("issue_reports table verified!");
        } catch (Exception e) {
            e.printStackTrace();
        }
        System.exit(0);
    }
}

