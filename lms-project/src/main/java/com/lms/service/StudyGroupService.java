package com.lms.service;

import com.lms.dao.CourseDAO;
import com.lms.dao.EnrollmentDAO;
import com.lms.dao.StudyGroupDAO;
import com.lms.dao.UserDAO;
import com.lms.model.Course;
import com.lms.model.GroupMember;
import com.lms.model.StudyGroup;
import com.lms.model.User;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class StudyGroupService {
    
    private final StudyGroupDAO groupDAO = new StudyGroupDAO();
    private final EnrollmentDAO enrollmentDAO = new EnrollmentDAO();
    private final CourseDAO courseDAO = new CourseDAO();
    private final UserDAO userDAO = new UserDAO();

    /**
     * Tự động chia nhóm ngẫu nhiên cho những học viên chưa có nhóm.
     * @param courseId ID của khóa học
     * @param membersPerGroup Số lượng học viên mỗi nhóm (ví dụ: 5)
     * @return Số lượng nhóm mới vừa được tạo
     */
    public int autoDivideGroups(int courseId, int membersPerGroup) {
        if (membersPerGroup <= 0) return 0;

        // 1. Lấy tất cả sinh viên trong khóa học
        List<Integer> allStudentIds = enrollmentDAO.findStudentIdsByCourseOrSection(courseId);
        
        // 2. Lấy những sinh viên ĐÃ có nhóm trong khóa này
        List<Integer> groupedStudentIds = groupDAO.getGroupedStudentIds(courseId);
        
        // 3. Lọc ra những sinh viên CHƯA có nhóm
        List<Integer> unassignedStudents = new ArrayList<>();
        for (Integer id : allStudentIds) {
            if (!groupedStudentIds.contains(id)) {
                unassignedStudents.add(id);
            }
        }

        if (unassignedStudents.isEmpty()) {
            return 0; // Không có ai để chia nhóm
        }

        // 4. Trộn ngẫu nhiên danh sách (Randomize)
        Collections.shuffle(unassignedStudents);

        // 5. Tính toán số lượng nhóm cần tạo
        int totalUnassigned = unassignedStudents.size();
        int numGroups = (int) Math.ceil((double) totalUnassigned / membersPerGroup);

        Course course = courseDAO.findById(courseId);
        if (course == null) {
             // Fallback nếu không tìm thấy
             course = new Course();
             course.setId(courseId);
        }

        int currentGroupCount = groupDAO.getGroupsByCourse(courseId).size();
        int studentIndex = 0;
        int groupsCreated = 0;

        // 6. Phân bổ sinh viên vào nhóm
        for (int i = 0; i < numGroups; i++) {
            // Tạo nhóm mới
            StudyGroup newGroup = new StudyGroup();
            newGroup.setCourse(course);
            newGroup.setName("Nhóm " + (currentGroupCount + i + 1));
            newGroup.setMaxMembers(membersPerGroup);
            groupDAO.createGroup(newGroup);
            groupsCreated++;

            // Phân bổ sinh viên vào nhóm này
            // Chia đều nếu là nhóm cuối cùng thì gánh nốt số dư
            int membersToAssign = membersPerGroup;
            if (i == numGroups - 1) { // Nhóm cuối
                membersToAssign = totalUnassigned - studentIndex;
            }

            for (int j = 0; j < membersToAssign; j++) {
                if (studentIndex >= totalUnassigned) break;

                int studentId = unassignedStudents.get(studentIndex);
                User student = userDAO.findById(studentId);
                if (student == null) {
                    student = new User();
                    student.setId(studentId);
                }

                GroupMember member = new GroupMember();
                member.setStudyGroup(newGroup);
                member.setStudent(student);
                member.setRole(j == 0 ? "LEADER" : "MEMBER"); // Người đầu tiên làm nhóm trưởng
                
                groupDAO.addGroupMember(member);
                studentIndex++;
            }
        }

        return groupsCreated;
    }
}
