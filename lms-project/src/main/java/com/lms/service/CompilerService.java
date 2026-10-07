package com.lms.service;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

public class CompilerService {
    
    private static final String WANDBOX_API_URL = "https://wandbox.org/api/compile.json";
    private static final Gson gson = new Gson();

    private static final Map<String, String> COMPILER_MAP = new HashMap<>();
    static {
        COMPILER_MAP.put("java", "openjdk-jdk-21+35");
        COMPILER_MAP.put("python", "cpython-3.12.7");
        COMPILER_MAP.put("cpp", "gcc-head");
        COMPILER_MAP.put("c", "gcc-head-c");
        COMPILER_MAP.put("javascript", "nodejs-20.17.0");
        COMPILER_MAP.put("typescript", "typescript-5.6.2");
        COMPILER_MAP.put("go", "go-1.23.2");
        COMPILER_MAP.put("php", "php-8.3.12");
        COMPILER_MAP.put("rust", "rust-1.82.0");
        COMPILER_MAP.put("csharp", "mono-6.12.0.199");
        COMPILER_MAP.put("ruby", "ruby-4.0.2");
        COMPILER_MAP.put("sql", "sqlite-3.46.1");
    }

    public static CompilerResult executeCode(String language, String code, String stdin) {
        CompilerResult result = new CompilerResult();
        try {
            String lang = language == null ? "java" : language.trim().toLowerCase();
            String compiler = COMPILER_MAP.getOrDefault(lang, "gcc-head");

            // Fix Java public class naming restriction on Wandbox (prog.java)
            if ("java".equals(lang) && code != null) {
                code = code.replaceAll("public\\s+class\\s+", "class ");
            }

            URL url = new URL(WANDBOX_API_URL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("User-Agent", "Mozilla/5.0 LMS-Compiler");
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(20000);
            conn.setDoOutput(true);

            JsonObject payload = new JsonObject();
            payload.addProperty("compiler", compiler);
            payload.addProperty("code", code);
            if (stdin != null && !stdin.isEmpty()) {
                payload.addProperty("stdin", stdin);
            }

            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = gson.toJson(payload).getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }

            int codeResp = conn.getResponseCode();
            BufferedReader br = new BufferedReader(
                new InputStreamReader(codeResp >= 200 && codeResp < 300 ? conn.getInputStream() : conn.getErrorStream(), StandardCharsets.UTF_8)
            );
            
            StringBuilder response = new StringBuilder();
            String responseLine;
            while ((responseLine = br.readLine()) != null) {
                response.append(responseLine).append("\n");
            }

            JsonObject jsonResp = gson.fromJson(response.toString(), JsonObject.class);
            
            StringBuilder outputBuilder = new StringBuilder();
            boolean hasCompileError = false;

            if (jsonResp.has("compiler_error") && !jsonResp.get("compiler_error").isJsonNull()) {
                String cErr = jsonResp.get("compiler_error").getAsString().trim();
                if (!cErr.isEmpty()) {
                    outputBuilder.append("[Lỗi Biên Dịch / Syntax Error]:\n").append(cErr).append("\n");
                    hasCompileError = true;
                }
            }

            if (jsonResp.has("program_error") && !jsonResp.get("program_error").isJsonNull()) {
                String pErr = jsonResp.get("program_error").getAsString().trim();
                if (!pErr.isEmpty()) {
                    outputBuilder.append("[Runtime Error]:\n").append(pErr).append("\n");
                }
            }

            if (jsonResp.has("program_output") && !jsonResp.get("program_output").isJsonNull()) {
                outputBuilder.append(jsonResp.get("program_output").getAsString());
            }

            String finalOutput = outputBuilder.toString();
            if (finalOutput.isEmpty()) {
                finalOutput = "Chương trình thực thi thành công nhưng không có kết quả in ra màn hình (Output rỗng).";
            }

            result.setSuccess(!hasCompileError);
            result.setOutput(finalOutput);

        } catch (Exception e) {
            result.setSuccess(false);
            result.setOutput("Lỗi kết nối tới máy chủ biên dịch: " + e.getMessage());
            e.printStackTrace();
        }
        return result;
    }

    public static class CompilerResult {
        private boolean success;
        private String output;
        
        public CompilerResult() {}
        public CompilerResult(boolean success, String output) {
            this.success = success;
            this.output = output;
        }

        public boolean isSuccess() { return success; }
        public void setSuccess(boolean success) { this.success = success; }
        public String getOutput() { return output; }
        public void setOutput(String output) { this.output = output; }
    }
}