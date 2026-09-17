package com.lms.util;

import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

/**
 * Lop tien ich JPA theo chuan Murach Chapter 13 Slide 19 (UTE Web Programming)
 * Quan ly khoi tao va cung cap EntityManagerFactory cho persistence unit 'lmsPU'
 */
public class DBUtil {
    private static final EntityManagerFactory emf;

    static {
        EntityManagerFactory factory = null;
        try {
            Map<String, Object> props = new HashMap<>();
            try (InputStream input = DBUtil.class.getClassLoader().getResourceAsStream("db.properties")) {
                if (input != null) {
                    Properties p = new Properties();
                    p.load(input);
                    if (p.getProperty("db.url") != null) {
                        String url = p.getProperty("db.url").trim();
                        props.put("jakarta.persistence.jdbc.url", url);
                        props.put("javax.persistence.jdbc.url", url);
                    }
                    if (p.getProperty("db.username") != null) {
                        String user = p.getProperty("db.username").trim();
                        props.put("jakarta.persistence.jdbc.user", user);
                        props.put("javax.persistence.jdbc.user", user);
                    }
                    if (p.getProperty("db.password") != null) {
                        String pass = p.getProperty("db.password").trim();
                        props.put("jakarta.persistence.jdbc.password", pass);
                        props.put("javax.persistence.jdbc.password", pass);
                    }
                    String driver = p.getProperty("db.driver");
                    if (driver == null || driver.trim().isEmpty()) {
                        driver = "org.postgresql.Driver";
                    }
                    props.put("jakarta.persistence.jdbc.driver", driver.trim());
                    props.put("javax.persistence.jdbc.driver", driver.trim());
                }
            } catch (Exception ex) {
                System.err.println(">> [DBUtil] Khong the doc db.properties: " + ex.getMessage());
            }

            if (!props.isEmpty()) {
                factory = Persistence.createEntityManagerFactory("lmsPU", props);
            } else {
                factory = Persistence.createEntityManagerFactory("lmsPU");
            }
            System.out.println(">> [DBUtil] Khoi tao EntityManagerFactory (lmsPU) thanh cong!");
        } catch (Throwable e) {
            System.err.println(">> [DBUtil] Loi khoi tao EntityManagerFactory: " + e.getMessage());
            e.printStackTrace();
        }
        emf = factory;
    }

    public static EntityManagerFactory getEmFactory() {
        return emf;
    }

    public static void closeEmFactory() {
        if (emf != null && emf.isOpen()) {
            emf.close();
        }
    }
}
