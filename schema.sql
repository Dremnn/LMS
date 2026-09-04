CREATE DATABASE LMS_DB;
GO
USE LMS_DB;
GO

/* 
   1. NHÓM NGƯỜI DÙNG
    */

CREATE TABLE users (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    full_name       NVARCHAR(100)   NOT NULL,
    email           VARCHAR(100)    NOT NULL UNIQUE,
    password_hash   VARCHAR(255)    NOT NULL,
    role            VARCHAR(20)     NOT NULL
                        CONSTRAINT CK_users_role CHECK (role IN ('student','instructor','admin')),
    avatar_url      VARCHAR(255)    NULL,
    status          VARCHAR(20)     NOT NULL
                        CONSTRAINT DF_users_status DEFAULT 'active'
                        CONSTRAINT CK_users_status CHECK (status IN ('active','locked','pending')),
    created_at      DATETIME2       NOT NULL CONSTRAINT DF_users_created_at DEFAULT SYSDATETIME()
);
GO

/* 
   2. NHÓM KHÓA HỌC
    */

CREATE TABLE categories (
    id      INT IDENTITY(1,1) PRIMARY KEY,
    name    NVARCHAR(100) NOT NULL UNIQUE
);
GO

CREATE TABLE courses (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    instructor_id   INT             NOT NULL,
    category_id     INT             NULL,
    title           NVARCHAR(200)   NOT NULL,
    description     NVARCHAR(MAX)   NULL,
    thumbnail_url   VARCHAR(255)    NULL,
    price           DECIMAL(10,2)   NOT NULL CONSTRAINT DF_courses_price DEFAULT 0,
    pass_score      DECIMAL(5,2)    NULL,
    status          VARCHAR(20)     NOT NULL
                        CONSTRAINT DF_courses_status DEFAULT 'draft'
                        CONSTRAINT CK_courses_status CHECK (status IN ('draft','pending','published','rejected')),
    reject_reason   NVARCHAR(255)   NULL,
    avg_rating      DECIMAL(3,2)    NOT NULL CONSTRAINT DF_courses_avg_rating DEFAULT 0,
    total_students  INT             NOT NULL CONSTRAINT DF_courses_total_students DEFAULT 0,
    total_lessons   INT             NOT NULL CONSTRAINT DF_courses_total_lessons DEFAULT 0,
    created_at      DATETIME2       NOT NULL CONSTRAINT DF_courses_created_at DEFAULT SYSDATETIME(),

    CONSTRAINT FK_courses_instructor FOREIGN KEY (instructor_id) REFERENCES users(id),
    CONSTRAINT FK_courses_category   FOREIGN KEY (category_id)   REFERENCES categories(id)
);
GO

CREATE TABLE sections (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    course_id       INT             NOT NULL,
    title           NVARCHAR(200)   NOT NULL,
    order_index     INT             NOT NULL CONSTRAINT DF_sections_order DEFAULT 0,

    CONSTRAINT FK_sections_course FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);
GO

CREATE TABLE lessons (
    id                  INT IDENTITY(1,1) PRIMARY KEY,
    section_id          INT             NOT NULL,
    title               NVARCHAR(200)   NOT NULL,
    video_url           VARCHAR(255)    NULL,
    document_url        VARCHAR(255)    NULL,
    duration_minutes    INT             NULL,
    order_index         INT             NOT NULL CONSTRAINT DF_lessons_order DEFAULT 0,

    CONSTRAINT FK_lessons_section FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE
);
GO

/* 
   3. NHÓM GHI DANH & TIẾN ĐỘ
    */

