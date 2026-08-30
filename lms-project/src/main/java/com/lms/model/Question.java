package com.lms.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class Question implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int quizId;
    private String content;
    private String questionType; // "single_choice" | "multi_choice"

    // Danh sách đáp án của câu hỏi này (dùng khi hiển thị form làm bài/quản lý)
    private List<AnswerOption> options = new ArrayList<>();

    public Question() {}

    public Question(int quizId, String content, String questionType) {
        this.quizId = quizId;
        this.content = content;
        this.questionType = questionType;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getQuizId() { return quizId; }
    public void setQuizId(int quizId) { this.quizId = quizId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getQuestionType() { return questionType; }
    public void setQuestionType(String questionType) { this.questionType = questionType; }

    public List<AnswerOption> getOptions() { return options; }
    public void setOptions(List<AnswerOption> options) { this.options = options; }
}