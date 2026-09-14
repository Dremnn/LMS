package com.lms.dao;

import com.lms.model.Category;
import com.lms.util.DBUtil;
import jakarta.persistence.EntityManager;

import java.util.List;

/**
 * CategoryDAO chuẩn JPA Chapter 13 Slide 19 (Murach's Java Servlets and JSP)
 * Sử dụng EntityManagerFactory từ DBUtil để truy vấn thực thể Category
 */
public class CategoryDAO {

    public List<Category> findAll() {
        EntityManager em = DBUtil.getEmFactory().createEntityManager();
        try {
            return em.createQuery("SELECT c FROM Category c ORDER BY c.name ASC", Category.class).getResultList();
        } finally {
            em.close();
        }
    }

    public Category findById(int id) {
        EntityManager em = DBUtil.getEmFactory().createEntityManager();
        try {
            return em.find(Category.class, id);
        } finally {
            em.close();
        }
    }
}