CREATE TABLE enrollments (
    id                  INT IDENTITY(1,1) PRIMARY KEY,
    student_id          INT             NOT NULL,
    course_id           INT             NOT NULL,
    progress_percent    DECIMAL(5,2)    NOT NULL CONSTRAINT DF_enrollments_progress DEFAULT 0,
    status              VARCHAR(20)     NOT NULL
                            CONSTRAINT DF_enrollments_status DEFAULT 'in_progress'
                            CONSTRAINT CK_enrollments_status CHECK (status IN ('in_progress','completed')),
    enrolled_at         DATETIME2       NOT NULL CONSTRAINT DF_enrollments_enrolled_at DEFAULT SYSDATETIME(),
    completed_at        DATETIME2       NULL,

    CONSTRAINT FK_enrollments_student FOREIGN KEY (student_id) REFERENCES users(id),
    CONSTRAINT FK_enrollments_course  FOREIGN KEY (course_id)  REFERENCES courses(id),
    CONSTRAINT UQ_enrollments_student_course UNIQUE (student_id, course_id)
);
GO

CREATE TABLE lesson_progress (
    id                  INT IDENTITY(1,1) PRIMARY KEY,
    enrollment_id       INT             NOT NULL,
    lesson_id           INT             NOT NULL,
    is_completed        BIT             NOT NULL CONSTRAINT DF_lesson_progress_completed DEFAULT 0,
    completed_at        DATETIME2       NULL,

    CONSTRAINT FK_lesson_progress_enrollment FOREIGN KEY (enrollment_id) REFERENCES enrollments(id) ON DELETE CASCADE,
    CONSTRAINT FK_lesson_progress_lesson     FOREIGN KEY (lesson_id)     REFERENCES lessons(id),
    CONSTRAINT UQ_lesson_progress_enrollment_lesson UNIQUE (enrollment_id, lesson_id)
);
GO

/* 
   4. NHÓM QUIZ
    */

CREATE TABLE quizzes (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    section_id      INT             NULL,
    course_id       INT             NULL,
    title           NVARCHAR(200)   NOT NULL,
    pass_score      DECIMAL(5,2)    NOT NULL CONSTRAINT DF_quizzes_pass_score DEFAULT 50,

    CONSTRAINT FK_quizzes_section FOREIGN KEY (section_id) REFERENCES sections(id),
    CONSTRAINT FK_quizzes_course  FOREIGN KEY (course_id)  REFERENCES courses(id)
);
GO

CREATE TABLE questions (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    quiz_id         INT             NOT NULL,
    content         NVARCHAR(MAX)   NOT NULL,
    question_type   VARCHAR(20)     NOT NULL
                        CONSTRAINT DF_questions_type DEFAULT 'single_choice'
                        CONSTRAINT CK_questions_type CHECK (question_type IN ('single_choice','multi_choice')),

    CONSTRAINT FK_questions_quiz FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE
);
GO

CREATE TABLE answer_options (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    question_id     INT             NOT NULL,
    content         NVARCHAR(255)   NOT NULL,
    is_correct      BIT             NOT NULL CONSTRAINT DF_answer_options_correct DEFAULT 0,

    CONSTRAINT FK_answer_options_question FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);
GO

CREATE TABLE quiz_attempts (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    student_id      INT             NOT NULL,
    quiz_id         INT             NOT NULL,
    score           DECIMAL(5,2)    NULL,
    is_passed       BIT             NULL,
    submitted_at    DATETIME2       NOT NULL CONSTRAINT DF_quiz_attempts_submitted_at DEFAULT SYSDATETIME(),

    CONSTRAINT FK_quiz_attempts_student FOREIGN KEY (student_id) REFERENCES users(id),
    CONSTRAINT FK_quiz_attempts_quiz    FOREIGN KEY (quiz_id)    REFERENCES quizzes(id)
);
GO

CREATE TABLE attempt_answers (
    id                      INT IDENTITY(1,1) PRIMARY KEY,
    attempt_id              INT NOT NULL,
    question_id             INT NOT NULL,
    selected_option_id      INT NOT NULL,

    CONSTRAINT FK_attempt_answers_attempt  FOREIGN KEY (attempt_id)         REFERENCES quiz_attempts(id) ON DELETE CASCADE,
    CONSTRAINT FK_attempt_answers_question FOREIGN KEY (question_id)        REFERENCES questions(id),
    CONSTRAINT FK_attempt_answers_option   FOREIGN KEY (selected_option_id) REFERENCES answer_options(id)
);
GO

/* 
   5. NHÓM CHỨNG CHỈ & ĐÁNH GIÁ
    */

