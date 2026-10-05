package com.lms.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Controller cho các trang thông tin khám phá công cộng tại Footer:
 * - /instructors: Đội ngũ Giảng viên tiêu biểu
 * - /learning-paths: Lộ trình học tập nghề nghiệp
 * - /resources: Thư viện tài liệu & mã nguồn mở
 */
@WebServlet(urlPatterns = {"/instructors", "/learning-paths", "/resources"})
public class ExploreServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public static class InstructorItem implements Serializable {
        private static final long serialVersionUID = 1L;
        private int id;
        private String name;
        private String title;
        private String specialty;
        private String org;
        private String bio;
        private double rating;
        private String reviews;
        private String students;
        private int coursesCount;
        private List<String> skills;
        private String avatarBg;
        private String initials;
        private String courseUrl;
        private String chatContactId;

        public InstructorItem(int id, String name, String title, String specialty, String org,
                              String bio, double rating, String reviews, String students,
                              int coursesCount, List<String> skills, String avatarBg,
                              String courseUrl, String chatContactId) {
            this.id = id;
            this.name = name;
            this.title = title;
            this.specialty = specialty;
            this.org = org;
            this.bio = bio;
            this.rating = rating;
            this.reviews = reviews;
            this.students = students;
            this.coursesCount = coursesCount;
            this.skills = skills;
            this.avatarBg = avatarBg;
            this.courseUrl = courseUrl;
            this.chatContactId = chatContactId;
            this.initials = calculateInitials(name);
        }

