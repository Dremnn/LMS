package com.lms.util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class VideoUtil {

    // Nhận diện và trích xuất Video ID từ nhiều dạng link YouTube khác nhau:
    // - https://www.youtube.com/watch?v=VIDEO_ID
    // - https://youtu.be/VIDEO_ID
    // - https://www.youtube.com/embed/VIDEO_ID (đã đúng dạng embed sẵn)
    private static final Pattern YOUTUBE_PATTERN = Pattern.compile(
        "(?:youtube\\.com/watch\\?v=|youtu\\.be/|youtube\\.com/embed/)([a-zA-Z0-9_-]{11})"
    );

    // Trả về URL dạng embed nếu link là YouTube, hoặc null nếu không phải (VD: link .mp4 thật)
    public static String getYouTubeEmbedUrl(String url) {
        if (url == null || url.trim().isEmpty()) {
            return null;
        }

        Matcher matcher = YOUTUBE_PATTERN.matcher(url);
        if (matcher.find()) {
            String videoId = matcher.group(1);
            return "https://www.youtube.com/embed/" + videoId;
        }

        return null; // Không phải link YouTube
    }
}