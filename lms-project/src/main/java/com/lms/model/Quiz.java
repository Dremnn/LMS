package com.lms.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import jakarta.persistence.*;

@Entity
@Table(name = "quizzes")
public class Quiz implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @Column(name = "section_id")
    private Integer sectionId;   // nullable - quiz gắn vào Section

    @Column(name = "course_id")
    private Integer courseId;    // nullable - quiz gắn vào toàn bộ Course

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "pass_score", nullable = false)
    private BigDecimal passScore;

    @Column(name = "max_attempts")
    private Integer maxAttempts; // null = không giới hạn số lần làm

    @Column(name = "time_limit_minutes")
    private Integer timeLimitMinutes;

    @Column(name = "open_at")
    private LocalDateTime openAt;

    @Column(name = "close_at")
    private LocalDateTime closeAt;

    // Quan hệ ORM
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "section_id", insertable = false, updatable = false)
    private Section section;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "course_id", insertable = false, updatable = false)
    private Course course;

    @OneToMany(mappedBy = "quiz")
    private List<Question> questions = new ArrayList<>();

    // Bổ sung từ JOIN - không map trực tiếp cột DB
    @Transient
    private String sectionTitle;

    @Transient
    private String courseTitle;

    @Transient
    private int totalQuestions;

    public Quiz() {}

    public Quiz(Integer sectionId, Integer courseId, String title,
                BigDecimal passScore, Integer maxAttempts,Integer timeLimitMinutes,
                LocalDateTime openAt, LocalDateTime closeAt) {
        this.sectionId = sectionId;
        this.courseId = courseId;
        this.title = title;
        this.passScore = passScore;
        this.maxAttempts = maxAttempts;
        this.timeLimitMinutes = timeLimitMinutes;
        this.openAt = openAt;
        this.closeAt = closeAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Integer getSectionId() { return sectionId; }
    public void setSectionId(Integer sectionId) { this.sectionId = sectionId; }

    public Integer getCourseId() { return courseId; }
    public void setCourseId(Integer courseId) { this.courseId = courseId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public BigDecimal getPassScore() { return passScore; }
    public void setPassScore(BigDecimal passScore) { this.passScore = passScore; }

    public Integer getMaxAttempts() { return maxAttempts; }
    public void setMaxAttempts(Integer maxAttempts) { this.maxAttempts = maxAttempts; }

    public Integer getTimeLimitMinutes() { return timeLimitMinutes; }
    public void setTimeLimitMinutes(Integer timeLimitMinutes) { this.timeLimitMinutes = timeLimitMinutes; }

    public LocalDateTime getOpenAt() { return openAt; }
    public void setOpenAt(LocalDateTime openAt) { this.openAt = openAt; }

    public LocalDateTime getCloseAt() { return closeAt; }
    public void setCloseAt(LocalDateTime closeAt) { this.closeAt = closeAt; }

    public boolean isOpenNow() {
        LocalDateTime now = LocalDateTime.now();
        if (openAt != null && now.isBefore(openAt)) return false;
        if (closeAt != null && now.isAfter(closeAt)) return false;
        return true;
    }
    private static final java.time.format.DateTimeFormatter DISPLAY_FMT =
        java.time.format.DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy");

    public String getOpenAtFormatted() { return openAt != null ? openAt.format(DISPLAY_FMT) : null; }
    public String getCloseAtFormatted() { return closeAt != null ? closeAt.format(DISPLAY_FMT) : null; }

    public boolean isNotYetOpen() { return openAt != null && LocalDateTime.now().isBefore(openAt); }
    public boolean isClosedNow() { return closeAt != null && LocalDateTime.now().isAfter(closeAt); }

    public String getSectionTitle() { return sectionTitle; }
    public void setSectionTitle(String sectionTitle) { this.sectionTitle = sectionTitle; }

    public String getCourseTitle() { return courseTitle; }
    public void setCourseTitle(String courseTitle) { this.courseTitle = courseTitle; }

    public int getTotalQuestions() { return totalQuestions; }
    public void setTotalQuestions(int totalQuestions) { this.totalQuestions = totalQuestions; }

    public Section getSection() { return section; }
    public void setSection(Section section) { this.section = section; }

    public Course getCourse() { return course; }
    public void setCourse(Course course) { this.course = course; }

    public List<Question> getQuestions() { return questions; }
    public void setQuestions(List<Question> questions) { this.questions = questions; }
}