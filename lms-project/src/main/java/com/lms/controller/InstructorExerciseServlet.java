package com.lms.controller;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.lms.dao.CodingExerciseDAO;
import com.lms.dao.LessonDAO;
import com.lms.model.CodingExercise;
import com.lms.model.ExerciseTestCase;
import com.lms.model.Lesson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

@WebServlet(urlPatterns = {
    "/instructor/courses/lessons/exercise",
    "/instructor/courses/lessons/exercise/save",
    "/instructor/courses/lessons/exercise/delete"
})
public class InstructorExerciseServlet extends HttpServlet {

    private final Gson gson = new Gson();
    private final CodingExerciseDAO exerciseDAO = new CodingExerciseDAO();
    private final LessonDAO lessonDAO = new LessonDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        String lessonIdStr = req.getParameter("lessonId");
        if (lessonIdStr == null || lessonIdStr.trim().isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\":false,\"message\":\"Thiếu tham số lessonId\"}");
            return;
        }

        try {
            int lessonId = Integer.parseInt(lessonIdStr);
            Lesson lesson = lessonDAO.findById(lessonId);
            CodingExercise exercise = exerciseDAO.findByLessonId(lessonId);

            JsonObject res = new JsonObject();
            res.addProperty("success", true);
            res.addProperty("lessonId", lessonId);
            res.addProperty("videoCheckpointSeconds", lesson != null ? lesson.getVideoCheckpointSeconds() : null);
            res.addProperty("checkpointType", lesson != null ? lesson.getCheckpointType() : null);
            res.addProperty("checkpointRefId", lesson != null ? lesson.getCheckpointRefId() : null);

            if (exercise == null) {
                res.addProperty("hasExercise", false);
            } else {
                res.addProperty("hasExercise", true);
                res.addProperty("exerciseId", exercise.getId());
                res.addProperty("title", exercise.getTitle() != null ? exercise.getTitle() : "");
                res.addProperty("description", exercise.getDescription() != null ? exercise.getDescription() : "");
                res.addProperty("language", exercise.getLanguage());
                res.addProperty("initialCode", exercise.getInitialCode() != null ? exercise.getInitialCode() : "");

                JsonArray tcArr = new JsonArray();
                List<ExerciseTestCase> testCases = exerciseDAO.findTestCases(exercise.getId());
                for (ExerciseTestCase tc : testCases) {
                    JsonObject tcObj = new JsonObject();
                    tcObj.addProperty("id", tc.getId());
                    tcObj.addProperty("inputData", tc.getInputData() != null ? tc.getInputData() : "");
                    tcObj.addProperty("expectedOutput", tc.getExpectedOutput());
                    tcObj.addProperty("isHidden", tc.isHidden());
                    tcObj.addProperty("points", tc.getPoints());
                    tcArr.add(tcObj);
                }
                res.add("testCases", tcArr);
            }

            out.print(gson.toJson(res));
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            StringBuilder sb = new StringBuilder();
            BufferedReader reader = req.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }

            JsonObject data = gson.fromJson(sb.toString(), JsonObject.class);

            if ("/instructor/courses/lessons/exercise/delete".equals(path)) {
                int exerciseId = data.get("exerciseId").getAsInt();
                int lessonId = data.get("lessonId").getAsInt();
                exerciseDAO.delete(exerciseId);
                lessonDAO.updateCheckpoint(lessonId, null, null, null);
                out.print("{\"success\":true,\"message\":\"Đã xóa bài tập code thành công!\"}");
                return;
            }

            int lessonId = data.get("lessonId").getAsInt();
            String title = data.has("title") ? data.get("title").getAsString() : "Bài tập code";
            String description = data.has("description") ? data.get("description").getAsString() : "";
            String language = data.has("language") ? data.get("language").getAsString() : "cpp";
            String initialCode = data.has("initialCode") ? data.get("initialCode").getAsString() : "";
            
            Integer checkpointSeconds = null;
            if (data.has("videoCheckpointSeconds") && !data.get("videoCheckpointSeconds").isJsonNull()) {
                String secStr = data.get("videoCheckpointSeconds").getAsString().trim();
                if (!secStr.isEmpty()) {
                    checkpointSeconds = Integer.parseInt(secStr);
                }
            }
            String checkpointType = data.has("checkpointType") ? data.get("checkpointType").getAsString() : "code";
            Integer checkpointRefId = data.has("checkpointRefId") && !data.get("checkpointRefId").isJsonNull() ? data.get("checkpointRefId").getAsInt() : null;

            Lesson lesson = lessonDAO.findById(lessonId);
            if (lesson == null) {
                out.print("{\"success\":false,\"message\":\"Không tìm thấy bài học!\"}");
                return;
            }

            CodingExercise exercise = exerciseDAO.findByLessonId(lessonId);
            if (exercise == null) {
                exercise = new CodingExercise();
                exercise.setLesson(lesson);
            }

            exercise.setTitle(title);
            exercise.setDescription(description);
            exercise.setLanguage(language);
            exercise.setInitialCode(initialCode);

            // Xử lý danh sách test cases
            List<ExerciseTestCase> newTestCases = new ArrayList<>();
            if (data.has("testCases") && data.get("testCases").isJsonArray()) {
                JsonArray tcArr = data.getAsJsonArray("testCases");
                for (JsonElement el : tcArr) {
                    JsonObject tcObj = el.getAsJsonObject();
                    ExerciseTestCase tc = new ExerciseTestCase();
                    tc.setExercise(exercise);
                    tc.setInputData(tcObj.has("inputData") ? tcObj.get("inputData").getAsString() : "");
                    tc.setExpectedOutput(tcObj.has("expectedOutput") ? tcObj.get("expectedOutput").getAsString() : "");
                    tc.setHidden(tcObj.has("isHidden") && tcObj.get("isHidden").getAsBoolean());
                    tc.setPoints(tcObj.has("points") ? tcObj.get("points").getAsInt() : 10);
                    newTestCases.add(tc);
                }
            }

            if (exercise.getTestCases() != null) {
                exercise.getTestCases().clear();
                exercise.getTestCases().addAll(newTestCases);
            } else {
                exercise.setTestCases(newTestCases);
            }

            exerciseDAO.saveOrUpdate(exercise);

            // Cập nhật checkpoint trên bài học
                        if (checkpointSeconds != null) {
                if ("quiz".equalsIgnoreCase(checkpointType)) {
                    lessonDAO.updateCheckpoint(lessonId, checkpointSeconds, "quiz", checkpointRefId);
                } else {
                    lessonDAO.updateCheckpoint(lessonId, checkpointSeconds, "code", exercise.getId());
                }
            } else {
                lessonDAO.updateCheckpoint(lessonId, null, null, null);
            }

            out.print("{\"success\":true,\"message\":\"Đã lưu bài tập và test case thành công!\",\"exerciseId\":" + exercise.getId() + "}");

        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"success\":false,\"message\":\"Lỗi máy chủ: " + e.getMessage() + "\"}");
            e.printStackTrace();
        }
    }
}