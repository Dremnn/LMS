package com.lms.dao;

import com.lms.model.GroupSubmission;
import com.lms.util.DBUtil;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.TypedQuery;
import java.util.List;

public class GroupSubmissionDAO {

    public boolean saveOrUpdate(GroupSubmission submission) {
        EntityManager em = DBUtil.getEmFactory().createEntityManager();
        EntityTransaction trans = em.getTransaction();
        try {
            trans.begin();
            if (submission.getId() == 0) {
                em.persist(submission);
            } else {
                em.merge(submission);
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

    public GroupSubmission getSubmissionByGroupAndAssignment(int groupId, int assignmentId) {
        EntityManager em = DBUtil.getEmFactory().createEntityManager();
        try {
            TypedQuery<GroupSubmission> q = em.createQuery(
                "SELECT s FROM GroupSubmission s WHERE s.studyGroup.id = :groupId AND s.assignmentId = :assignmentId", 
                GroupSubmission.class);
            q.setParameter("groupId", groupId);
            q.setParameter("assignmentId", assignmentId);
            return q.getResultStream().findFirst().orElse(null);
        } finally {
            em.close();
        }
    }
}