CREATE TABLE certificates (
    id                  INT IDENTITY(1,1) PRIMARY KEY,
    student_id          INT             NOT NULL,
    course_id           INT             NOT NULL,
    certificate_code    VARCHAR(50)     NOT NULL UNIQUE,
    issued_at           DATETIME2       NOT NULL CONSTRAINT DF_certificates_issued_at DEFAULT SYSDATETIME(),

    CONSTRAINT FK_certificates_student FOREIGN KEY (student_id) REFERENCES users(id),
    CONSTRAINT FK_certificates_course  FOREIGN KEY (course_id)  REFERENCES courses(id),
    CONSTRAINT UQ_certificates_student_course UNIQUE (student_id, course_id)
);
GO

CREATE TABLE reviews (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    student_id      INT             NOT NULL,
    course_id       INT             NOT NULL,
    rating          TINYINT         NOT NULL CONSTRAINT CK_reviews_rating CHECK (rating BETWEEN 1 AND 5),
    comment         NVARCHAR(MAX)   NULL,
    created_at      DATETIME2       NOT NULL CONSTRAINT DF_reviews_created_at DEFAULT SYSDATETIME(),

    CONSTRAINT FK_reviews_student FOREIGN KEY (student_id) REFERENCES users(id),
    CONSTRAINT FK_reviews_course  FOREIGN KEY (course_id)  REFERENCES courses(id),
    CONSTRAINT UQ_reviews_student_course UNIQUE (student_id, course_id)
);
GO

/* 
   6. INDEX GỢI Ý (tối ưu truy vấn thường dùng)
    */

CREATE INDEX idx_courses_status    ON courses(status);
CREATE INDEX idx_courses_category  ON courses(category_id);
CREATE INDEX idx_courses_instructor ON courses(instructor_id);
CREATE INDEX idx_enrollments_student ON enrollments(student_id);
CREATE INDEX idx_enrollments_course  ON enrollments(course_id);
CREATE INDEX idx_lesson_progress_enrollment ON lesson_progress(enrollment_id);
GO

/* 
   PHẦN A. FUNCTIONS
    */

