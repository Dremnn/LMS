package com.lms.controller;

import com.lms.dao.CourseDAO;
import com.lms.dao.StudyGroupDAO;
import com.lms.model.Course;
import com.lms.model.StudyGroup;
import com.lms.model.GroupMember;
import com.lms.model.User;
import com.lms.service.StudyGroupService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/instructor/groups")
public class InstructorGroupServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();
    private final StudyGroupDAO groupDAO = new StudyGroupDAO();
    private final StudyGroupService groupService = new StudyGroupService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null || (!"instructor".equals(currentUser.getRole()) && !"admin".equals(currentUser.getRole()))) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String courseIdStr = req.getParameter("courseId");
        if (courseIdStr == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu courseId");
            return;
        }

        try {
            int courseId = Integer.parseInt(courseIdStr);
            Course course = courseDAO.findById(courseId);
            
            if (course == null || (course.getInstructor().getId() != currentUser.getId() && !"admin".equals(currentUser.getRole()))) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập khóa học này.");
                return;
            }

            List<StudyGroup> groups = groupDAO.getGroupsByCourse(courseId);
            Map<Integer, List<GroupMember>> groupMembersMap = new HashMap<>();
            Map<Integer, com.lms.model.GroupSubmission> groupSubmissionsMap = new HashMap<>();
            com.lms.dao.GroupSubmissionDAO submissionDAO = new com.lms.dao.GroupSubmissionDAO();
            
            for (StudyGroup group : groups) {
                List<GroupMember> members = groupDAO.getMembersByGroup(group.getId());
                groupMembersMap.put(group.getId(), members);
                
                com.lms.model.GroupSubmission submission = submissionDAO.getSubmissionByGroupAndAssignment(group.getId(), courseId);
                if (submission != null) {
                    groupSubmissionsMap.put(group.getId(), submission);
                }
            }

            req.setAttribute("course", course);
            req.setAttribute("groups", groups);
            req.setAttribute("groupMembersMap", groupMembersMap);
            req.setAttribute("groupSubmissionsMap", groupSubmissionsMap);

            req.getRequestDispatcher("/WEB-INF/views/instructor/group-manage.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "CourseId không hợp lệ");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null || (!"instructor".equals(currentUser.getRole()) && !"admin".equals(currentUser.getRole()))) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String action = req.getParameter("action");
        String courseIdStr = req.getParameter("courseId");

        if ("auto_divide".equals(action)) {
            try {
                int courseId = Integer.parseInt(courseIdStr);
                int membersPerGroup = Integer.parseInt(req.getParameter("membersPerGroup"));
                
                Course course = courseDAO.findById(courseId);
                if (course != null && (course.getInstructor().getId() == currentUser.getId() || "admin".equals(currentUser.getRole()))) {
                    int created = groupService.autoDivideGroups(courseId, membersPerGroup);
                    session.setAttribute("flashSuccess", "Đã tạo thành công " + created + " nhóm mới!");
                }
            } catch (Exception e) {
                session.setAttribute("flashError", "Lỗi chia nhóm: " + e.getMessage());
            }
        } else if ("grade_submission".equals(action)) {
            try {
                int groupId = Integer.parseInt(req.getParameter("groupId"));
                int courseId = Integer.parseInt(courseIdStr); // used as assignmentId
                double score = Double.parseDouble(req.getParameter("score"));
                String feedback = req.getParameter("feedback");

                com.lms.dao.GroupSubmissionDAO submissionDAO = new com.lms.dao.GroupSubmissionDAO();
                com.lms.model.GroupSubmission submission = submissionDAO.getSubmissionByGroupAndAssignment(groupId, courseId);
                
                if (submission != null) {
                    submission.setScore(score);
                    submission.setFeedback(feedback);
                    if (submissionDAO.saveOrUpdate(submission)) {
                        session.setAttribute("flashSuccess", "Đã lưu điểm cho nhóm!");
                    } else {
                        session.setAttribute("flashError", "Lỗi khi lưu điểm vào DB.");
                    }
                } else {
                    session.setAttribute("flashError", "Nhóm này chưa nộp bài, không thể chấm điểm.");
                }
            } catch (Exception e) {
                session.setAttribute("flashError", "Dữ liệu điểm không hợp lệ.");
            }
        }
        
        resp.sendRedirect(req.getContextPath() + "/instructor/groups?courseId=" + courseIdStr);
    }
}
