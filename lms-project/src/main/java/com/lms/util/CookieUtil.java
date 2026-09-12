package com.lms.util;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class CookieUtil {

    /**
     * Tìm kiếm Cookie theo tên từ HttpServletRequest.
     */
    public static Cookie getCookie(HttpServletRequest request, String name) {
        if (request == null || name == null) {
            return null;
        }
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (name.equals(cookie.getName())) {
                    return cookie;
                }
            }
        }
        return null;
    }

    /**
     * Lấy giá trị chuỗi của Cookie theo tên. Trả về null nếu không tìm thấy.
     */
    public static String getCookieValue(HttpServletRequest request, String name) {
        Cookie cookie = getCookie(request, name);
        return (cookie != null) ? cookie.getValue() : null;
    }

    /**
     * Thêm một Cookie vào HttpServletResponse.
     * 
     * @param response       HttpServletResponse
     * @param name           Tên cookie
     * @param value          Giá trị cookie
     * @param maxAgeSeconds  Thời gian sống (giây). Ví dụ: 30 * 24 * 60 * 60 (30 ngày)
     * @param httpOnly       true để chặn JavaScript đọc cookie (bảo mật chống XSS)
     */
    public static void addCookie(HttpServletResponse response, String name, String value, int maxAgeSeconds, boolean httpOnly) {
        if (response == null || name == null) {
            return;
        }
        Cookie cookie = new Cookie(name, value != null ? value : "");
        cookie.setMaxAge(maxAgeSeconds);
        cookie.setPath("/");
        cookie.setHttpOnly(httpOnly);
        response.addCookie(cookie);
    }

    /**
     * Xóa một Cookie khỏi trình duyệt người dùng bằng cách đặt maxAge = 0.
     */
    public static void deleteCookie(HttpServletResponse response, String name) {
        if (response == null || name == null) {
            return;
        }
        Cookie cookie = new Cookie(name, "");
        cookie.setMaxAge(0);
        cookie.setPath("/");
        cookie.setHttpOnly(true);
        response.addCookie(cookie);
    }
}
