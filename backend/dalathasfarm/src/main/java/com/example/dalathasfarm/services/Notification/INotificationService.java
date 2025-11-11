package com.example.dalathasfarm.services.Notification;

import com.example.dalathasfarm.responses.notification.NotificationResponse;

import java.util.List;

public interface INotificationService {
    List<NotificationResponse> getNotificationByUserId(Integer userId) throws Exception;

    NotificationResponse markAsReadNotification(Integer userId, Integer notificationId) throws Exception;
    void  markAllAsReadNotification(Integer userId) throws Exception;

    List<NotificationResponse> getUnreadNotificationsByUserId(Integer userId) throws Exception;

    void deleteNoitificationById(Integer userId, Integer notificationId) throws Exception;
}
