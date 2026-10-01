package com.lms.util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.io.InputStream;
import java.util.Properties;
import java.util.concurrent.CompletableFuture;

/**
 * Lớp tiện ích gửi Email theo chuẩn giáo trình Murach Chapter 14 (JavaMail API)
 * Hỗ trợ gửi Email bất đồng bộ (Async) và tự động bắt lỗi (Try-Catch) an toàn tuyệt đối.
 */
public class MailUtil {

    private static final Properties mailProps = new Properties();

    static {
        loadConfig();
    }

    private static void loadConfig() {
        try (InputStream is = MailUtil.class.getClassLoader().getResourceAsStream("email.properties")) {
            if (is != null) {
                mailProps.load(is);
            }
        } catch (Exception e) {
            System.err.println("===> [MailUtil] Không thể đọc file email.properties: " + e.getMessage());
        }
    }

    private static String getUsername() {
        String env = System.getenv("MAIL_USERNAME");
        return (env != null && !env.trim().isEmpty()) ? env : mailProps.getProperty("mail.username", "");
    }

    private static String getPassword() {
        String env = System.getenv("MAIL_PASSWORD");
        return (env != null && !env.trim().isEmpty()) ? env : mailProps.getProperty("mail.password", "");
    }

    private static String getFromAddress() {
        String env = System.getenv("MAIL_FROM");
        return (env != null && !env.trim().isEmpty()) ? env : mailProps.getProperty("mail.from", "noreply@utedu.edu.vn");
    }

    private static String getFromName() {
        return mailProps.getProperty("mail.from.name", "UTEdu LMS Support");
    }

