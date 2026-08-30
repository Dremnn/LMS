package com.lms.model;

import java.io.Serializable;

public class AnswerOption implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int questionId;
    private String content;
    private boolean correct;

    public AnswerOption() {}

    public AnswerOption(int questionId, String content, boolean correct) {
        this.questionId = questionId;
        this.content = content;
        this.correct = correct;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getQuestionId() { return questionId; }
    public void setQuestionId(int questionId) { this.questionId = questionId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public boolean isCorrect() { return correct; }
    public void setCorrect(boolean correct) { this.correct = correct; }
}