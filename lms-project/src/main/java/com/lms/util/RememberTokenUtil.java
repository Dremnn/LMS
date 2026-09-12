package com.lms.util;

import com.lms.model.User;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;

public class RememberTokenUtil {

    // Khóa bí mật máy chủ dùng để ký HMAC token
    private static final String SECRET_KEY = "LMS_SECRET_REMEMBER_TOKEN_KEY_2026_UTEDU";
    private static final String HMAC_ALGORITHM = "HmacSHA256";

    // Thời hạn token: 14 ngày (tính bằng mili-giây)
    public static final long TOKEN_VALIDITY_MS = 14L * 24 * 60 * 60 * 1000;
    // Thời hạn cookie: 14 ngày (tính bằng giây)
    public static final int TOKEN_COOKIE_MAX_AGE = 14 * 24 * 60 * 60;

    /**
     * Tạo token ghi nhớ đăng nhập an toàn:
     * Định dạng: Base64(userId:expiryTimestamp:signature)
     */
    public static String generateToken(User user) {
        if (user == null) {
            return null;
        }

        long expiryTime = System.currentTimeMillis() + TOKEN_VALIDITY_MS;
        String dataToSign = user.getId() + ":" + expiryTime + ":" + user.getPasswordHash();
        String signature = calculateHmac(dataToSign);

        String rawToken = user.getId() + ":" + expiryTime + ":" + signature;
        return Base64.getUrlEncoder().withoutPadding().encodeToString(rawToken.getBytes(StandardCharsets.UTF_8));
    }

    /**
     * Trích xuất userId từ token mà chưa cần validate chữ ký (dùng để tìm User từ DB trước).
     * Trả về -1 nếu token không hợp lệ về mặt cú pháp.
     */
    public static int getUserIdFromToken(String encodedToken) {
        if (encodedToken == null || encodedToken.trim().isEmpty()) {
            return -1;
        }

        try {
            byte[] decoded = Base64.getUrlDecoder().decode(encodedToken);
            String rawToken = new String(decoded, StandardCharsets.UTF_8);
            String[] parts = rawToken.split(":");
            if (parts.length == 3) {
                return Integer.parseInt(parts[0]);
            }
        } catch (Exception e) {
            // Token bị hỏng hoặc cố tình giả mạo
        }
        return -1;
    }

    /**
     * Xác thực token với thông tin người dùng lấy từ cơ sở dữ liệu.
     * Kiểm tra cả thời hạn và tính toàn vẹn của chữ ký HMAC.
     */
    public static boolean validateToken(String encodedToken, User user) {
        if (encodedToken == null || user == null || !"active".equalsIgnoreCase(user.getStatus())) {
            return false;
        }

        try {
            byte[] decoded = Base64.getUrlDecoder().decode(encodedToken);
            String rawToken = new String(decoded, StandardCharsets.UTF_8);
            String[] parts = rawToken.split(":");
            if (parts.length != 3) {
                return false;
            }

            int userId = Integer.parseInt(parts[0]);
            long expiryTime = Long.parseLong(parts[1]);
            String signature = parts[2];

            // 1. Kiểm tra ID người dùng
            if (userId != user.getId()) {
                return false;
            }

            // 2. Kiểm tra thời hạn token
            if (System.currentTimeMillis() > expiryTime) {
                return false;
            }

            // 3. Kiểm tra tính toàn vẹn chữ ký HMAC
            String expectedData = user.getId() + ":" + expiryTime + ":" + user.getPasswordHash();
            String expectedSignature = calculateHmac(expectedData);

            return signature.equals(expectedSignature);

        } catch (Exception e) {
            return false;
        }
    }

    private static String calculateHmac(String data) {
        try {
            Mac mac = Mac.getInstance(HMAC_ALGORITHM);
            SecretKeySpec secretKeySpec = new SecretKeySpec(SECRET_KEY.getBytes(StandardCharsets.UTF_8), HMAC_ALGORITHM);
            mac.init(secretKeySpec);
            byte[] rawHmac = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(rawHmac);
        } catch (NoSuchAlgorithmException | InvalidKeyException e) {
            throw new RuntimeException("Lỗi tính toán HMAC token", e);
        }
    }
}
