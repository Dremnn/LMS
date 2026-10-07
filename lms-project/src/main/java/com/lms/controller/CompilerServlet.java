package com.lms.controller;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.lms.dao.CodingExerciseDAO;
import com.lms.model.CodingExercise;
import com.lms.model.ExerciseTestCase;
import com.lms.model.StudentCodeSubmission;
import com.lms.model.User;
import com.lms.service.CompilerService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Date;
import java.util.List;

@WebServlet(urlPatterns = {"/api/compiler/run", "/api/compiler/test", "/api/compiler/submit", "/api/compiler/exercise"})
public class CompilerServlet extends HttpServlet {

    private final Gson gson = new Gson();
    private final CodingExerciseDAO exerciseDAO = new CodingExerciseDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        if ("/api/compiler/exercise".equals(path)) {
            String lessonIdStr = req.getParameter("lessonId");
            if (lessonIdStr == null || lessonIdStr.trim().isEmpty()) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Missing lessonId\"}");
                return;
            }

            try {
                int lessonId = Integer.parseInt(lessonIdStr);
                CodingExercise exercise = exerciseDAO.findByLessonId(lessonId);
                if (exercise == null) {
                    out.print("{\"success\":true,\"hasExercise\":false}");
                    return;
                }

                JsonObject json = new JsonObject();
                json.addProperty("success", true);
                json.addProperty("hasExercise", true);
                json.addProperty("exerciseId", exercise.getId());
                json.addProperty("title", exercise.getTitle() != null ? exercise.getTitle() : "Bài tập thực hành code");
                json.addProperty("description", exercise.getDescription() != null ? exercise.getDescription() : "");
                json.addProperty("language", exercise.getLanguage());
                json.addProperty("initialCode", exercise.getInitialCode() != null ? exercise.getInitialCode() : "");

                // Kiểm tra xem học viên hiện tại đã PASS bài này chưa
                HttpSession session = req.getSession(false);
                User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
                boolean passed = false;
                if (currentUser != null) {
                    passed = exerciseDAO.hasStudentPassed(exercise.getId(), currentUser.getId());
                }
                json.addProperty("isPassed", passed);

                // Public Test Cases
                JsonArray testCasesJson = new JsonArray();
                List<ExerciseTestCase> testCases = exerciseDAO.findTestCases(exercise.getId());
                for (ExerciseTestCase tc : testCases) {
                    JsonObject tcObj = new JsonObject();
                    tcObj.addProperty("id", tc.getId());
                    tcObj.addProperty("isHidden", tc.isHidden());
                    if (!tc.isHidden()) {
                        tcObj.addProperty("inputData", tc.getInputData() != null ? tc.getInputData() : "");
                        tcObj.addProperty("expectedOutput", tc.getExpectedOutput());
                    }
                    tcObj.addProperty("points", tc.getPoints());
                    testCasesJson.add(tcObj);
                }
                json.add("testCases", testCasesJson);

                out.print(gson.toJson(json));
            } catch (Exception e) {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        String path = req.getServletPath();

        try {
            StringBuilder sb = new StringBuilder();
            BufferedReader reader = req.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }

            JsonObject requestJson = gson.fromJson(sb.toString(), JsonObject.class);
            String language = requestJson.has("language") ? requestJson.get("language").getAsString() : "cpp";
            String code = requestJson.has("code") ? requestJson.get("code").getAsString() : "";
            String stdin = requestJson.has("stdin") ? requestJson.get("stdin").getAsString() : "";

            if (code == null || code.trim().isEmpty()) {
                JsonObject error = new JsonObject();
                error.addProperty("success", false);
                error.addProperty("output", "Vui lòng nhập mã nguồn trước khi chạy.");
                out.print(gson.toJson(error));
                return;
            }

            // 1. Chạy code tự do (Run Sandbox)
            if ("/api/compiler/run".equals(path)) {
                CompilerService.CompilerResult result = CompilerService.executeCode(language, code, stdin);
                JsonObject responseJson = new JsonObject();
                responseJson.addProperty("success", result.isSuccess());
                responseJson.addProperty("output", result.getOutput());
                out.print(gson.toJson(responseJson));
                return;
            }

            // 2. Chạy kiểm thử test case (Test / Submit)
            int exerciseId = requestJson.has("exerciseId") ? requestJson.get("exerciseId").getAsInt() : 0;
            CodingExercise exercise = exerciseDAO.findById(exerciseId);
            if (exercise == null) {
                JsonObject error = new JsonObject();
                error.addProperty("success", false);
                error.addProperty("output", "Không tìm thấy thông tin bài tập (ID: " + exerciseId + ").");
                out.print(gson.toJson(error));
                return;
            }

            List<ExerciseTestCase> testCases = exercise.getTestCases();
            if (testCases == null || testCases.isEmpty()) {
                JsonObject error = new JsonObject();
                error.addProperty("success", false);
                error.addProperty("output", "Bài tập này chưa được Giảng viên thiết lập Test Case.");
                out.print(gson.toJson(error));
                return;
            }

            boolean isSubmit = "/api/compiler/submit".equals(path);
            int totalTests = testCases.size();
            int passedTests = 0;
            JsonArray details = new JsonArray();

            for (ExerciseTestCase tc : testCases) {
                String inputData = tc.getInputData() != null ? tc.getInputData() : "";
                String expected = tc.getExpectedOutput() != null ? tc.getExpectedOutput().trim() : "";

                CompilerService.CompilerResult runRes = CompilerService.executeCode(language, code, inputData);
                String actual = runRes.getOutput() != null ? runRes.getOutput().trim() : "";

                boolean passed = runRes.isSuccess() && expected.equals(actual);
                if (passed) {
                    passedTests++;
                }

                JsonObject tcDetail = new JsonObject();
                tcDetail.addProperty("testCaseId", tc.getId());
                tcDetail.addProperty("isHidden", tc.isHidden());
                tcDetail.addProperty("passed", passed);

                if (!tc.isHidden() || !isSubmit) {
                    tcDetail.addProperty("input", inputData);
                    tcDetail.addProperty("expected", expected);
                    tcDetail.addProperty("actual", actual);
                } else {
                    tcDetail.addProperty("message", passed ? "Test case ẩn: ĐẠT" : "Test case ẩn: KHÔNG ĐẠT");
                }
                details.add(tcDetail);
            }

            boolean allPassed = (passedTests == totalTests);
            String status = allPassed ? "PASSED" : "FAILED";

            // Nếu là SUBMIT -> Lưu kết quả vào CSDL
            if (isSubmit) {
                HttpSession session = req.getSession(false);
                User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
                if (currentUser != null) {
                    StudentCodeSubmission sub = new StudentCodeSubmission();
                    sub.setStudent(currentUser);
                    sub.setExercise(exercise);
                    sub.setSubmittedCode(code);
                    sub.setStatus(status);
                    sub.setOutputMessage("Passed " + passedTests + "/" + totalTests + " test cases.");
                    sub.setSubmittedAt(new Date());
                    exerciseDAO.saveSubmission(sub);
                }
            }

            JsonObject responseJson = new JsonObject();
            responseJson.addProperty("success", true);
            responseJson.addProperty("status", status);
            responseJson.addProperty("allPassed", allPassed);
            responseJson.addProperty("passedTests", passedTests);
            responseJson.addProperty("totalTests", totalTests);
            responseJson.add("details", details);

            out.print(gson.toJson(responseJson));

        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JsonObject error = new JsonObject();
            error.addProperty("success", false);
            error.addProperty("output", "Server error: " + e.getMessage());
            out.print(gson.toJson(error));
            e.printStackTrace();
        }
    }
}