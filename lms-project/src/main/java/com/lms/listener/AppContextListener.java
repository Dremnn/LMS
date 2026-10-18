package com.lms.listener;

import com.lms.service.NotificationService;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@WebListener
public class AppContextListener implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor();
        NotificationService notificationService = new NotificationService();

        // Chờ 30 giây sau khi server khởi động xong mới bắt đầu quét định kỳ mỗi 15 phút
        scheduler.scheduleAtFixedRate(() -> {
            try {
                notificationService.checkAndNotifyQuizDeadlines();
            } catch (Exception e) {
                e.printStackTrace();
            }
            try {
                notificationService.checkAndNotifyAssignmentDeadlines();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }, 30, 900, TimeUnit.SECONDS);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) {
            scheduler.shutdownNow();
        }
    }
}
