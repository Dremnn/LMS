package com.lms.util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

public class DBConnection {

    private static volatile HikariDataSource dataSource;

    private static synchronized void initDataSource() {
        if (dataSource != null && !dataSource.isClosed()) {
            return;
        }
        try {
            Properties props = new Properties();
            try (InputStream input = DBConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
                if (input == null) {
                    throw new RuntimeException("Khong tim thay file db.properties");
                }
                props.load(input);
            }

            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(props.getProperty("db.url"));
            config.setUsername(props.getProperty("db.username"));
            config.setPassword(props.getProperty("db.password"));
            config.setDriverClassName("org.postgresql.Driver");

            // Phù hợp Supabase Pooler (tránh quá tải connection limit)
            config.setMaximumPoolSize(10);
            config.setMinimumIdle(1);
            config.setConnectionTimeout(30000);   // Chờ tối đa 30s
            config.setIdleTimeout(600000);
            config.setMaxLifetime(1800000);
            config.setInitializationFailTimeout(0); // Không crash ứng dụng nếu gặp trục trặc mạng tức thời

            dataSource = new HikariDataSource(config);
            System.out.println("===> HikariCP Connection Pool da khoi tao thanh cong! <===");
        } catch (Exception e) {
            System.err.println("===> Loi khoi tao HikariCP: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Loi khoi tao Connection Pool", e);
        }
    }

    // Mượn 1 Connection có sẵn từ pool - tự động khởi tạo lại an toàn nếu pool chưa sẵn sàng
    public static Connection getConnection() throws SQLException {
        if (dataSource == null || dataSource.isClosed()) {
            initDataSource();
        }
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
