package com.lms.util;

import com.lms.model.FileData;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/** Trả file lưu trong DB về trình duyệt dưới dạng tải xuống (attachment). */
public final class FileDownloadUtil {

    private FileDownloadUtil() {}

    public static void send(HttpServletResponse response, FileData file) throws IOException {
        byte[] bytes = file.getBytes();
        String type = file.getType() != null ? file.getType() : "application/octet-stream";

        // Tên file có dấu tiếng Việt: dùng filename* (RFC 5987) + bản ASCII dự phòng cho trình duyệt cũ
        String encoded = URLEncoder.encode(file.getName(), StandardCharsets.UTF_8).replace("+", "%20");
        String asciiFallback = file.getName().replaceAll("[^\\x20-\\x7E]", "_").replace("\"", "_");

        response.setContentType(type);
        response.setContentLength(bytes.length);
        response.setHeader("Content-Disposition",
                "attachment; filename=\"" + asciiFallback + "\"; filename*=UTF-8''" + encoded);
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("Cache-Control", "private, no-store");
        response.getOutputStream().write(bytes);
    }
}
