package com.lms.service;

import com.lms.dao.UserDAO;
import com.lms.model.User;
import com.lms.util.PasswordUtil;

import java.util.regex.Pattern;

public class AuthService {

    // Regex kiểm tra định dạng email hợp lệ
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
            "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$"
    );

    private final UserDAO userDAO;

    // Constructor: Khởi tạo UserDAO để thao tác dữ liệu
    public AuthService() {
        this.userDAO = new UserDAO();
    }

    // Constructor cho phép truyền UserDAO (thuận tiện nếu viết Unit Test sau này)
    public AuthService(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    // =========================================================================
    // 1. NGHIỆP VỤ ĐĂNG KÝ TÀI KHOẢN (Register)
    // =========================================================================
    public User register(String fullName, String email, String password, String confirmPassword, String role) {
        
        // 1. Kiểm tra không được để trống
        if (fullName == null || fullName.trim().isEmpty()) {
            throw new IllegalArgumentException("Họ và tên không được để trống!");
        }
        if (email == null || email.trim().isEmpty()) {
            throw new IllegalArgumentException("Email không được để trống!");
        }
        if (password == null || password.isEmpty()) {
            throw new IllegalArgumentException("Mật khẩu không được để trống!");
        }

        // Chuẩn hóa dữ liệu đầu vào
        fullName = fullName.trim();
        email = email.trim().toLowerCase();

        // 2. Kiểm tra định dạng email
        if (!EMAIL_PATTERN.matcher(email).matches()) {
            throw new IllegalArgumentException("Định dạng Email không hợp lệ!");
        }

        // 3. Kiểm tra độ dài mật khẩu (tối thiểu 6 ký tự)
        if (password.length() < 6) {
            throw new IllegalArgumentException("Mật khẩu phải có độ dài tối thiểu từ 6 ký tự trở lên!");
        }

        // 4. Kiểm tra xác nhận mật khẩu có khớp không
        if (!password.equals(confirmPassword)) {
            throw new IllegalArgumentException("Mật khẩu xác nhận không khớp!");
        }

        // 5. Kiểm tra role hợp lệ (mặc định cho phép student hoặc instructor)
        if (role == null || role.trim().isEmpty()) {
            role = "student";
        } else {
            role = role.trim().toLowerCase();
            if (!role.equals("student") && !role.equals("instructor")) {
                throw new IllegalArgumentException("Vai trò đăng ký không hợp lệ!");
            }
        }

        // 6. Kiểm tra email đã tồn tại trong Database chưa
        if (userDAO.existsByEmail(email)) {
            throw new IllegalArgumentException("Email '" + email + "' đã được sử dụng. Vui lòng chọn email khác!");
        }

        // 7. Mã hóa mật khẩu bằng BCrypt
        String passwordHash = PasswordUtil.hashPassword(password);

        // 8. Tạo đối tượng User và lưu vào Database
        // Status mặc định: student là 'active', instructor có thể để 'active' hoặc 'pending'
        String status = "active";
        User newUser = new User(fullName, email, passwordHash, role, status);

        boolean isSaved = userDAO.save(newUser);
        if (!isSaved) {
            throw new RuntimeException("Có lỗi xảy ra trong quá trình tạo tài khoản. Vui lòng thử lại sau!");
        }

        return newUser;
    }

    // =========================================================================
    // 2. NGHIỆP VỤ ĐĂNG NHẬP (Login)
    // =========================================================================
    public User login(String email, String password) {
        
        // 1. Kiểm tra đầu vào cơ bản
        if (email == null || email.trim().isEmpty() || password == null || password.isEmpty()) {
            throw new IllegalArgumentException("Vui lòng nhập đầy đủ Email và Mật khẩu!");
        }

        email = email.trim().toLowerCase();

        // 2. Tìm user theo email trong Database
        User user = userDAO.findByEmail(email);
        if (user == null) {
            // Nguyên tắc bảo mật: Không nói rõ là "Email sai" để tránh hacker dò tìm tài khoản có thật
            throw new IllegalArgumentException("Email hoặc mật khẩu không chính xác!");
        }

        // 3. Kiểm tra trạng thái tài khoản
        if ("locked".equalsIgnoreCase(user.getStatus())) {
            throw new IllegalStateException("Tài khoản của bạn đã bị khóa. Vui lòng liên hệ Admin!");
        }
        if ("pending".equalsIgnoreCase(user.getStatus())) {
            throw new IllegalStateException("Tài khoản của bạn đang chờ phê duyệt. Vui lòng quay lại sau!");
        }

        // 4. So khớp mật khẩu nhập vào với mật khẩu hash trong Database
        boolean isPasswordMatch = PasswordUtil.checkPassword(password, user.getPasswordHash());
        if (!isPasswordMatch) {
            throw new IllegalArgumentException("Email hoặc mật khẩu không chính xác!");
        }

        // 5. Đăng nhập thành công -> trả về đối tượng User để Servlet lưu vào Session
        return user;
    }
}