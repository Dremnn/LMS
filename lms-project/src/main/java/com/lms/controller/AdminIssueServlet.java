package com.lms.controller;

import com.lms.model.IssueReport;
import com.lms.model.User;
import com.lms.service.IssueReportService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {
    "/admin/issues",
    "/admin/issues/update-status"
})
public class AdminIssueServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private IssueReportService issueReportService;

    @Override
    public void init() throws ServletException {
        this.issueReportService = new IssueReportService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session != null) {
            if (session.getAttribute("flashError") != null) {
                request.setAttribute("error", session.getAttribute("flashError"));
                session.removeAttribute("flashError");
            }
            if (session.getAttribute("flashSuccess") != null) {
                request.setAttribute("successMessage", session.getAttribute("flashSuccess"));
                session.removeAttribute("flashSuccess");
            }
        }

        String status = request.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = "all";
        }

        String role = request.getParameter("role");
        if (role == null || role.trim().isEmpty()) {
            role = "all";
        }

        String keyword = request.getParameter("keyword");

        List<IssueReport> issues = issueReportService.getReports(status, role, keyword);
        Map<String, Integer> stats = issueReportService.getStats();

        request.setAttribute("issues", issues);
        request.setAttribute("stats", stats);
        request.setAttribute("currentStatus", status);
        request.setAttribute("currentRole", role);
        request.setAttribute("keyword", keyword);

        request.getRequestDispatcher("/WEB-INF/views/admin/issue-manage.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        try {
            String issueIdStr = request.getParameter("issueId");
            if (issueIdStr == null || issueIdStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Mã ID sự cố không hợp lệ!");
            }
            int issueId = Integer.parseInt(issueIdStr.trim());

            String action = request.getParameter("action"); // "resolve", "reject", "pending"
            String adminNote = request.getParameter("adminNote");
            Integer adminUserId = currentUser != null ? currentUser.getId() : null;

            if ("resolve".equalsIgnoreCase(action) || "resolved".equalsIgnoreCase(action)) {
                issueReportService.resolveIssue(issueId, adminNote, adminUserId);
                session.setAttribute("flashSuccess", "Đã cập nhật trạng thái sự cố sang: ĐÃ XỬ LÝ!");
            } else if ("reject".equalsIgnoreCase(action) || "rejected".equalsIgnoreCase(action)) {
                issueReportService.rejectIssue(issueId, adminNote, adminUserId);
                session.setAttribute("flashSuccess", "Đã cập nhật trạng thái sự cố sang: TỪ CHỐI!");
            } else if ("pending".equalsIgnoreCase(action)) {
                issueReportService.setPendingIssue(issueId, adminNote, adminUserId);
                session.setAttribute("flashSuccess", "Đã chuyển sự cố về trạng thái: CHỜ XỬ LÝ!");
            } else {
                throw new IllegalArgumentException("Hành động không hợp lệ: " + action);
            }

        } catch (IllegalArgumentException e) {
            session.setAttribute("flashError", e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("flashError", "Đã xảy ra lỗi khi cập nhật sự cố!");
        }

        // Redirect back to /admin/issues
        String redirectUrl = request.getContextPath() + "/admin/issues";
        String filterStatus = request.getParameter("filterStatus");
        if (filterStatus != null && !filterStatus.trim().isEmpty()) {
            redirectUrl += "?status=" + filterStatus.trim();
        }
        response.sendRedirect(redirectUrl);
    }
}
