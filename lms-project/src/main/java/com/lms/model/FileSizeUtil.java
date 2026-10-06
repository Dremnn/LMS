package com.lms.model;

/** Định dạng dung lượng file cho dễ đọc (VD: 1.5 MB). */
final class FileSizeUtil {
    private FileSizeUtil() {}

    static String format(long bytes) {
        if (bytes < 1024) return bytes + " B";
        if (bytes < 1024L * 1024) return String.format("%.1f KB", bytes / 1024.0);
        return String.format("%.1f MB", bytes / (1024.0 * 1024));
    }
}
