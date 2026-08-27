package com.lms.model;

import java.io.Serializable;

public class Lesson implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int sectionId;
    private String title;
    private String videoUrl;
    private String documentUrl;
    private Integer durationMinutes;
    private int orderIndex;

    public Lesson() {}

    public Lesson(int sectionId, String title, String videoUrl, String documentUrl,
                  Integer durationMinutes, int orderIndex) {
        this.sectionId = sectionId;
        this.title = title;
        this.videoUrl = videoUrl;
        this.documentUrl = documentUrl;
        this.durationMinutes = durationMinutes;
        this.orderIndex = orderIndex;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getSectionId() { return sectionId; }
    public void setSectionId(int sectionId) { this.sectionId = sectionId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getVideoUrl() { return videoUrl; }
    public void setVideoUrl(String videoUrl) { this.videoUrl = videoUrl; }

    public String getDocumentUrl() { return documentUrl; }
    public void setDocumentUrl(String documentUrl) { this.documentUrl = documentUrl; }

    public Integer getDurationMinutes() { return durationMinutes; }
    public void setDurationMinutes(Integer durationMinutes) { this.durationMinutes = durationMinutes; }

    public int getOrderIndex() { return orderIndex; }
    public void setOrderIndex(int orderIndex) { this.orderIndex = orderIndex; }
}