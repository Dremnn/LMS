package com.lms.model;

import java.io.Serializable;

/** Nội dung 1 file lưu trong DB (dùng cho download file đề bài / file bài nộp). */
public class FileData implements Serializable {
    private static final long serialVersionUID = 1L;

    private final String name;
    private final String type;
    private final byte[] bytes;

    public FileData(String name, String type, byte[] bytes) {
        this.name = name;
        this.type = type;
        this.bytes = bytes;
    }

    public String getName() { return name; }
    public String getType() { return type; }
    public byte[] getBytes() { return bytes; }
}
