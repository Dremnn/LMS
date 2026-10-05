package com.lms.controller;

import com.lms.model.Assignment;
import com.lms.model.AssignmentSubmission;
import com.lms.model.Course;
import com.lms.model.FileData;
import com.lms.model.User;
import com.lms.service.AssignmentService;
import com.lms.util.FileDownloadUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.util.List;

/**
 * Học viên xem danh sách bài tập của khóa học, tải đề, nộp / nộp lại bài (doc, docx, txt, pdf, ...).
 */
@WebServlet(urlPatterns = {
    "/student/assignments",
    "/student/assignments/view",
    "/student/assignments/submit",
    "/student/assignments/download",
    "/student/assignments/mysubmission/download"
})
@MultipartConfig(
    maxFileSize = 10L * 1024 * 1024,
    maxRequestSize = 11L * 1024 * 1024,
    fileSizeThreshold = 512 * 1024
)
public class StudentAssignmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private AssignmentService assignmentService;

    @Override
    public void init() throws ServletException {
        this.assignmentService = new AssignmentService();
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (User) session.getAttribute("currentUser");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        User currentUser = getCurrentUser(request);

        // Flash message từ lần nộp bài trước
        HttpSession session = request.getSession(false);
        if (session != null) {
            if (session.getAttribute("flashError") != null) {
                request.setAttribute("error", session.getAttribute("flashError"));
                session.removeAttribute("flashError");
            }
            if (session.getAttribute("flashSuccess") != null) {
                request.setAttribute("success", session.getAttribute("flashSuccess"));
                session.removeAttribute("flashSuccess");
            }
        }

        try {
            if ("/student/assignments".equals(path)) {
                int courseId = Integer.parseInt(request.getParameter("courseId"));
                Course course = assignmentService.getCourseForStudent(courseId, currentUser.getId());
                List<Assignment> assignments = assignmentService.listForStudent(courseId, currentUser.getId());
                request.setAttribute("course", course);
                request.setAttribute("assignments", assignments);
                request.getRequestDispatcher("/WEB-INF/views/student/assignment-list.jsp").forward(request, response);

            } else if ("/student/assignments/view".equals(path)) {
                int id = Integer.parseInt(request.getParameter("id"));
                Assignment assignment = assignmentService.getForStudent(id, currentUser.getId());
                AssignmentSubmission mine = assignmentService.getMySubmission(id, currentUser.getId());
                request.setAttribute("assignment", assignment);
                request.setAttribute("mySubmission", mine);
                request.getRequestDispatcher("/WEB-INF/views/student/assignment-detail.jsp").forward(request, response);

            } else if ("/student/assignments/download".equals(path)) {
                int id = Integer.parseInt(request.getParameter("id"));
                FileData file = assignmentService.getAttachmentForStudent(id, currentUser.getId());
                FileDownloadUtil.send(response, file);

            } else if ("/student/assignments/mysubmission/download".equals(path)) {
                int submissionId = Integer.parseInt(request.getParameter("id"));
                FileData file = assignmentService.getMySubmissionFile(submissionId, currentUser.getId());
                FileDownloadUtil.send(response, file);

            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tham số không hợp lệ!");
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, e.getMessage());
        } catch (SecurityException e) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        User currentUser = getCurrentUser(request);

        if (!"/student/assignments/submit".equals(path)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        int assignmentId = -1;
        try {
            // Đọc multipart trước để phát hiện file vượt giới hạn dung lượng
            try {
                request.getParts();
            } catch (IllegalStateException e) {
                throw new IllegalArgumentException("File quá lớn! Dung lượng tối đa là 10 MB.");
            }

            assignmentId = Integer.parseInt(request.getParameter("assignmentId"));
            String note = request.getParameter("note");

            Part filePart = request.getPart("file");
            String fileName = filePart != null ? filePart.getSubmittedFileName() : null;
            byte[] fileBytes = (filePart != null && filePart.getSize() > 0)
                    ? filePart.getInputStream().readAllBytes() : null;

            assignmentService.submit(assignmentId, currentUser.getId(), fileName, fileBytes, note);

            request.getSession().setAttribute("flashSuccess", "Nộp bài thành công!");
            response.sendRedirect(request.getContextPath() + "/student/assignments/view?id=" + assignmentId);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tham số không hợp lệ!");
        } catch (IllegalArgumentException | IllegalStateException e) {
            request.getSession().setAttribute("flashError", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/student/assignments/view?id=" + assignmentId);
        } catch (SecurityException e) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        }
    }
}