        private String calculateInitials(String fullName) {
            if (fullName == null || fullName.trim().isEmpty()) return "GV";
            String[] parts = fullName.trim().split("\\s+");
            if (parts.length == 1) return parts[0].substring(0, Math.min(2, parts[0].length())).toUpperCase();
            return (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1)).toUpperCase();
        }

        public int getId() { return id; }
        public String getName() { return name; }
        public String getTitle() { return title; }
        public String getSpecialty() { return specialty; }
        public String getOrg() { return org; }
        public String getBio() { return bio; }
        public double getRating() { return rating; }
        public String getReviews() { return reviews; }
        public String getStudents() { return students; }
        public int getCoursesCount() { return coursesCount; }
        public List<String> getSkills() { return skills; }
        public String getAvatarBg() { return avatarBg; }
        public String getInitials() { return initials; }
        public String getCourseUrl() { return courseUrl; }
        public String getChatContactId() { return chatContactId; }
    }

    public static class PathwayItem implements Serializable {
        private static final long serialVersionUID = 1L;
        private String id;
        private String title;
        private String category;
        private String duration;
        private String level;
        private String salaryRange;
        private String description;
        private String icon;
        private String color;
        private List<String> targetRoles;
        private List<PhaseItem> phases;
        private String courseQuery;

        public PathwayItem(String id, String title, String category, String duration, String level,
                           String salaryRange, String description, String icon, String color,
                           List<String> targetRoles, List<PhaseItem> phases, String courseQuery) {
            this.id = id;
            this.title = title;
            this.category = category;
            this.duration = duration;
            this.level = level;
            this.salaryRange = salaryRange;
            this.description = description;
            this.icon = icon;
            this.color = color;
            this.targetRoles = targetRoles;
            this.phases = phases;
            this.courseQuery = courseQuery;
        }

        public String getId() { return id; }
        public String getTitle() { return title; }
        public String getCategory() { return category; }
        public String getDuration() { return duration; }
        public String getLevel() { return level; }
        public String getSalaryRange() { return salaryRange; }
        public String getDescription() { return description; }
        public String getIcon() { return icon; }
        public String getColor() { return color; }
        public List<String> getTargetRoles() { return targetRoles; }
        public List<PhaseItem> getPhases() { return phases; }
        public String getCourseQuery() { return courseQuery; }
    }

    public static class PhaseItem implements Serializable {
        private static final long serialVersionUID = 1L;
        private String phaseName;
        private String timeEstimate;
        private String summary;
        private List<String> skills;

        public PhaseItem(String phaseName, String timeEstimate, String summary, List<String> skills) {
            this.phaseName = phaseName;
            this.timeEstimate = timeEstimate;
            this.summary = summary;
            this.skills = skills;
        }

        public String getPhaseName() { return phaseName; }
        public String getTimeEstimate() { return timeEstimate; }
        public String getSummary() { return summary; }
        public List<String> getSkills() { return skills; }
    }

    public static class ResourceItem implements Serializable {
        private static final long serialVersionUID = 1L;
        private String id;
        private String title;
        private String category;
        private String format;
        private String formatColor;
        private String icon;
        private String size;
        private int pagesOrItems;
        private String pagesLabel;
        private String downloads;
        private String author;
        private String description;
        private String level;

        public ResourceItem(String id, String title, String category, String format, String formatColor,
                            String icon, String size, int pagesOrItems, String pagesLabel,
                            String downloads, String author, String description, String level) {
            this.id = id;
            this.title = title;
            this.category = category;
            this.format = format;
            this.formatColor = formatColor;
            this.icon = icon;
            this.size = size;
            this.pagesOrItems = pagesOrItems;
            this.pagesLabel = pagesLabel;
            this.downloads = downloads;
            this.author = author;
            this.description = description;
            this.level = level;
        }

        public String getId() { return id; }
        public String getTitle() { return title; }
        public String getCategory() { return category; }
        public String getFormat() { return format; }
        public String getFormatColor() { return formatColor; }
        public String getIcon() { return icon; }
        public String getSize() { return size; }
        public int getPagesOrItems() { return pagesOrItems; }
        public String getPagesLabel() { return pagesLabel; }
        public String getDownloads() { return downloads; }
        public String getAuthor() { return author; }
        public String getDescription() { return description; }
        public String getLevel() { return level; }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if ("/instructors".equals(path)) {
            handleInstructors(request, response);
        } else if ("/learning-paths".equals(path)) {
            handleLearningPaths(request, response);
        } else if ("/resources".equals(path)) {
            handleResources(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/");
        }
    }

    private void handleInstructors(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<InstructorItem> instructors = new ArrayList<>();

        // 1. Thầy Khổng Đình Tú
        instructors.add(new InstructorItem(
                4,
                "Khổng Đình Tú",
                "Principal Software Architect & Tech Lead",
                "Kiến trúc Hệ thống & Java Enterprise",
                "Khoa Công nghệ Phần mềm · Cựu Trưởng nhóm Kỹ thuật FinTech",
                "Hơn 10 năm kinh nghiệm nghiên cứu và phát triển hệ thống lõi ngân hàng, kiến trúc Microservices và cơ sở dữ liệu phân tán quy mô hàng triệu giao dịch. Đam mê truyền cảm hứng tư duy lập trình chuyên nghiệp và clean architecture.",
                4.95,
                "420+ đánh giá",
                "6,850+",
                5,
                Arrays.asList("Java 21", "Spring Boot 3", "Microservices", "Kafka", "Docker", "PostgreSQL", "Clean Architecture"),
                "linear-gradient(135deg, #093C62, #076FA4)",
                "courses?keyword=Java",
                "4"
        ));

        // 2. Thầy Đoàn Trọng Trung
        instructors.add(new InstructorItem(
                201,
                "Đoàn Trọng Trung",
                "Head of AI Research & Lead Machine Learning Engineer",
                "Trí tuệ Nhân tạo & LLM Autonomous Systems",
                "Phòng Thí nghiệm AI UTEdu · Thạc sĩ Khoa học Máy tính",
                "Chuyên gia hàng đầu trong nghiên cứu mô hình ngôn ngữ lớn (LLMs), kỹ thuật RAG (Retrieval-Augmented Generation) và xây dựng đàn Agent tự hành. Tác giả nhiều công trình nghiên cứu và tài liệu chuyển giao công nghệ cho doanh nghiệp.",
                4.92,
                "385+ đánh giá",
                "5,420+",
                4,
                Arrays.asList("Python", "PyTorch", "Generative AI", "RAG & Vector DB", "LangGraph", "ChromaDB", "Prompt Engineering"),
                "linear-gradient(135deg, #076FA4, #10B981)",
                "courses?keyword=AI",
                "4"
        ));

        // 3. Thầy Võ Mạnh Đức Tín
        instructors.add(new InstructorItem(
                202,
                "Võ Mạnh Đức Tín",
                "Senior Cloud Solutions Architect & DevSecOps Lead",
                "Điện toán Đám mây AWS & Kubernetes",
                "Chuyên gia Giải pháp Đám mây Doanh nghiệp · AWS Pro & CKA",
                "Sở hữu các chứng chỉ danh giá nhất về Cloud và hạ tầng phân tán. Hơn 8 năm kinh nghiệm thực chiến tư vấn kiến trúc đám mây có tính sẵn sàng cao (High Availability), tự động hóa CI/CD và bảo mật hệ thống toàn diện.",
                4.89,
                "315+ đánh giá",
                "4,280+",
                4,
                Arrays.asList("AWS Cloud", "Kubernetes (K8s)", "Docker", "Terraform (IaC)", "CI/CD Actions", "DevSecOps", "Linux"),
                "linear-gradient(135deg, #093C62, #D97706)",
                "courses?keyword=Cloud",
                "4"
        ));

        // 4. Thầy Nguyễn Minh Thành
        instructors.add(new InstructorItem(
                203,
                "Nguyễn Minh Thành",
                "Staff Data Engineer & Big Data Architect",
                "Kỹ nghệ Dữ liệu Lớn & Tối ưu Database",
                "Kiến trúc sư Dữ liệu Doanh nghiệp · Ban Chuyên môn UTEdu",
                "Chuyên sâu trong việc xây dựng hệ thống xử lý dữ liệu lớn theo thời gian thực (Real-time Stream Processing), thiết kế Data Lakehouse và tinh chỉnh hiệu năng cơ sở dữ liệu quan hệ đạt đỉnh cao tốc độ.",
                4.93,
                "290+ đánh giá",
                "3,950+",
                3,
                Arrays.asList("Advanced SQL", "Database Tuning", "Apache Spark", "Kafka", "Apache Airflow", "Snowflake", "Data Modeling"),
                "linear-gradient(135deg, #1E3A5F, #0284C7)",
                "courses?keyword=SQL",
                "4"
        ));

        request.setAttribute("instructors", instructors);
        request.getRequestDispatcher("/WEB-INF/views/explore/instructors.jsp").forward(request, response);
    }

    private void handleLearningPaths(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<PathwayItem> pathways = new ArrayList<>();

        // 1. Fullstack Enterprise Developer
        pathways.add(new PathwayItem(
                "fullstack",
                "Fullstack Enterprise Developer",
                "Lập trình Phần mềm",
                "6 - 8 tháng",
                "Cơ bản đến Chuyên sâu",
                "$900 - $2,200+",
                "Chương trình đào tạo toàn diện từ nền tảng Java Core vững chắc, xây dựng web đa tầng với Servlet/JSP, phát triển RESTful Microservices với Spring Boot 3 và làm chủ giao diện hiện đại cùng React/Next.js.",
                "fa-laptop-code",
                "#076FA4",
                Arrays.asList("Java Backend Developer", "Fullstack Engineer", "Enterprise Software Engineer"),
                Arrays.asList(
                        new PhaseItem("Giai đoạn 1: Nền tảng Java Core & OOP", "6 tuần", "Tư duy hướng đối tượng nâng cao, cấu trúc dữ liệu Collections, đa luồng (Multi-threading) và xử lý ngoại lệ chuẩn doanh nghiệp.", Arrays.asList("Java 21", "OOP Principles", "Design Patterns")),
                        new PhaseItem("Giai đoạn 2: Enterprise Web MVC & Cơ sở dữ liệu", "6 tuần", "Mô hình MVC chuẩn, Servlet & JSP, kết nối CSDL với JDBC & JPA/Hibernate, bảo mật phiên làm việc và transaction.", Arrays.asList("Servlet/JSP", "PostgreSQL", "HikariCP", "JPA")),
                        new PhaseItem("Giai đoạn 3: Spring Boot 3 & RESTful Microservices", "8 tuần", "Xây dựng hệ sinh thái API bảo mật với Spring Security & JWT, kiến trúc hướng sự kiện với Apache Kafka, container hóa Docker.", Arrays.asList("Spring Boot 3", "Spring Security", "JWT", "Docker")),
                        new PhaseItem("Giai đoạn 4: Đồ án Capstone & Triển khai Thực chiến", "4 tuần", "Tích hợp giao diện React, đóng gói CI/CD tự động và triển khai lên hạ tầng đám mây có giám sát.", Arrays.asList("React", "CI/CD", "AWS Deployment", "System Monitoring"))
                ),
                "courses?keyword=Java"
        ));

        // 2. AI & Machine Learning Engineer
        pathways.add(new PathwayItem(
                "ai-ml",
                "AI Engineer & Autonomous LLM Systems",
                "Trí tuệ Nhân tạo",
                "7 - 9 tháng",
                "Trung cấp đến Chuyên sâu",
                "$1,200 - $3,000+",
                "Làm chủ làn sóng Generative AI từ nền tảng toán học, Deep Learning, kỹ thuật RAG (Retrieval-Augmented Generation) tìm kiếm vector và xây dựng đàn Agent tự hành ứng dụng thực tế.",
                "fa-brain",
                "#10B981",
                Arrays.asList("AI Engineer", "LLM Application Developer", "Machine Learning Specialist"),
                Arrays.asList(
                        new PhaseItem("Giai đoạn 1: Toán học AI & Python Nâng cao", "6 tuần", "Đại số tuyến tính, giải tích, xác suất thống kê cho AI; xử lý dữ liệu với NumPy, Pandas và trực quan hóa chuyên sâu.", Arrays.asList("Python 3.12", "NumPy", "Pandas", "Math for AI")),
                        new PhaseItem("Giai đoạn 2: Deep Learning & Mạng Nơ-ron Transformer", "8 tuần", "Xây dựng mạng nơ-ron với PyTorch, xử lý ngôn ngữ tự nhiên (NLP) và cơ chế Attention trong kiến trúc Transformer.", Arrays.asList("PyTorch", "Transformers", "Hugging Face", "NLP")),
                        new PhaseItem("Giai đoạn 3: RAG, Vector Database & Prompt Tuning", "8 tuần", "Hệ thống hỏi đáp tài liệu chuyên ngành với LangChain, LlamaIndex, ChromaDB/Pinecone và reranking văn bản.", Arrays.asList("RAG Architecture", "ChromaDB", "Prompt Engineering", "Embeddings")),
                        new PhaseItem("Giai đoạn 4: Hệ thống Multi-Agent Tự hành Thực tế", "6 tuần", "Phát triển đàn Agent phối hợp (LangGraph, AutoGen), công cụ tương tác (Tool-use) và kiểm thử chất lượng mô hình.", Arrays.asList("Multi-Agent", "LangGraph", "AI Safety", "Production Serving"))
                ),
                "courses?keyword=AI"
        ));

        // 3. Cloud DevOps & DevSecOps
        pathways.add(new PathwayItem(
                "devops",
                "Cloud Solutions & DevSecOps Lead",
                "Hạ tầng & Đám mây",
                "5 - 7 tháng",
                "Trung cấp",
                "$1,000 - $2,500+",
                "Chinh phục hạ tầng điện toán đám mây thế hệ mới: từ quản trị máy chủ Linux, container hóa với Docker, điều phối Kubernetes đến tự động hóa đường ống CI/CD và bảo mật DevSecOps.",
                "fa-cloud",
                "#F59E0B",
                Arrays.asList("DevOps Engineer", "Cloud Architect", "Site Reliability Engineer (SRE)"),
                Arrays.asList(
                        new PhaseItem("Giai đoạn 1: Quản trị Linux & Mạng Máy tính", "4 tuần", "Làm chủ dòng lệnh Linux, Bash shell scripting, cấu hình mạng TCP/IP, DNS, SSL/TLS và quản trị người dùng.", Arrays.asList("Linux Admin", "Bash Scripting", "Networking", "Security")),
                        new PhaseItem("Giai đoạn 2: Container hóa & Đường ống CI/CD", "6 tuần", "Tối ưu hóa Dockerfile, Docker Compose, tự động hóa build/test/deploy với GitHub Actions và Jenkins.", Arrays.asList("Docker", "GitHub Actions", "CI/CD Pipelines", "SonarQube")),
                        new PhaseItem("Giai đoạn 3: Điều phối Cụm Kubernetes (K8s)", "8 tuần", "Triển khai Pods, Deployments, Services, Ingress, Helm Charts, giám sát cụm với Prometheus & Grafana.", Arrays.asList("Kubernetes", "Helm", "Prometheus", "Grafana")),
                        new PhaseItem("Giai đoạn 4: Hạ tầng Đám mây AWS & DevSecOps", "6 tuần", "Hạ tầng như mã (Terraform), thiết kế mạng VPC bảo mật, quét lỗ hổng tự động và phục hồi sau sự cố.", Arrays.asList("AWS", "Terraform (IaC)", "DevSecOps", "Disaster Recovery"))
                ),
                "courses?keyword=Cloud"
        ));

        // 4. Data Engineering & Big Data Analytics
        pathways.add(new PathwayItem(
                "data-eng",
                "Data Engineering & Big Data Architect",
                "Dữ liệu Lớn",
                "6 - 8 tháng",
                "Trung cấp",
                "$1,100 - $2,600+",
                "Thiết kế và vận hành các luồng dữ liệu khổng lồ (Pipelines) từ hệ thống nguồn đến Data Warehouse/Lakehouse, tối ưu hóa truy vấn SQL chuyên sâu và xử lý dữ liệu phân tán.",
                "fa-database",
                "#6366F1",
                Arrays.asList("Data Engineer", "Big Data Developer", "Database Administrator (DBA)"),
                Arrays.asList(
                        new PhaseItem("Giai đoạn 1: SQL Chuyên sâu & Data Modeling", "6 tuần", "Window functions, tối ưu hóa Execution Plan, Indexing chuyên sâu, mô hình dữ liệu Star Schema & Snowflake.", Arrays.asList("Advanced SQL", "Indexing", "Query Tuning", "Data Modeling")),
                        new PhaseItem("Giai đoạn 2: Xây dựng Đường ống ETL/ELT", "6 tuần", "Trích xuất, làm sạch và nạp dữ liệu tự động với Python và lập lịch điều phối Apache Airflow.", Arrays.asList("Python ETL", "Apache Airflow", "Data Cleaning", "Automation")),
                        new PhaseItem("Giai đoạn 3: Xử lý Phân tán với Spark & Kafka", "8 tuần", "Xử lý dữ liệu luồng thời gian thực với Apache Kafka và tính toán cụm phân tán bằng Apache Spark.", Arrays.asList("Apache Spark", "Apache Kafka", "Stream Processing", "PySpark")),
                        new PhaseItem("Giai đoạn 4: Kiến trúc Data Lakehouse Đám mây", "6 tuần", "Tích hợp Snowflake, Databricks, BigQuery và quản trị bảo mật dữ liệu theo quy chuẩn doanh nghiệp.", Arrays.asList("Data Lakehouse", "Snowflake", "Databricks", "Data Governance"))
                ),
                "courses?keyword=SQL"
        ));

        request.setAttribute("pathways", pathways);
        request.getRequestDispatcher("/WEB-INF/views/explore/learning-paths.jsp").forward(request, response);
    }

    private void handleResources(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<ResourceItem> resources = new ArrayList<>();

        resources.add(new ResourceItem(
                "res-01",
                "Cẩm nang Java 21 & Spring Boot 3 Enterprise Full-Stack",
                "java",
                "PDF",
                "#EF4444",
                "fa-file-pdf",
                "15.4 MB",
                210,
                "trang",
                "4,850",
                "Ban Chuyên môn UTEdu",
                "Tài liệu toàn diện từ cú pháp hiện đại Java 21 (Virtual Threads, Pattern Matching), thiết kế REST APIs với Spring Boot 3 đến tối ưu hóa kết nối cơ sở dữ liệu.",
                "Tất cả trình độ"
        ));

        resources.add(new ResourceItem(
                "res-02",
                "Kiến trúc AI RAG & Autonomous Multi-Agent Systems Handbook",
                "ai",
                "PDF + CODE",
                "#10B981",
                "fa-brain",
                "28.6 MB",
                95,
                "trang & source code",
                "3,620",
                "Phòng Nghiên cứu AI UTEdu",
                "Hướng dẫn từng bước xây dựng hệ thống hỏi đáp dữ liệu chuyên biệt với vector search, LangChain, ChromaDB và đàn Agent tự hành phối hợp giải quyết tác vụ phức tạp.",
                "Trung cấp -> Nâng cao"
        ));

        resources.add(new ResourceItem(
                "res-03",
                "Sổ tay Tối ưu hóa Database & SQL Query Tuning Cheatsheet",
                "database",
                "PDF",
                "#0284C7",
                "fa-database",
                "8.2 MB",
                48,
                "trang tóm tắt",
                "5,240",
                "Thầy Nguyễn Minh Thành",
                "Tổng hợp 50 kỹ thuật tối ưu hóa câu lệnh SQL, phân tích Execution Plan, thiết kế chỉ mục (Index) thông minh và xử lý tắc nghẽn giao dịch trong PostgreSQL & SQL Server.",
                "Mọi lập trình viên"
        ));

        resources.add(new ResourceItem(
                "res-04",
                "Docker & Kubernetes Thực chiến từ Zero đến Production",
                "cloud",
                "EBOOK",
                "#F59E0B",
                "fa-cloud",
                "18.1 MB",
                142,
                "trang",
                "3,180",
                "Thầy Võ Mạnh Đức Tín",
                "Cẩm nang thực hành container hóa ứng dụng web, viết file Helm Chart, thiết lập cụm K8s đa node và tự động hóa triển khai không gián đoạn dịch vụ.",
                "Cơ bản -> Thực chiến"
        ));

        resources.add(new ResourceItem(
                "res-05",
                "Starter Kit Microservices Event-Driven với Spring Cloud & Kafka",
                "java",
                "ZIP CODE",
                "#8B5CF6",
                "fa-file-zipper",
                "34.8 MB",
                12,
                "modules mã nguồn",
                "4,110",
                "Thầy Khổng Đình Tú",
                "Mã nguồn khung chuẩn (Boilerplate) cho hệ thống Microservices: tích hợp sẵn API Gateway, Config Server, Eureka Service Discovery, Kafka Producer/Consumer và Docker Compose.",
                "Nâng cao"
        ));

        resources.add(new ResourceItem(
                "res-06",
                "Bộ 300 Câu hỏi Phỏng vấn Kỹ sư Phần mềm & System Design 2026",
                "career",
                "PDF",
                "#EC4899",
                "fa-file-lines",
                "12.0 MB",
                135,
                "câu hỏi có đáp án",
                "6,900",
                "Hội đồng Tuyển dụng UTEdu",
                "Tổng hợp câu hỏi phỏng vấn thuật toán, OOP, cấu trúc dữ liệu, hệ điều hành, cơ sở dữ liệu và 10 kịch bản thiết kế hệ thống phân tán được hỏi nhiều nhất tại các tập đoàn công nghệ.",
                "Chuẩn bị phỏng vấn"
        ));

        resources.add(new ResourceItem(
                "res-07",
                "Prompt Engineering & API Integration Guidebook for Developers",
                "ai",
                "PDF",
                "#14B8A6",
                "fa-wand-magic-sparkles",
                "6.8 MB",
                64,
                "trang",
                "2,940",
                "Thầy Đoàn Trọng Trung",
                "Các mẫu prompt chuẩn mực cho lập trình viên: sinh code, refactor mã nguồn, viết unit test tự động và tích hợp các mô hình LLM thông qua API bảo mật.",
                "Mọi lập trình viên"
        ));

        resources.add(new ResourceItem(
                "res-08",
                "Template Dự án Web Thương mại Điện tử Jakarta EE / Servlet JSP",
                "java",
                "ZIP CODE",
                "#64748B",
                "fa-file-code",
                "26.5 MB",
                1,
                "full project mã nguồn",
                "4,450",
                "Ban Giảng huấn UTEdu",
                "Mã nguồn hoàn chỉnh ứng dụng web thương mại điện tử viết bằng Servlet/JSP thuần, kết nối PostgreSQL, phân quyền người dùng, giỏ hàng, thanh toán và bảng điều khiển quản trị viên.",
                "Học viên thực hành"
        ));

        request.setAttribute("resources", resources);
        request.getRequestDispatcher("/WEB-INF/views/explore/resources.jsp").forward(request, response);
    }
}
