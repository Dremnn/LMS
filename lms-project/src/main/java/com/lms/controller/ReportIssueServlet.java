package com.lms.controller;

import com.lms.model.IssueReport;
import com.lms.service.IssueReportService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet(urlPatterns = {
    "/report-issue",
    "/api/report-issue"
})
public class ReportIssueServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private IssueReportService issueReportService;

    @Override
    public void init() throws ServletException {
        this.issueReportService = new IssueReportService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Forward directly to report-issue.jsp
        request.getRequestDispatcher("/report-issue.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        String email = null;
        String role = null;
        String issueType = null;
        String description = null;
        String pageUrl = null;
        String screenshots = null;

        String contentType = request.getContentType();
        if (contentType != null && contentType.toLowerCase().contains("application/json")) {
            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = request.getReader()) {
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
            }
            Map<String, String> jsonMap = parseSimpleJson(sb.toString());
            email = jsonMap.get("email");
            role = jsonMap.get("role");
            issueType = jsonMap.get("issue_type");
            description = jsonMap.get("description");
            pageUrl = jsonMap.get("page_url");
            screenshots = jsonMap.get("screenshots");
        } else {
            email = request.getParameter("email");
            role = request.getParameter("role");
            issueType = request.getParameter("issue_type");
            description = request.getParameter("description");
            pageUrl = request.getParameter("page_url");
            screenshots = request.getParameter("screenshots");
        }

        try {
            IssueReport report = issueReportService.submitReport(
                    email, role, issueType, description, pageUrl, screenshots
            );

            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write(String.format(
                    "{\"success\":true,\"referenceCode\":\"%s\",\"message\":\"Báo cáo sự cố đã được gửi thành công!\"}",
                    escapeJson(report.getReferenceCode())
            ));
        } catch (IllegalArgumentException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write(String.format(
                    "{\"success\":false,\"message\":\"%s\"}",
                    escapeJson(e.getMessage())
            ));
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\":false,\"message\":\"Đã xảy ra lỗi máy chủ. Vui lòng thử lại sau!\"}");
        }
    }

    private Map<String, String> parseSimpleJson(String json) {
        Map<String, String> map = new HashMap<>();
        if (json == null || json.trim().isEmpty()) {
            return map;
        }

        // Basic parsing for flat JSON strings or arrays
        json = json.trim();
        if (json.startsWith("{")) {
            json = json.substring(1);
        }
        if (json.endsWith("}")) {
            json = json.substring(0, json.length() - 1);
        }

        int length = json.length();
        int i = 0;
        while (i < length) {
            // Find key
            int keyStart = json.indexOf('"', i);
            if (keyStart == -1) break;
            int keyEnd = json.indexOf('"', keyStart + 1);
            if (keyEnd == -1) break;
            String key = json.substring(keyStart + 1, keyEnd);

            int colonPos = json.indexOf(':', keyEnd + 1);
            if (colonPos == -1) break;

            // Find value
            int valueStart = colonPos + 1;
            while (valueStart < length && Character.isWhitespace(json.charAt(valueStart))) {
                valueStart++;
            }
            if (valueStart >= length) break;

            char firstChar = json.charAt(valueStart);
            String value = "";
            if (firstChar == '"') {
                // String value, handle escaped quotes
                StringBuilder valSb = new StringBuilder();
                int cur = valueStart + 1;
                boolean escaped = false;
                while (cur < length) {
                    char c = json.charAt(cur);
                    if (escaped) {
                        if (c == 'n') valSb.append('\n');
                        else if (c == 'r') valSb.append('\r');
                        else if (c == 't') valSb.append('\t');
                        else valSb.append(c);
                        escaped = false;
                    } else if (c == '\\') {
                        escaped = true;
                    } else if (c == '"') {
                        break;
                    } else {
                        valSb.append(c);
                    }
                    cur++;
                }
                value = valSb.toString();
                i = cur + 1;
            } else if (firstChar == '[') {
                // Array value (e.g. screenshots array)
                int bracketCount = 1;
                int cur = valueStart + 1;
                while (cur < length && bracketCount > 0) {
                    char c = json.charAt(cur);
                    if (c == '[') bracketCount++;
                    else if (c == ']') bracketCount--;
                    cur++;
                }
                value = json.substring(valueStart, cur);
                i = cur;
            } else {
                // Number / boolean / null
                int commaPos = json.indexOf(',', valueStart);
                if (commaPos == -1) {
                    value = json.substring(valueStart).trim();
                    i = length;
                } else {
                    value = json.substring(valueStart, commaPos).trim();
                    i = commaPos + 1;
                }
            }

            map.put(key, value);
            int nextComma = json.indexOf(',', i);
            if (nextComma != -1 && nextComma >= i) {
                i = nextComma + 1;
            }
        }
        return map;
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
