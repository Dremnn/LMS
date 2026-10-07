package com.lms.model;

import jakarta.persistence.*;
import java.util.List;

@Entity
@Table(name = "coding_exercises")
public class CodingExercise {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lesson_id", nullable = false)
    private Lesson lesson;

    @Column
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false)
    private String language;

    @Column(name = "initial_code", columnDefinition = "TEXT")
    private String initialCode;

    @OneToMany(mappedBy = "exercise", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ExerciseTestCase> testCases;

    public CodingExercise() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public Lesson getLesson() { return lesson; }
    public void setLesson(Lesson lesson) { this.lesson = lesson; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getLanguage() { return language; }
    public void setLanguage(String language) { this.language = language; }
    public String getInitialCode() { return initialCode; }
    public void setInitialCode(String initialCode) { this.initialCode = initialCode; }
    public List<ExerciseTestCase> getTestCases() { return testCases; }
    public void setTestCases(List<ExerciseTestCase> testCases) { this.testCases = testCases; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
}