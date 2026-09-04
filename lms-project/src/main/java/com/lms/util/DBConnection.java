package com.lms.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class DBConnection {

    private static String url;
    private static String username;
    private static String password;

    // Static block: chạy 1 lần duy nhất khi class được load,
    // dùng để đọc file db.properties
    static {
        try {
            Class.forName("org.postgresql.Driver");
            Properties props = new Properties();
            InputStream input = DBConnection.class.getClassLoader()
                    .getResourceAsStream("db.properties");

            if (input == null) {
                throw new RuntimeException("Khong tim thay file db.properties");
            }

            props.load(input);
            url = props.getProperty("db.url");
            username = props.getProperty("db.username");
            password = props.getProperty("db.password");

        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Khong tim thay Driver com.microsoft.sqlserver.jdbc.SQLServerDriver", e);
        } catch (IOException e) {
            throw new RuntimeException("Loi doc file db.properties", e);
        }
    }

    // Trả về 1 Connection mới mỗi lần gọi
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(
                url,
                username,
                password
        );
    }

    // Hàm main dùng để test nhanh kết nối trực tiếp
    public static void main(String[] args) {
        System.out.println("Đang thử kết nối database...");
        try (Connection conn = getConnection()) {
            if (conn != null && !conn.isClosed()) {
                System.out.println("===> KẾT NỐI DATABASE THÀNH CÔNG! <===");
            }
        } catch (Exception e) {
            System.err.println("===> KẾT NỐI THẤT BẠI! <===");
            e.printStackTrace();
        }
    }
}