package com.lms.util;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {

    // Độ phức tạp của thuật toán băm (mặc định là 10, đặt 12 để an toàn hơn)
    private static final int LOG_ROUNDS = 12;

    // 1. Hàm băm mật khẩu: Nhận mật khẩu gốc -> Trả về chuỗi hash an toàn
    // Dùng khi: Người dùng Đăng ký tài khoản mới hoặc Đổi mật khẩu
    public static String hashPassword(String plainPassword) {
        if (plainPassword == null || plainPassword.trim().isEmpty()) {
            throw new IllegalArgumentException("Mat khau khong duoc de trong!");
        }
        // BCrypt.gensalt(LOG_ROUNDS) sinh ra 1 chuỗi muối ngẫu nhiên với độ phức tạp 12
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(LOG_ROUNDS));
    }

    // 2. Hàm kiểm tra mật khẩu: So khớp mật khẩu người dùng nhập vào với chuỗi hash trong DB
    // Dùng khi: Người dùng Đăng nhập
    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        if (plainPassword == null || hashedPassword == null || hashedPassword.trim().isEmpty()) {
            return false;
        }
        try {
            // BCrypt sẽ tự động trích xuất Salt từ hashedPassword để so sánh
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (IllegalArgumentException e) {
            // Trường hợp chuỗi hash trong DB bị sai định dạng
            return false;
        }
    }

    // Hàm main để test nhanh cách hoạt động của BCrypt
    public static void main(String[] args) {
        String rawPass = "Trung1611@";

        // Băm mật khẩu 2 lần khác nhau
        String hash1 = hashPassword(rawPass);
        String hash2 = hashPassword(rawPass);

        System.out.println("Mat khau goc : " + rawPass);
        System.out.println("Hash lan 1   : " + hash1);
        System.out.println("Hash lan 2   : " + hash2);
        System.out.println("-> Hai chuoi hash khac nhau hoan toan (nho Salt ngau nhien)!");

        // Kiem tra thu dang nhap
        boolean isCorrect = checkPassword("Trung1611@", hash1);
        boolean isWrong   = checkPassword("MatKhauSai", hash1);

        System.out.println("\nTest dang nhap dung: " + isCorrect); // true
        System.out.println("Test dang nhap sai : " + isWrong);   // false
    }
}