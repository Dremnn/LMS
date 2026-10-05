package com.lms.util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.io.InputStream;
import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
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

    /**
     * Gửi Email xác nhận nạp tiền/chuyển khoản BẤT ĐỒNG BỘ (Async)
     * Đảm bảo không làm nghẽn luồng xử lý của người dùng, try-catch an toàn tuyệt đối.
     */
    public static void sendTransferConfirmationEmailAsync(String toEmail, String fullName, BigDecimal amount, String referenceCode, BigDecimal newBalance) {
        if (toEmail == null || toEmail.trim().isEmpty()) {
            return;
        }

        CompletableFuture.runAsync(() -> {
            try {
                String subject = "Xác nhận chuyển khoản nạp tiền thành công - UTEdu LMS";
                String htmlBody = buildTransferConfirmationEmailTemplate(fullName, toEmail, amount, referenceCode, newBalance);
                sendMail(toEmail, subject, htmlBody, true);
                System.out.println("===> [MailUtil] Đã gửi email xác nhận chuyển khoản thành công tới: " + toEmail);
            } catch (Exception e) {
                // Nuốt lỗi an toàn: in log để quản trị viên nắm bắt, không làm gián đoạn người dùng
                System.err.println(">> [MailUtil] Bỏ qua gửi Email xác nhận chuyển khoản tới (" + toEmail + ") do lỗi: " + e.getMessage());
            }
        });
    }

    /**
     * Template Email HTML xác nhận giao dịch chuyển khoản ngân hàng theo phong cách chuyên nghiệp UTEdu
     */
    private static String buildTransferConfirmationEmailTemplate(String fullName, String email, BigDecimal amount, String referenceCode, BigDecimal newBalance) {
        DecimalFormat df = new DecimalFormat("#,###");
        String formattedAmount = df.format(amount != null ? amount : BigDecimal.ZERO) + " VNĐ";
        String formattedBalance = df.format(newBalance != null ? newBalance : BigDecimal.ZERO) + " VNĐ";
        String formattedTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("HH:mm:ss - dd/MM/yyyy"));
        String safeRefCode = escapeHtml(referenceCode != null && !referenceCode.trim().isEmpty() ? referenceCode : "CK" + System.currentTimeMillis());

        return "<!DOCTYPE html>"
                + "<html>"
                + "<head><meta charset='UTF-8'></head>"
                + "<body style='font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, Helvetica, Arial, sans-serif; background-color: #F8FAFC; margin: 0; padding: 30px;'>"
                + "  <div style='max-width: 600px; margin: 0 auto; background: #FFFFFF; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border: 1px solid #E2E8F0;'>"
                + "    <div style='background: linear-gradient(135deg, #093C62, #076FA4); padding: 25px; text-align: center; color: #FFFFFF;'>"
                + "      <h1 style='margin: 0; font-size: 24px; font-weight: 700;'>UTEdu LMS</h1>"
                + "      <p style='margin: 5px 0 0 0; opacity: 0.9; font-size: 14px;'>Hệ Thống Quản Lý Đào Tạo Trực Tuyến</p>"
                + "    </div>"
                + "    <div style='padding: 30px; color: #1E293B; line-height: 1.6;'>"
                + "      <div style='text-align: center; margin-bottom: 24px;'>"
                + "        <div style='display: inline-block; width: 56px; height: 56px; line-height: 56px; border-radius: 50%; background: #D1FAE5; color: #059669; font-size: 28px; margin-bottom: 12px;'>✓</div>"
                + "        <h2 style='color: #0F172A; margin: 0; font-size: 20px;'>Xác Nhận Chuyển Khoản Thành Công</h2>"
                + "        <p style='color: #64748B; font-size: 14px; margin: 6px 0 0 0;'>Giao dịch nạp tiền của bạn đã được ghi nhận và xử lý</p>"
                + "      </div>"
                + "      <p>Xin chào <strong>" + escapeHtml(fullName) + "</strong>,</p>"
                + "      <p>Tài khoản học tập <strong>" + escapeHtml(email) + "</strong> của bạn vừa được cộng số dư thành công từ giao dịch chuyển khoản ngân hàng. Dưới đây là thông tin chi tiết biên lai giao dịch:</p>"
                + "      <table style='width: 100%; border-collapse: collapse; margin: 20px 0; background: #F8FAFC; border-radius: 8px; overflow: hidden; border: 1px solid #E2E8F0;'>"
                + "        <tbody>"
                + "          <tr style='border-bottom: 1px solid #E2E8F0;'>"
                + "            <td style='padding: 12px 16px; color: #64748B; font-size: 14px;'>Mã giao dịch / Tham chiếu:</td>"
                + "            <td style='padding: 12px 16px; font-weight: 600; color: #093C62; font-size: 14px; text-align: right;'>" + safeRefCode + "</td>"
                + "          </tr>"
                + "          <tr style='border-bottom: 1px solid #E2E8F0;'>"
                + "            <td style='padding: 12px 16px; color: #64748B; font-size: 14px;'>Số tiền nạp:</td>"
                + "            <td style='padding: 12px 16px; font-weight: 700; color: #059669; font-size: 16px; text-align: right;'>+ " + formattedAmount + "</td>"
                + "          </tr>"
                + "          <tr style='border-bottom: 1px solid #E2E8F0;'>"
                + "            <td style='padding: 12px 16px; color: #64748B; font-size: 14px;'>Phương thức nạp:</td>"
                + "            <td style='padding: 12px 16px; font-weight: 500; color: #1E293B; font-size: 14px; text-align: right;'>Chuyển khoản Ngân hàng (QR)</td>"
                + "          </tr>"
                + "          <tr style='border-bottom: 1px solid #E2E8F0;'>"
                + "            <td style='padding: 12px 16px; color: #64748B; font-size: 14px;'>Thời gian thực hiện:</td>"
                + "            <td style='padding: 12px 16px; color: #1E293B; font-size: 14px; text-align: right;'>" + formattedTime + "</td>"
                + "          </tr>"
                + "          <tr style='border-bottom: 1px solid #E2E8F0;'>"
                + "            <td style='padding: 12px 16px; color: #64748B; font-size: 14px;'>Trạng thái:</td>"
                + "            <td style='padding: 12px 16px; font-weight: 600; color: #059669; font-size: 14px; text-align: right;'>Thành công (Đã cộng số dư)</td>"
                + "          </tr>"
                + "          <tr>"
                + "            <td style='padding: 12px 16px; color: #64748B; font-size: 14px;'>Số dư ví hiện tại:</td>"
                + "            <td style='padding: 12px 16px; font-weight: 700; color: #076FA4; font-size: 16px; text-align: right;'>" + formattedBalance + "</td>"
                + "          </tr>"
                + "        </tbody>"
                + "      </table>"
                + "      <p>Số dư ví hiện đã sẵn sàng để bạn đăng ký tham gia các khóa học chuyên sâu trên hệ thống.</p>"
                + "      <div style='text-align: center; margin: 30px 0;'>"
                + "        <a href='http://localhost:8080/lms-project/courses' style='background: linear-gradient(135deg, #076FA4, #093C62); color: #FFFFFF; text-decoration: none; padding: 12px 28px; border-radius: 8px; font-weight: 600; font-size: 14px; display: inline-block; box-shadow: 0 2px 8px rgba(7, 111, 164, 0.25);'>Khám phá Khóa học ngay</a>"
                + "      </div>"
                + "      <p style='font-size: 13px; color: #64748B; line-height: 1.5; border-top: 1px solid #E2E8F0; padding-top: 16px; margin-top: 24px;'>"
                + "        <em>* Lưu ý: Đây là email tự động gửi biên lai giao dịch. Nếu bạn không thực hiện yêu cầu nạp tiền này, vui lòng liên hệ ngay với ban quản trị LMS để được hỗ trợ kiểm tra.</em>"
                + "      </p>"
                + "    </div>"
                + "    <div style='background: #F8FAFC; padding: 18px; text-align: center; font-size: 12px; color: #94A3B8; border-top: 1px solid #E2E8F0;'>"
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
        System.out.println("--- Đang thử nghiệm tính năng Email Xác nhận Chuyển khoản (Chapter 14) ---");
        try {
            String subject = "Xác nhận chuyển khoản nạp tiền thành công - UTEdu LMS (Test)";
            String htmlBody = buildTransferConfirmationEmailTemplate("Nguyễn Văn Trọng", "Trongtrung122@gmail.com", new BigDecimal("200000"), "CK20261001TEST", new BigDecimal("500000"));
            sendMail("Trongtrung122@gmail.com", subject, htmlBody, true);
            System.out.println("===> [TEST SUCCESS] Gửi email xác nhận chuyển khoản thành công!");
        } catch (Exception e) {
            System.err.println("===> [TEST FAILED]: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
