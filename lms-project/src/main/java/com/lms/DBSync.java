package com.lms;

import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

public class DBSync {
    public static void main(String[] args) {
        try {
            Map<String, Object> props = new HashMap<>();
            try (InputStream input = DBSync.class.getClassLoader().getResourceAsStream("db.properties")) {
                if (input != null) {
                    Properties p = new Properties();
                    p.load(input);
                    if (p.getProperty("db.url") != null) props.put("jakarta.persistence.jdbc.url", p.getProperty("db.url").trim());
                    if (p.getProperty("db.username") != null) props.put("jakarta.persistence.jdbc.user", p.getProperty("db.username").trim());
                    if (p.getProperty("db.password") != null) props.put("jakarta.persistence.jdbc.password", p.getProperty("db.password").trim());
                    String driver = p.getProperty("db.driver");
                    props.put("jakarta.persistence.jdbc.driver", (driver != null) ? driver.trim() : "org.postgresql.Driver");
                }
            }
            
            // Override hbm2ddl to auto-create tables
            props.put("hibernate.hbm2ddl.auto", "update");

            System.out.println("Starting JPA schema update...");
            EntityManagerFactory emf = Persistence.createEntityManagerFactory("lmsPU", props);
            emf.close();
            System.out.println("Schema update successful!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
