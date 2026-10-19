package com.lms.controller;

import com.lms.dao.CourseDAO;
import com.lms.dao.EnrollmentDAO;
import com.lms.dao.GroupSubmissionDAO;
import com.lms.dao.StudyGroupDAO;
import com.lms.dao.UserDAO;
import com.lms.model.Course;
import com.lms.model.GroupMember;
import com.lms.model.GroupSubmission;
import com.lms.model.StudyGroup;
import com.lms.model.User;
import com.lms.service.StudyGroupService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/instructor/groups")
public class InstructorGroupServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();
    private final StudyGroupDAO groupDAO = new StudyGroupDAO();
    private final StudyGroupService groupService = new StudyGroupService();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null || (!"instructor".equals(currentUser.getRole()) && !"admin".equals(currentUser.getRole()))) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String courseIdStr = req.getParameter("courseId");
        if (courseIdStr == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu courseId");
            return;
        }

        try {
            int courseId = Integer.parseInt(courseIdStr);
            Course course = courseDAO.findById(courseId);
            
            if (course == null || (course.getInstructorId() != currentUser.getId() && !"admin".equals(currentUser.getRole()))) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập khóa học này.");
                return;
            }

            List<StudyGroup> groups = groupDAO.getGroupsByCourse(courseId);
            Map<Integer, List<GroupMember>> groupMembersMap = new HashMap<>();
            Map<Integer, GroupSubmission> groupSubmissionsMap = new HashMap<>();
            GroupSubmissionDAO submissionDAO = new GroupSubmissionDAO();
            
            for (StudyGroup group : groups) {
                List<GroupMember> members = groupDAO.getMembersByGroup(group.getId());
                groupMembersMap.put(group.getId(), members);
                
                GroupSubmission submission = submissionDAO.getSubmissionByGroupAndAssignment(group.getId(), courseId);
                if (submission != null) {
                    groupSubmissionsMap.put(group.getId(), submission);
                }
            }

            // Thống kê học viên cho giao diện chia nhóm
            List<Integer> allStudentIds = enrollmentDAO.findStudentIdsByCourseOrSection(courseId);
            List<Integer> groupedStudentIds = groupDAO.getGroupedStudentIds(courseId);
            List<User> unassignedUsers = new ArrayList<>();
            for (Integer sid : allStudentIds) {
                if (!groupedStudentIds.contains(sid)) {
                    User u = userDAO.findById(sid);
                    if (u != null) {
                        unassignedUsers.add(u);
                    }
                }
            }

            req.setAttribute("course", course);
            req.setAttribute("groups", groups);
            req.setAttribute("groupMembersMap", groupMembersMap);
            req.setAttribute("groupSubmissionsMap", groupSubmissionsMap);
            req.setAttribute("totalStudentsCount", allStudentIds.size());
            req.setAttribute("groupedStudentsCount", groupedStudentIds.size());
            req.setAttribute("unassignedStudentsCount", unassignedUsers.size());
            req.setAttribute("unassignedUsers", unassignedUsers);

            req.getRequestDispatcher("/WEB-INF/views/instructor/group-manage.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "CourseId không hợp lệ");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null || (!"instructor".equals(currentUser.getRole()) && !"admin".equals(currentUser.getRole()))) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String action = req.getParameter("action");
        String courseIdStr = req.getParameter("courseId");

        try {
            int courseId = Integer.parseInt(courseIdStr);
            Course course = courseDAO.findById(courseId);

            if (course == null || (course.getInstructorId() != currentUser.getId() && !"admin".equals(currentUser.getRole()))) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thao tác trên khóa học này.");
                return;
            }

            if ("auto_divide".equals(action)) {
                int membersPerGroup = Integer.parseInt(req.getParameter("membersPerGroup"));
                int created = groupService.autoDivideGroups(courseId, membersPerGroup);
                if (created > 0) {
                    session.setAttribute("flashSuccess", "Đã chia ngẫu nhiên thành công " + created + " nhóm mới!");
                } else {
                    session.setAttribute("flashError", "Không thể chia nhóm: Tất cả học viên đã có nhóm hoặc khóa học chưa có học viên nào đăng ký.");
                }
            } else if ("create_group".equals(action)) {
                String groupName = req.getParameter("groupName");
                String maxMembersStr = req.getParameter("maxMembers");
                int maxMembers = (maxMembersStr != null && !maxMembersStr.isEmpty()) ? Integer.parseInt(maxMembersStr) : 5;
                if (groupName != null && !groupName.trim().isEmpty()) {
                    StudyGroup newGroup = new StudyGroup();
                    newGroup.setName(groupName.trim());
                    newGroup.setMaxMembers(maxMembers);
                    newGroup.setCourse(course);
                    if (groupDAO.createGroup(newGroup)) {
                        session.setAttribute("flashSuccess", "Đã tạo nhóm '" + newGroup.getName() + "' thành công!");
                    } else {
                        session.setAttribute("flashError", "Lỗi khi tạo nhóm mới.");
                    }
                } else {
                    session.setAttribute("flashError", "Tên nhóm không được để trống.");
                }
            } else if ("delete_group".equals(action)) {
                int groupId = Integer.parseInt(req.getParameter("groupId"));
                if (groupDAO.deleteGroup(groupId)) {
                    session.setAttribute("flashSuccess", "Đã xóa nhóm thành công!");
                } else {
                    session.setAttribute("flashError", "Lỗi khi xóa nhóm.");
                }
            } else if ("delete_all".equals(action)) {
                if (groupDAO.deleteAllGroupsByCourse(courseId)) {
                    session.setAttribute("flashSuccess", "Đã xóa toàn bộ nhóm học tập của khóa học để chia lại!");
                } else {
                    session.setAttribute("flashError", "Lỗi khi xóa các nhóm.");
                }
            } else if ("add_member".equals(action)) {
                int groupId = Integer.parseInt(req.getParameter("groupId"));
                int studentId = Integer.parseInt(req.getParameter("studentId"));
                String role = req.getParameter("role");
                if (role == null || role.isEmpty()) role = "MEMBER";

                User student = userDAO.findById(studentId);
                StudyGroup group = new StudyGroup();
                group.setId(groupId);

                if (student != null) {
                    GroupMember member = new GroupMember();
                    member.setStudyGroup(group);
                    member.setStudent(student);
                    member.setRole(role);
                    if (groupDAO.addGroupMember(member)) {
                        session.setAttribute("flashSuccess", "Đã thêm " + student.getFullName() + " vào nhóm!");
                    } else {
                        session.setAttribute("flashError", "Không thể thêm học viên vào nhóm (có thể học viên đã trong nhóm).");
                    }
                }
            } else if ("remove_member".equals(action)) {
                int groupId = Integer.parseInt(req.getParameter("groupId"));
                int studentId = Integer.parseInt(req.getParameter("studentId"));
                if (groupDAO.removeGroupMember(groupId, studentId)) {
                    session.setAttribute("flashSuccess", "Đã xóa thành viên khỏi nhóm.");
                } else {
                    session.setAttribute("flashError", "Lỗi khi xóa thành viên khỏi nhóm.");
                }
            } else if ("grade_submission".equals(action)) {
                int groupId = Integer.parseInt(req.getParameter("groupId"));
                double score = Double.parseDouble(req.getParameter("score"));
                String feedback = req.getParameter("feedback");

                GroupSubmissionDAO submissionDAO = new GroupSubmissionDAO();
                GroupSubmission submission = submissionDAO.getSubmissionByGroupAndAssignment(groupId, courseId);
                
                if (submission != null) {
                    submission.setScore(score);
                    submission.setFeedback(feedback);
                    if (submissionDAO.saveOrUpdate(submission)) {
                        session.setAttribute("flashSuccess", "Đã lưu điểm cho nhóm!");
                    } else {
                        session.setAttribute("flashError", "Lỗi khi lưu điểm vào DB.");
                    }
                } else {
                    session.setAttribute("flashError", "Nhóm này chưa nộp bài, không thể chấm điểm.");
                }
            }
        } catch (Exception e) {
            session.setAttribute("flashError", "Lỗi xử lý yêu cầu: " + e.getMessage());
        }
        
        resp.sendRedirect(req.getContextPath() + "/instructor/groups?courseId=" + courseIdStr);
    }
}
