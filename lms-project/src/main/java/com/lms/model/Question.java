package com.lms.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import jakarta.persistence.*;

@Entity
@Table(name = "questions")
public class Question implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @Column(name = "quiz_id", nullable = false)
    private int quizId;

    @Column(name = "content", columnDefinition = "TEXT", nullable = false)
    private String content;

    @Column(name = "question_type", nullable = false)
    private String questionType; // "single_choice" | "multi_choice"

    // Quan hệ ORM
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "quiz_id", insertable = false, updatable = false)
    private Quiz quiz;

    // Danh sách đáp án của câu hỏi này (dùng khi hiển thị form làm bài/quản lý)
    @OneToMany(mappedBy = "question")
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

    public Quiz getQuiz() { return quiz; }
    public void setQuiz(Quiz quiz) { this.quiz = quiz; }

    public List<AnswerOption> getOptions() { return options; }
    public void setOptions(List<AnswerOption> options) { this.options = options; }
}