-- ---------------------------------------------------------
-- A1. fn_calculate_progress
-- Tính % tiến độ học của 1 enrollment (dựa trên số bài đã
-- hoàn thành / tổng số bài học của khóa học đó)
-- ---------------------------------------------------------
GO
CREATE FUNCTION dbo.fn_calculate_progress (@enrollment_id INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @course_id       INT;
    DECLARE @total_lessons   INT;
    DECLARE @completed_lessons INT;
    DECLARE @result          DECIMAL(5,2);

    SELECT @course_id = course_id FROM enrollments WHERE id = @enrollment_id;

    SELECT @total_lessons = COUNT(*)
    FROM lessons l
    INNER JOIN sections s ON l.section_id = s.id
    WHERE s.course_id = @course_id;

    SELECT @completed_lessons = COUNT(*)
    FROM lesson_progress
    WHERE enrollment_id = @enrollment_id AND is_completed = 1;

    IF @total_lessons IS NULL OR @total_lessons = 0
        SET @result = 0;
    ELSE
        SET @result = (CAST(@completed_lessons AS DECIMAL(10,2)) / @total_lessons) * 100;

    RETURN @result;
END
GO

-- ---------------------------------------------------------
-- A2. fn_generate_certificate_code
-- Sinh mã chứng chỉ duy nhất theo pattern:
-- CERT-{course_id}-{student_id}-{yyyyMMddHHmmss}
-- ---------------------------------------------------------
CREATE FUNCTION dbo.fn_generate_certificate_code (@student_id INT, @course_id INT)
RETURNS VARCHAR(50)
AS
BEGIN
    RETURN CONCAT('CERT-', @course_id, '-', @student_id, '-', FORMAT(SYSDATETIME(), 'yyyyMMddHHmmss'));
END
GO


/* 
   PHẦN B. TRIGGERS
    */

-- ---------------------------------------------------------
-- B1. trg_lesson_progress_update
-- Khi 1 bài học được đánh dấu hoàn thành/hủy hoàn thành
-- (INSERT hoặc UPDATE trên lesson_progress) => tự tính lại
-- progress_percent của enrollment tương ứng. Nếu đạt 100%
-- thì set status = 'completed' và completed_at = NOW().
-- ---------------------------------------------------------
CREATE TRIGGER trg_lesson_progress_update
ON lesson_progress
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @enrollment_id INT;

    DECLARE cur CURSOR FOR
        SELECT DISTINCT enrollment_id FROM inserted;

    OPEN cur;
    FETCH NEXT FROM cur INTO @enrollment_id;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @new_progress DECIMAL(5,2);
        SET @new_progress = dbo.fn_calculate_progress(@enrollment_id);

        UPDATE enrollments
        SET progress_percent = @new_progress,
            status = CASE WHEN @new_progress >= 100 THEN 'completed' ELSE 'in_progress' END,
            completed_at = CASE WHEN @new_progress >= 100 AND completed_at IS NULL THEN SYSDATETIME() ELSE completed_at END
        WHERE id = @enrollment_id;

        FETCH NEXT FROM cur INTO @enrollment_id;
    END

    CLOSE cur;
    DEALLOCATE cur;
END
GO

-- ---------------------------------------------------------
-- B2. trg_enrollment_update_total_students
-- Khi có ghi danh mới / hủy ghi danh => cập nhật
-- total_students của khóa học tương ứng
-- ---------------------------------------------------------
CREATE TRIGGER trg_enrollment_update_total_students
ON enrollments
AFTER INSERT, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @course_id INT;

    DECLARE cur CURSOR FOR
        SELECT course_id FROM inserted
        UNION
        SELECT course_id FROM deleted;

    OPEN cur;
    FETCH NEXT FROM cur INTO @course_id;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE courses
        SET total_students = (SELECT COUNT(*) FROM enrollments WHERE course_id = @course_id)
        WHERE id = @course_id;

        FETCH NEXT FROM cur INTO @course_id;
    END

    CLOSE cur;
    DEALLOCATE cur;
END
GO

-- ---------------------------------------------------------
-- B3. trg_lesson_update_total_lessons
-- Khi thêm/xóa bài học => cập nhật total_lessons của
-- khóa học tương ứng (join qua sections)
-- ---------------------------------------------------------
CREATE TRIGGER trg_lesson_update_total_lessons
ON lessons
AFTER INSERT, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @course_id INT;

    DECLARE cur CURSOR FOR
        SELECT s.course_id FROM inserted i INNER JOIN sections s ON i.section_id = s.id
        UNION
        SELECT s.course_id FROM deleted d INNER JOIN sections s ON d.section_id = s.id;

    OPEN cur;
    FETCH NEXT FROM cur INTO @course_id;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE courses
        SET total_lessons = (
            SELECT COUNT(*)
            FROM lessons l
            INNER JOIN sections s ON l.section_id = s.id
            WHERE s.course_id = @course_id
        )
        WHERE id = @course_id;

        FETCH NEXT FROM cur INTO @course_id;
    END

    CLOSE cur;
    DEALLOCATE cur;
END
GO

ALTER TABLE quizzes ADD max_attempts INT NULL;

-- Bước 1: Xóa giới hạn cũ
-- (Nếu SQL báo lỗi không tìm thấy tên 'CHK_course_status', bạn hãy xem tên đúng của constraint trong mục Keys/Constraints của bảng courses để thay thế)
ALTER TABLE courses DROP CONSTRAINT CK_courses_status;
GO
-- Bước 2: Tạo giới hạn mới cho phép 'warning'
ALTER TABLE courses ADD CONSTRAINT CK_courses_status
CHECK (status IN ('draft', 'published', 'warning', 'rejected'));
GO

ALTER TABLE courses ADD appeal_message NVARCHAR(500) NULL;
GO
ALTER TABLE courses DROP CONSTRAINT CK_courses_status;
GO
ALTER TABLE courses ADD CONSTRAINT CK_courses_status 
CHECK (status IN ('draft', 'published', 'warning', 'appealed'));
GO