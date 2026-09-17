package com.lms.util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

public class DBConnection {

    private static HikariDataSource dataSource;

    // Static block: chạy 1 lần duy nhất khi class được load,
    // khởi tạo sẵn 1 "hồ chứa" connection thay vì tạo mới mỗi lần gọi
    static {
        try {
            Properties props = new Properties();
            InputStream input = DBConnection.class.getClassLoader()
                    .getResourceAsStream("db.properties");

            if (input == null) {
                throw new RuntimeException("Khong tim thay file db.properties");
            }
            props.load(input);

            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(props.getProperty("db.url"));
            config.setUsername(props.getProperty("db.username"));
            config.setPassword(props.getProperty("db.password"));
            config.setDriverClassName("org.postgresql.Driver");

            // Giữ sẵn tối đa 10 connection đã kết nối tới cloud DB, tái sử dụng liên tục
            config.setMaximumPoolSize(30);
            config.setMinimumIdle(2);
            config.setConnectionTimeout(30000);   // Chờ tối đa 30s nếu pool đang bận hết
            config.setIdleTimeout(600000);         // Connection rảnh quá 10 phút thì đóng bớt
            config.setMaxLifetime(1800000);        // Connection sống tối đa 30 phút rồi tự làm mới

            dataSource = new HikariDataSource(config);

            System.out.println("===> HikariCP Connection Pool da khoi tao thanh cong! <===");

        } catch (IOException e) {
            throw new RuntimeException("Loi doc file db.properties", e);
        }
    }

    // Mượn 1 Connection có sẵn từ pool - KHÔNG tạo kết nối TCP mới mỗi lần gọi
    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
    }

    // Hàm main dùng để test nhanh kết nối trực tiếp
    public static void main(String[] args) {
        System.out.println("Đang thử kết nối database qua connection pool...");
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
