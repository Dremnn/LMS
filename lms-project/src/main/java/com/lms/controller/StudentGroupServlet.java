package com.lms.controller;

import com.lms.dao.CourseDAO;
import com.lms.dao.GroupSubmissionDAO;
import com.lms.dao.StudyGroupDAO;
import com.lms.model.Course;
import com.lms.model.GroupMember;
import com.lms.model.GroupSubmission;
import com.lms.model.StudyGroup;
import com.lms.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/student/my-group")
public class StudentGroupServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();
    private final StudyGroupDAO groupDAO = new StudyGroupDAO();
    private final GroupSubmissionDAO submissionDAO = new GroupSubmissionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
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
            if (course == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy khóa học");
                return;
            }

            StudyGroup myGroup = groupDAO.getGroupOfStudent(courseId, currentUser.getId());
            
            if (myGroup != null) {
                List<GroupMember> members = groupDAO.getMembersByGroup(myGroup.getId());
                req.setAttribute("members", members);

                // Giả định bài tập nhóm cuối khóa có assignmentId = courseId (hoặc 1 ID cố định)
                GroupSubmission submission = submissionDAO.getSubmissionByGroupAndAssignment(myGroup.getId(), courseId);
                req.setAttribute("submission", submission);
            }

            req.setAttribute("course", course);
            req.setAttribute("myGroup", myGroup);
            req.getRequestDispatcher("/WEB-INF/views/student/my-group.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "CourseId không hợp lệ");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String courseIdStr = req.getParameter("courseId");
        String fileUrl = req.getParameter("fileUrl"); // Link Google Drive hoặc Github

        try {
            int courseId = Integer.parseInt(courseIdStr);
            StudyGroup myGroup = groupDAO.getGroupOfStudent(courseId, currentUser.getId());

            if (myGroup != null && fileUrl != null && !fileUrl.trim().isEmpty()) {
                GroupSubmission submission = submissionDAO.getSubmissionByGroupAndAssignment(myGroup.getId(), courseId);
                if (submission == null) {
                    submission = new GroupSubmission();
                    submission.setStudyGroup(myGroup);
                    submission.setAssignmentId(courseId);
                }
                
                // Cập nhật người nộp và file
                submission.setSubmitter(currentUser);
                submission.setFileUrl(fileUrl.trim());

                if (submissionDAO.saveOrUpdate(submission)) {
                    session.setAttribute("flashSuccess", "Đã nộp bài tập nhóm thành công!");
                } else {
                    session.setAttribute("flashError", "Có lỗi xảy ra khi nộp bài.");
                }
            } else {
                session.setAttribute("flashError", "Vui lòng nhập link bài nộp hợp lệ.");
            }
        } catch (Exception e) {
            session.setAttribute("flashError", "Lỗi: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/student/my-group?courseId=" + courseIdStr);
    }
}
