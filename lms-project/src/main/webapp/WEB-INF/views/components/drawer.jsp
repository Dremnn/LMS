<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lms.dao.EnrollmentDAO, com.lms.dao.CourseDAO, com.lms.model.Enrollment, com.lms.model.Course, java.util.List, java.util.ArrayList" %>
<%
    com.lms.model.User drawerUser = (com.lms.model.User) session.getAttribute("currentUser");
    List<Course> drawerCourses = null;
    if (drawerUser != null) {
        EnrollmentDAO drawerEnDAO = new EnrollmentDAO();
        CourseDAO drawerCourseDAO = new CourseDAO();
        List<Enrollment> drawerEns = drawerEnDAO.findByStudent(drawerUser.getId());
        drawerCourses = new ArrayList<>();
        for (Enrollment en : drawerEns) {
            Course c = drawerCourseDAO.findById(en.getCourseId());
            if (c != null) drawerCourses.add(c);
        }
    }
%>
<!-- ================= RIGHT DRAWER ================= -->
<div id="rightDrawer" class="right-drawer">
    <div class="drawer-header">
        <button class="drawer-close-btn" onclick="toggleDrawer()">&times;</button>
    </div>
    <div class="drawer-content">
        <h3 class="drawer-title">Recently accessed items</h3>
        <div class="recent-items-list">
            <% if (drawerCourses != null && !drawerCourses.isEmpty()) { 
                int count = 0;
                for (Course c : drawerCourses) { 
                    if (count >= 5) break;
                    count++;
            %>
            <a href="<%= request.getContextPath() %>/courses/detail?id=<%= c.getId() %>" class="recent-item">
                <div class="recent-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                </div>
                <div class="recent-info">
                    <div class="recent-name"><%= c.getTitle() %></div>
                    <div class="recent-course">Course ID: <%= c.getId() %></div>
                </div>
            </a>
            <% } } else { %>
                <p style="color: #666; font-size: 14px; text-align: center; margin-top: 20px;">Bạn chưa tham gia khóa học nào.</p>
            <% } %>

            <% if (drawerCourses != null && drawerCourses.size() > 5) { %>
                <a href="<%= request.getContextPath() %>/student/my-courses" style="text-decoration:none;"><button class="show-more-btn" style="width: 100%;">Xem thêm</button></a>
            <% } %>
        </div>
    </div>
</div>