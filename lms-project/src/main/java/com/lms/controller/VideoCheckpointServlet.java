package com.lms.controller;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.lms.dao.LessonDAO;
import com.lms.dao.QuestionDAO;
import com.lms.model.AnswerOption;
import com.lms.model.Lesson;
import com.lms.model.Question;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet(urlPatterns = {"/api/checkpoint", "/api/checkpoint/verify-quiz", "/api/checkpoint/questions"})
public class VideoCheckpointServlet extends HttpServlet {

    private final Gson gson = new Gson();
    private final LessonDAO lessonDAO = new LessonDAO();
    private final QuestionDAO questionDAO = new QuestionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            if ("/api/checkpoint/questions".equals(path)) {
                // Lấy danh sách câu hỏi của khóa học (cả quiz của Section hoặc quiz gắn trực tiếp vào Course)
                String courseIdStr = req.getParameter("courseId");
                int courseId = courseIdStr != null ? Integer.parseInt(courseIdStr) : 0;
                
                JsonArray qArr = new JsonArray();
                String sql = "SELECT q.id as quiz_id, q.title as quiz_title, quest.id as question_id, quest.content as question_content " +
                             "FROM questions quest " +
                             "INNER JOIN quizzes q ON quest.quiz_id = q.id " +
                             "LEFT JOIN sections s ON q.section_id = s.id " +
                             "WHERE q.course_id = ? OR s.course_id = ? " +
                             "ORDER BY q.id ASC, quest.id ASC";

                try (java.sql.Connection conn = com.lms.util.DBConnection.getConnection();
                     java.sql.PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setInt(1, courseId);
                    stmt.setInt(2, courseId);
                    try (java.sql.ResultSet rs = stmt.executeQuery()) {
                        while (rs.next()) {
                            JsonObject qObj = new JsonObject();
                            qObj.addProperty("id", rs.getInt("question_id"));
                            qObj.addProperty("quizTitle", rs.getString("quiz_title"));
                            qObj.addProperty("content", rs.getString("question_content"));
                            qArr.add(qObj);
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }

                out.print(gson.toJson(qArr));
                return;
            }

            // /api/checkpoint: Lấy thông tin checkpoint của bài học
            String lessonIdStr = req.getParameter("lessonId");
            if (lessonIdStr == null || lessonIdStr.trim().isEmpty()) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\":false,\"message\":\"Thiếu lessonId\"}");
                return;
            }

            int lessonId = Integer.parseInt(lessonIdStr);
            Lesson lesson = lessonDAO.findById(lessonId);
            if (lesson == null || lesson.getVideoCheckpointSeconds() == null || lesson.getVideoCheckpointSeconds() <= 0) {
                out.print("{\"success\":true,\"hasCheckpoint\":false}");
                return;
            }

            JsonObject res = new JsonObject();
            res.addProperty("success", true);
            res.addProperty("hasCheckpoint", true);
            res.addProperty("checkpointSeconds", lesson.getVideoCheckpointSeconds());
            res.addProperty("checkpointType", lesson.getCheckpointType() != null ? lesson.getCheckpointType() : "code");
            res.addProperty("checkpointRefId", lesson.getCheckpointRefId());

            if ("quiz".equalsIgnoreCase(lesson.getCheckpointType()) && lesson.getCheckpointRefId() != null) {
                Question question = questionDAO.findById(lesson.getCheckpointRefId());
                if (question != null) {
                    JsonObject qJson = new JsonObject();
                    qJson.addProperty("questionId", question.getId());
                    qJson.addProperty("content", question.getContent());
                    
                    JsonArray optArr = new JsonArray();
                    List<AnswerOption> options = questionDAO.findOptionsByQuestionId(question.getId());
                    for (AnswerOption opt : options) {
                        JsonObject optObj = new JsonObject();
                        optObj.addProperty("id", opt.getId());
                        optObj.addProperty("content", opt.getContent());
                        // Không gửi isCorrect xuống client để bảo mật
                        optArr.add(optObj);
                    }
                    qJson.add("options", optArr);
                    res.add("quiz", qJson);
                }
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

        if ("/api/checkpoint/verify-quiz".equals(path)) {
            try {
                StringBuilder sb = new StringBuilder();
                BufferedReader reader = req.getReader();
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }

                JsonObject reqJson = gson.fromJson(sb.toString(), JsonObject.class);
                int questionId = reqJson.get("questionId").getAsInt();
                int selectedOptionId = reqJson.get("selectedOptionId").getAsInt();

                Question question = questionDAO.findById(questionId);
                List<AnswerOption> options = questionDAO.findOptionsByQuestionId(questionId);

                boolean isCorrect = false;
                for (AnswerOption opt : options) {
                    if (opt.getId() == selectedOptionId && opt.isCorrect()) {
                        isCorrect = true;
                        break;
                    }
                }

                JsonObject result = new JsonObject();
                result.addProperty("success", true);
                result.addProperty("isCorrect", isCorrect);
                if (isCorrect) {
                    String exp = (question != null && question.getExplanation() != null && !question.getExplanation().trim().isEmpty())
                            ? question.getExplanation()
                            : "Tuyệt vời! Bạn đã chọn đáp án hoàn toàn chính xác.";
                    result.addProperty("explanation", exp);
                } else {
                    result.addProperty("message", "Đáp án chưa chính xác. Vui lòng suy nghĩ và chọn lại nhé!");
                }

                out.print(gson.toJson(result));

            } catch (Exception e) {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
            }
        }
    }
}