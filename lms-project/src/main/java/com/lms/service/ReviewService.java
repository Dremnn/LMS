package com.lms.service;

import com.lms.dao.EnrollmentDAO;
import com.lms.dao.ReviewDAO;
import com.lms.model.Review;

import java.util.List;

public class ReviewService {

    private final ReviewDAO reviewDAO;
    private final EnrollmentDAO enrollmentDAO;

    public ReviewService() {
        this.reviewDAO = new ReviewDAO();
        this.enrollmentDAO = new EnrollmentDAO();
    }

    public ReviewService(ReviewDAO reviewDAO, EnrollmentDAO enrollmentDAO) {
        this.reviewDAO = reviewDAO;
        this.enrollmentDAO = enrollmentDAO;
    }

    /**
     * Thêm mới hoặc cập nhật đánh giá cho khóa học.
     * Yêu cầu: Học viên phải đã đăng ký khóa học, điểm đánh giá từ 1 đến 5 sao.
     */
    public boolean addOrUpdateReview(int studentId, int courseId, int rating, String comment) {
        if (!enrollmentDAO.isEnrolled(studentId, courseId)) {
            throw new IllegalStateException("Bạn cần đăng ký khóa học này trước khi gửi đánh giá!");
        }

        if (rating < 1 || rating > 5) {
            throw new IllegalArgumentException("Điểm đánh giá phải từ 1 đến 5 sao!");
        }

        Review review = new Review(studentId, courseId, rating, comment != null ? comment.trim() : "");
        boolean success = reviewDAO.saveOrUpdate(review);
        if (success) {
            // Cập nhật lại avg_rating của khóa học trong DB
            reviewDAO.updateCourseAvgRating(courseId);
        }
        return success;
    }

    /**
     * Xóa đánh giá của học viên và cập nhật lại điểm trung bình của khóa học.
     */
    public boolean deleteReview(int studentId, int courseId) {
        boolean deleted = reviewDAO.delete(studentId, courseId);
        if (deleted) {
            reviewDAO.updateCourseAvgRating(courseId);
        }
        return deleted;
    }

    /**
     * Lấy danh sách đánh giá của khóa học.
     */
    public List<Review> getCourseReviews(int courseId) {
        return reviewDAO.findByCourseId(courseId);
    }

    /**
     * Lấy đánh giá của một học viên cho khóa học (nếu có).
     */
    public Review getStudentReview(int studentId, int courseId) {
        return reviewDAO.findByStudentAndCourse(studentId, courseId);
    }
}
