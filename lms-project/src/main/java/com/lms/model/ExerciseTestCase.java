package com.lms.model;

import jakarta.persistence.*;

@Entity
@Table(name = "exercise_test_cases")
public class ExerciseTestCase {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "exercise_id", nullable = false)
    private CodingExercise exercise;

    @Column(name = "input_data", columnDefinition = "TEXT")
    private String inputData;

    @Column(name = "expected_output", columnDefinition = "TEXT", nullable = false)
    private String expectedOutput;

    @Column(name = "is_hidden", nullable = false)
    private boolean isHidden;

    private int points = 10;

    public ExerciseTestCase() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public CodingExercise getExercise() { return exercise; }
    public void setExercise(CodingExercise exercise) { this.exercise = exercise; }
    public String getInputData() { return inputData; }
    public void setInputData(String inputData) { this.inputData = inputData; }
    public String getExpectedOutput() { return expectedOutput; }
    public void setExpectedOutput(String expectedOutput) { this.expectedOutput = expectedOutput; }
    public boolean isHidden() { return isHidden; }
    public void setHidden(boolean isHidden) { this.isHidden = isHidden; }
    public int getPoints() { return points; }
    public void setPoints(int points) { this.points = points; }
}