    /**
     * Hàm gửi Email đồng bộ theo chuẩn Murach Chapter 14
     */
    public static void sendMail(String to, String subject, String body, boolean isBodyHtml) throws MessagingException {
        loadConfig();

        // 1. Lấy thông tin tài khoản SMTP từ email.properties hoặc biến môi trường
        String username = getUsername();
        String password = getPassword();

        // 2. Thiết lập Session Mail (Chuẩn Murach Chapter 14 slide 21-24)
        Properties props = new Properties();
        props.put("mail.transport.protocol", mailProps.getProperty("mail.transport.protocol", "smtp"));
        props.put("mail.smtp.host", mailProps.getProperty("mail.smtp.host", "smtp.gmail.com"));
        props.put("mail.smtp.port", mailProps.getProperty("mail.smtp.port", "587"));
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        props.put("mail.smtp.connectiontimeout", "5000");
        props.put("mail.smtp.timeout", "5000");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });

        // 3. Tạo đối tượng Message (MimeMessage)
        Message message = new MimeMessage(session);
        message.setSubject(subject);

        if (isBodyHtml) {
            message.setContent(body, "text/html; charset=UTF-8");
        } else {
            message.setText(body);
        }

        // 4. Thiết lập địa chỉ người gửi và người nhận (InternetAddress)
        try {
            message.setFrom(new InternetAddress(getFromAddress(), getFromName(), "UTF-8"));
            message.setRecipient(Message.RecipientType.TO, new InternetAddress(to));
        } catch (Exception e) {
            throw new MessagingException("Lỗi định dạng địa chỉ email: " + e.getMessage(), e);
        }

        // 5. Thực hiện gửi thư qua Transport (Chuẩn Murach Chapter 14 slide 35-38)
        Transport.send(message);
        System.out.println("===> [MailUtil] Đã gửi email thực tế thành công tới: " + to);
    }

    /**
     * Gửi Welcome Email BẤT ĐỒNG BỘ (Async) - KHÔNG chặn luồng HTTP, an toàn tuyệt đối bằng Try-Catch
     */
    public static void sendWelcomeEmailAsync(String toEmail, String fullName) {
        CompletableFuture.runAsync(() -> {
            try {
                String subject = "Chào mừng bạn đến với Nền tảng Học tập UTEdu LMS!";
                String htmlBody = buildWelcomeEmailTemplate(fullName, toEmail);
                sendMail(toEmail, subject, htmlBody, true);
            } catch (Exception e) {
                // Nuốt lỗi an toàn: in log để quản trị viên nắm bắt, không làm sập web
                System.err.println(">> [MailUtil] Bỏ qua gửi Welcome Email tới (" + toEmail + ") do lỗi hoặc email không tồn tại: " + e.getMessage());
            }
        });
    }

    /**
     * Template Email HTML chuyên nghiệp chuẩn thiết kế thương hiệu UTEdu LMS
     */
    private static String buildWelcomeEmailTemplate(String fullName, String email) {
        return "<!DOCTYPE html>"
                + "<html>"
                + "<head><meta charset='UTF-8'></head>"
                + "<body style='font-family: Arial, sans-serif; background-color: #F8FAFC; margin: 0; padding: 30px;'>"
                + "  <div style='max-width: 600px; margin: 0 auto; background: #FFFFFF; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border: 1px solid #E2E8F0;'>"
                + "    <div style='background: linear-gradient(135deg, #093C62, #076FA4); padding: 25px; text-align: center; color: #FFFFFF;'>"
                + "      <h1 style='margin: 0; font-size: 26px; font-weight: 700;'>UTEdu LMS</h1>"
                + "      <p style='margin: 5px 0 0 0; opacity: 0.9; font-size: 14px;'>Nền tảng Quản lý Học tập Trực tuyến</p>"
                + "    </div>"
                + "    <div style='padding: 30px; color: #1E293B; line-height: 1.6;'>"
                + "      <h2 style='color: #076FA4; margin-top: 0; font-size: 20px;'>Xin chào " + escapeHtml(fullName) + ",</h2>"
                + "      <p>Chúc mừng bạn đã đăng ký tài khoản thành công tại <strong>UTEdu LMS</strong>. Chúng tôi rất hân hạnh được đồng hành cùng bạn trên con đường nâng cao kiến thức công nghệ!</p>"
                + "      <div style='background: #F1F5F9; border-left: 4px solid #076FA4; padding: 15px; margin: 20px 0; border-radius: 4px;'>"
                + "        <p style='margin: 0 0 8px 0;'><strong>Thông tin tài khoản học tập:</strong></p>"
                + "        <p style='margin: 0;'>• Email đăng nhập: <strong style='color: #093C62;'>" + escapeHtml(email) + "</strong></p>"
                + "      </div>"
                + "      <p>Bạn có thể khám phá hàng trăm khóa học hấp dẫn, làm bài kiểm tra trắc nghiệm và thảo luận cùng các giảng viên ngay hôm nay.</p>"
                + "      <div style='text-align: center; margin: 35px 0;'>"
                + "        <a href='http://localhost:8080/lms-project/login' style='background: #076FA4; color: #FFFFFF; text-decoration: none; padding: 12px 30px; border-radius: 8px; font-weight: bold; font-size: 15px; display: inline-block;'>Bắt đầu học ngay</a>"
                + "      </div>"
                + "      <p style='font-size: 13px; color: #64748B;'>Nếu bạn không thực hiện yêu cầu đăng ký này, vui lòng bỏ qua email.</p>"
                + "    </div>"
                + "    <div style='background: #F8FAFC; padding: 20px; text-align: center; font-size: 12px; color: #94A3B8; border-top: 1px solid #E2E8F0;'>"
                + "      <p style='margin: 0;'>© 2026 UTEdu LMS - Đại học Sư phạm Kỹ thuật TP.HCM (HCMUTE)</p>"
                + "    </div>"
                + "  </div>"
                + "</body>"
                + "</html>";
    }

    private static String escapeHtml(String text) {
        if (text == null) return "";
        return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }

    // Hàm main để test nhanh gửi email từ dòng lệnh hoặc IDE
    public static void main(String[] args) {
        System.out.println("--- Đang thử nghiệm tính năng Welcome Email (Chapter 14) ---");
        sendWelcomeEmailAsync("test_student@gmail.com", "Nguyễn Văn Test");
        try {
            Thread.sleep(1500); // Chờ thread async hoàn thành
        } catch (InterruptedException ignored) {}
    }
}
