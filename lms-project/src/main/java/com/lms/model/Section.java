package com.lms.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class Section implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int courseId;
    private String title;
    private int orderIndex;

    // Danh sách bài học thuộc chương này (dùng khi hiển thị trang chi tiết khóa học,
    // không map trực tiếp với 1 cột nào trong bảng `sections`)
    private List<Lesson> lessons = new ArrayList<>();

    public Section() {}

    public Section(int courseId, String title, int orderIndex) {
        this.courseId = courseId;
        this.title = title;
        this.orderIndex = orderIndex;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getCourseId() { return courseId; }
    public void setCourseId(int courseId) { this.courseId = courseId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public int getOrderIndex() { return orderIndex; }
    public void setOrderIndex(int orderIndex) { this.orderIndex = orderIndex; }

    public List<Lesson> getLessons() { return lessons; }
    public void setLessons(List<Lesson> lessons) { this.lessons = lessons; }
}