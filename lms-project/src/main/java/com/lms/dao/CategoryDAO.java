package com.lms.dao;

import com.lms.model.Category;
import com.lms.util.DBConnection;
import com.lms.util.DBUtil;
import jakarta.persistence.EntityManager;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * CategoryDAO chuẩn JPA Chapter 13 Slide 19 (Murach's Java Servlets and JSP)
 * Sử dụng EntityManagerFactory từ DBUtil, tự động fallback JDBC nếu cần
 */
public class CategoryDAO {

    public List<Category> findAll() {
        if (DBUtil.getEmFactory() != null) {
            EntityManager em = null;
            try {
                em = DBUtil.getEmFactory().createEntityManager();
                return em.createQuery("SELECT c FROM Category c ORDER BY c.name ASC", Category.class).getResultList();
            } catch (Exception e) {
                // Fallback JDBC
            } finally {
                if (em != null && em.isOpen()) em.close();
            }
        }
        return findAllJdbc();
    }

    private List<Category> findAllJdbc() {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT id, name FROM categories ORDER BY name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(new Category(rs.getInt("id"), rs.getString("name")));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Category findById(int id) {
        if (DBUtil.getEmFactory() != null) {
            EntityManager em = null;
            try {
                em = DBUtil.getEmFactory().createEntityManager();
                return em.find(Category.class, id);
            } catch (Exception e) {
                // Fallback JDBC
            } finally {
                if (em != null && em.isOpen()) em.close();
            }
        }
        return findByIdJdbc(id);
    }

    private Category findByIdJdbc(int id) {
        String sql = "SELECT id, name FROM categories WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new Category(rs.getInt("id"), rs.getString("name"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}