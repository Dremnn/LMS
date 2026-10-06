package com.lms.dao;

import com.lms.model.GroupMember;
import com.lms.model.StudyGroup;
import com.lms.util.DBUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import java.util.List;

public class StudyGroupDAO {

    public boolean createGroup(StudyGroup group) {
        EntityManager em = DBUtil.getEmFactory().createEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            em.persist(group);
            trans.commit();
            return true;
        } catch (Exception e) {
            if (trans.isActive()) trans.rollback();
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    public boolean updateGroup(StudyGroup group) {
        EntityManager em = DBUtil.getEmFactory().createEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            em.merge(group);
            trans.commit();
            return true;
        } catch (Exception e) {
            if (trans.isActive()) trans.rollback();
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    public boolean deleteGroup(int groupId) {
        EntityManager em = DBUtil.getEmFactory().createEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            StudyGroup group = em.find(StudyGroup.class, groupId);
            if (group != null) {
                em.remove(group);
            }
            trans.commit();
            return true;
        } catch (Exception e) {
            if (trans.isActive()) trans.rollback();
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    public List<StudyGroup> getGroupsByCourse(int courseId) {
        EntityManager em = DBUtil.getEmFactory().createEntityManager();
        try {
            TypedQuery<StudyGroup> q = em.createQuery(
                "SELECT g FROM StudyGroup g WHERE g.course.id = :courseId", StudyGroup.class);
            q.setParameter("courseId", courseId);
            return q.getResultList();
        } finally {
            em.close();
        }
    }

    public boolean addGroupMember(GroupMember member) {
        EntityManager em = DBUtil.getEmFactory().createEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            em.persist(member);
            trans.commit();
            return true;
        } catch (Exception e) {
            if (trans.isActive()) trans.rollback();
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    public boolean removeGroupMember(int groupId, int studentId) {
        EntityManager em = DBUtil.getEmFactory().createEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            TypedQuery<GroupMember> q = em.createQuery(
                "SELECT gm FROM GroupMember gm WHERE gm.studyGroup.id = :groupId AND gm.student.id = :studentId", 
                GroupMember.class);
            q.setParameter("groupId", groupId);
            q.setParameter("studentId", studentId);
            GroupMember member = q.getResultStream().findFirst().orElse(null);
            if (member != null) {
                em.remove(member);
            }
            trans.commit();
            return true;
        } catch (Exception e) {
            if (trans.isActive()) trans.rollback();
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    public List<GroupMember> getMembersByGroup(int groupId) {
        EntityManager em = DBUtil.getEmFactory().createEntityManager();
        try {
            TypedQuery<GroupMember> q = em.createQuery(
                "SELECT gm FROM GroupMember gm WHERE gm.studyGroup.id = :groupId", GroupMember.class);
            q.setParameter("groupId", groupId);
            return q.getResultList();
        } finally {
            em.close();
        }
    }

    public List<Integer> getGroupedStudentIds(int courseId) {
        EntityManager em = DBUtil.getEmFactory().createEntityManager();
        try {
            TypedQuery<Integer> q = em.createQuery(
                "SELECT gm.student.id FROM GroupMember gm WHERE gm.studyGroup.course.id = :courseId", Integer.class);
            q.setParameter("courseId", courseId);
            return q.getResultList();
        } finally {
            em.close();
        }
    }

    public StudyGroup getGroupOfStudent(int courseId, int studentId) {
        EntityManager em = DBUtil.getEmFactory().createEntityManager();
        try {
            TypedQuery<StudyGroup> q = em.createQuery(
                "SELECT gm.studyGroup FROM GroupMember gm WHERE gm.studyGroup.course.id = :courseId AND gm.student.id = :studentId", 
                StudyGroup.class);
            q.setParameter("courseId", courseId);
            q.setParameter("studentId", studentId);
            return q.getResultStream().findFirst().orElse(null);
        } finally {
            em.close();
        }
    }
}
