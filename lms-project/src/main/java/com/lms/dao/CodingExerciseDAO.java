package com.lms.dao;

import com.lms.model.CodingExercise;
import com.lms.model.ExerciseTestCase;
import com.lms.model.StudentCodeSubmission;
import com.lms.util.DBUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.NoResultException;
import java.util.Collections;
import java.util.List;

public class CodingExerciseDAO {

    public CodingExercise findByLessonId(int lessonId) {
        EntityManager em = DBUtil.getEntityManager();
        try {
            return em.createQuery("SELECT e FROM CodingExercise e LEFT JOIN FETCH e.testCases WHERE e.lesson.id = :lessonId", CodingExercise.class)
                    .setParameter("lessonId", lessonId)
                    .getSingleResult();
        } catch (NoResultException e) {
            return null;
        } finally {
            em.close();
        }
    }

    public CodingExercise findById(int id) {
        EntityManager em = DBUtil.getEntityManager();
        try {
            return em.createQuery("SELECT e FROM CodingExercise e LEFT JOIN FETCH e.testCases WHERE e.id = :id", CodingExercise.class)
                    .setParameter("id", id)
                    .getSingleResult();
        } catch (NoResultException e) {
            return null;
        } finally {
            em.close();
        }
    }

    public void saveOrUpdate(CodingExercise exercise) {
        EntityManager em = DBUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            if (exercise.getId() == 0) {
                em.persist(exercise);
            } else {
                em.merge(exercise);
            }
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public void delete(int id) {
        EntityManager em = DBUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            CodingExercise e = em.find(CodingExercise.class, id);
            if (e != null) {
                em.remove(e);
            }
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public List<ExerciseTestCase> findTestCases(int exerciseId) {
        EntityManager em = DBUtil.getEntityManager();
        try {
            return em.createQuery("SELECT tc FROM ExerciseTestCase tc WHERE tc.exercise.id = :exerciseId ORDER BY tc.id ASC", ExerciseTestCase.class)
                    .setParameter("exerciseId", exerciseId)
                    .getResultList();
        } catch (Exception e) {
            return Collections.emptyList();
        } finally {
            em.close();
        }
    }

    public void saveSubmission(StudentCodeSubmission sub) {
        EntityManager em = DBUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(sub);
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public boolean hasStudentPassed(int exerciseId, int studentId) {
        EntityManager em = DBUtil.getEntityManager();
        try {
            Long count = em.createQuery("SELECT COUNT(s) FROM StudentCodeSubmission s WHERE s.exercise.id = :exId AND s.student.id = :stId AND s.status = 'PASSED'", Long.class)
                    .setParameter("exId", exerciseId)
                    .setParameter("stId", studentId)
                    .getSingleResult();
            return count != null && count > 0;
        } catch (Exception e) {
            return false;
        } finally {
            em.close();
        }
    }

    public StudentCodeSubmission getLatestSubmission(int exerciseId, int studentId) {
        EntityManager em = DBUtil.getEntityManager();
        try {
            List<StudentCodeSubmission> list = em.createQuery("SELECT s FROM StudentCodeSubmission s WHERE s.exercise.id = :exId AND s.student.id = :stId ORDER BY s.submittedAt DESC", StudentCodeSubmission.class)
                    .setParameter("exId", exerciseId)
                    .setParameter("stId", studentId)
                    .setMaxResults(1)
                    .getResultList();
            return list.isEmpty() ? null : list.get(0);
        } catch (Exception e) {
            return null;
        } finally {
            em.close();
        }
    }
}