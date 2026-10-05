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
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.List;

/**
 * Giảng viên quản lý Bài tập của khóa học:
 *  - tạo / sửa / xóa bài tập (mô tả + file đính kèm đều tùy chọn, có thể đặt hạn nộp ngày + giờ)
 *  - xem danh sách học viên đã nộp bài và tải file bài nộp
 */
@WebServlet(urlPatterns = {
    "/instructor/assignments/new",
    "/instructor/assignments/edit",
    "/instructor/assignments/delete",
    "/instructor/assignments/submissions",
    "/instructor/assignments/download",
    "/instructor/assignments/submissions/download"
})
@MultipartConfig(
    maxFileSize = 10L * 1024 * 1024,        // mỗi file tối đa 10 MB
    maxRequestSize = 11L * 1024 * 1024,
    fileSizeThreshold = 512 * 1024          // vượt 512KB mới ghi tạm xuống đĩa
)
public class InstructorAssignmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String FORM_VIEW = "/WEB-INF/views/instructor/assignment-form.jsp";
    private static final String SUBMISSIONS_VIEW = "/WEB-INF/views/instructor/assignment-submissions.jsp";

    private AssignmentService assignmentService;

    @Override
    public void init() throws ServletException {
        this.assignmentService = new AssignmentService();
    }

    private User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (User) session.getAttribute("currentUser");
    }

    // =========================================================================
    // GET
    // =========================================================================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();
        User currentUser = getCurrentUser(request);

        try {
            if ("/instructor/assignments/new".equals(path)) {
                int courseId = Integer.parseInt(request.getParameter("courseId"));
                Course course = assignmentService.getCourseForManage(courseId, currentUser);
                request.setAttribute("course", course);
                request.setAttribute("editMode", false);
                request.getRequestDispatcher(FORM_VIEW).forward(request, response);

            } else if ("/instructor/assignments/edit".equals(path)) {
                int id = Integer.parseInt(request.getParameter("id"));
                Assignment assignment = assignmentService.getForInstructor(id, currentUser);
                Course course = assignmentService.getCourseForManage(assignment.getCourseId(), currentUser);
                request.setAttribute("course", course);
                request.setAttribute("assignment", assignment);
                request.setAttribute("editMode", true);
                request.setAttribute("formTitle", assignment.getTitle());
                request.setAttribute("formDescription", assignment.getDescription());
                request.setAttribute("formDueAt", toInputValue(assignment.getDueAt()));
                request.getRequestDispatcher(FORM_VIEW).forward(request, response);

            } else if ("/instructor/assignments/submissions".equals(path)) {
                int id = Integer.parseInt(request.getParameter("id"));
                Assignment assignment = assignmentService.getForInstructor(id, currentUser);
                Course course = assignmentService.getCourseForManage(assignment.getCourseId(), currentUser);
                List<AssignmentSubmission> submissions = assignmentService.listSubmissions(id, currentUser);

                // Số học viên trong khóa lấy từ danh sách bài tập của khóa (đã có subquery đếm)
                int enrolled = 0;
                for (Assignment a : assignmentService.listForInstructor(course.getId(), currentUser)) {
                    if (a.getId() == id) { enrolled = a.getEnrolledCount(); break; }
                }

                request.setAttribute("course", course);
                request.setAttribute("assignment", assignment);
                request.setAttribute("submissions", submissions);
                request.setAttribute("enrolledCount", enrolled);
                request.getRequestDispatcher(SUBMISSIONS_VIEW).forward(request, response);

            } else if ("/instructor/assignments/download".equals(path)) {
                int id = Integer.parseInt(request.getParameter("id"));
                FileData file = assignmentService.getAttachmentForInstructor(id, currentUser);
                FileDownloadUtil.send(response, file);

            } else if ("/instructor/assignments/submissions/download".equals(path)) {
                int submissionId = Integer.parseInt(request.getParameter("id"));
                FileData file = assignmentService.getSubmissionFileForInstructor(submissionId, currentUser);
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

    // =========================================================================
    // POST
    // =========================================================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        User currentUser = getCurrentUser(request);

        try {
            if ("/instructor/assignments/delete".equals(path)) {
                int assignmentId = Integer.parseInt(request.getParameter("assignmentId"));
                int courseId = Integer.parseInt(request.getParameter("courseId"));
                assignmentService.delete(assignmentId, currentUser);
                response.sendRedirect(request.getContextPath() + "/instructor/courses/manage?id=" + courseId);
                return;
            }

            if ("/instructor/assignments/new".equals(path) || "/instructor/assignments/edit".equals(path)) {
                handleSave(request, response, currentUser, "/instructor/assignments/edit".equals(path));
                return;
            }

            response.sendError(HttpServletResponse.SC_NOT_FOUND);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tham số không hợp lệ!");
        } catch (IllegalArgumentException | IllegalStateException e) {
            // Lỗi ở các thao tác không có form để hiển thị lại (VD: xóa)
            HttpSession session = request.getSession();
            session.setAttribute("flashError", e.getMessage());
            String courseId = request.getParameter("courseId");
            response.sendRedirect(request.getContextPath() +
                    (courseId != null && !courseId.isEmpty()
                            ? "/instructor/courses/manage?id=" + courseId
                            : "/instructor/courses"));
        } catch (SecurityException e) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, e.getMessage());
        }
    }

    // Tạo mới hoặc cập nhật: nếu lỗi nhập liệu thì hiển thị lại form với dữ liệu đã nhập
    private void handleSave(HttpServletRequest request, HttpServletResponse response,
                            User currentUser, boolean editMode) throws ServletException, IOException {

        String title = null, description = null, dueRaw = null;
        int courseId = -1, assignmentId = -1;

        try {
            // Đọc multipart trước (phát hiện sớm trường hợp file vượt giới hạn dung lượng)
            Part filePart = readParts(request);

            title = request.getParameter("title");
            description = request.getParameter("description");
            dueRaw = request.getParameter("dueAt");
            LocalDateTime dueAt = parseDue(dueRaw);

            String fileName = filePart != null ? filePart.getSubmittedFileName() : null;
            byte[] fileBytes = (filePart != null && filePart.getSize() > 0)
                    ? filePart.getInputStream().readAllBytes() : null;

            if (editMode) {
                assignmentId = Integer.parseInt(request.getParameter("assignmentId"));
                Assignment existing = assignmentService.getForInstructor(assignmentId, currentUser);
                courseId = existing.getCourseId();
                String attachMode = request.getParameter("removeAttachment") != null ? "remove" : "keep";
                assignmentService.update(assignmentId, currentUser, title, description, dueAt,
                        attachMode, fileName, fileBytes);
            } else {
                courseId = Integer.parseInt(request.getParameter("courseId"));
                assignmentService.create(courseId, currentUser, title, description, dueAt, fileName, fileBytes);
            }

            response.sendRedirect(request.getContextPath() + "/instructor/courses/manage?id=" + courseId);

        } catch (IllegalArgumentException | IllegalStateException e) {
            // Hiển thị lại form + giữ nguyên nội dung đã nhập (trừ file phải chọn lại)
            try {
                if (editMode) {
                    Assignment a = assignmentService.getForInstructor(assignmentId, currentUser);
                    request.setAttribute("assignment", a);
                    request.setAttribute("course", assignmentService.getCourseForManage(a.getCourseId(), currentUser));
                } else {
                    request.setAttribute("course", assignmentService.getCourseForManage(courseId, currentUser));
                }
            } catch (RuntimeException ex) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, ex.getMessage());
                return;
            }
            request.setAttribute("editMode", editMode);
            request.setAttribute("error", e.getMessage());
            request.setAttribute("formTitle", title);
            request.setAttribute("formDescription", description);
            request.setAttribute("formDueAt", dueRaw);
            request.getRequestDispatcher(FORM_VIEW).forward(request, response);
        }
    }

    // Đọc toàn bộ multipart; nếu vượt giới hạn dung lượng thì báo lỗi thân thiện
    private Part readParts(HttpServletRequest request) throws IOException, ServletException {
        try {
            request.getParts();
        } catch (IllegalStateException e) {
            throw new IllegalArgumentException("File quá lớn! Dung lượng tối đa là 10 MB.");
        }
        return request.getPart("file");
    }

    private LocalDateTime parseDue(String raw) {
        if (raw == null || raw.trim().isEmpty()) return null;
        try {
            return LocalDateTime.parse(raw.trim());
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Ngày giờ hạn nộp không hợp lệ!");
        }
    }

    // LocalDateTime -> giá trị cho <input type="datetime-local"> (yyyy-MM-ddTHH:mm)
    private String toInputValue(LocalDateTime dt) {
        return dt == null ? "" : dt.withSecond(0).withNano(0).toString();
    }
}
