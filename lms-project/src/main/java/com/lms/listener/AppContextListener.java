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

        // Chờ 15 giây sau khi server khởi động xong mới bắt đầu quét định kỳ
        scheduler.scheduleAtFixedRate(() -> {
            try {
                notificationService.checkAndNotifyQuizDeadlines();
                System.out.println("Ran checkAndNotifyQuizDeadlines background task.");
            } catch (Exception e) {
                e.printStackTrace();
            }
        }, 15, 60, TimeUnit.SECONDS);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null) {
            scheduler.shutdownNow();
        }
    }
}
