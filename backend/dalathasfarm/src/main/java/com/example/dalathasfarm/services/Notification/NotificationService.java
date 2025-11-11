package com.example.dalathasfarm.services.Notification;

import com.example.dalathasfarm.components.LocalizationUtils;
import com.example.dalathasfarm.exceptions.DataNotFoundException;
import com.example.dalathasfarm.models.Notification;
import com.example.dalathasfarm.models.User;
import com.example.dalathasfarm.repositories.NotificationRepository;
import com.example.dalathasfarm.repositories.UserRepository;
import com.example.dalathasfarm.responses.notification.NotificationResponse;
import com.example.dalathasfarm.utils.MessageKeys;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NotificationService implements INotificationService{
    private final LocalizationUtils localizationUtils;
    private final UserRepository userRepository;
    private final NotificationRepository notificationRepository;

    @Override
    public List<NotificationResponse> getNotificationByUserId(Integer userId) throws Exception {
        User existingUser = userRepository.findById(userId).orElseThrow(
                () -> new DataNotFoundException(localizationUtils.getLocalizedMessage(MessageKeys.USER_NOT_FOUND))
        );
        return notificationRepository.findByUserOrderByCreatedAtDesc(existingUser).stream()
                .map(NotificationResponse::fromNotification)
                .collect(Collectors.toList());
    }

    @Override
    public NotificationResponse markAsReadNotification(Integer userId, Integer notificationId) throws Exception {
        Notification notification = notificationRepository.findById(notificationId).orElseThrow(()
                -> new DataNotFoundException(
                localizationUtils.getLocalizedMessage(MessageKeys.NOTIFICATION_NOT_FOUND, notificationId))
        );
        if (!Objects.equals(notification.getUser().getId(), userId)) {
            throw new DataNotFoundException(
                    localizationUtils.getLocalizedMessage(MessageKeys.NOTIFICATION_ACCESS_DENIED));
        }
        notification.setIsRead(true);
        notificationRepository.save(notification);
        return NotificationResponse.fromNotification(notification);
    }

    @Override
    public void markAllAsReadNotification(Integer userId) throws Exception {
        User existingUser = userRepository.findById(userId).orElseThrow(
                () -> new DataNotFoundException(localizationUtils.getLocalizedMessage(MessageKeys.USER_NOT_FOUND))
        );
        List<Notification> notifications = notificationRepository.findByUser(existingUser);
        for (Notification notification : notifications) {
            notification.setIsRead(true);
        }
        notificationRepository.saveAll(notifications);
    }

    @Override
    public List<NotificationResponse> getUnreadNotificationsByUserId(Integer userId) throws Exception {
        User existingUser = userRepository.findById(userId).orElseThrow(
                () -> new DataNotFoundException(localizationUtils.getLocalizedMessage(MessageKeys.USER_NOT_FOUND))
        );
        return notificationRepository.findByUserAndIsReadFalseOrderByCreatedAtDesc(existingUser).stream()
                .map(NotificationResponse::fromNotification)
                .collect(Collectors.toList());
    }

    @Override
    public void deleteNoitificationById(Integer userId, Integer notificationId) throws Exception {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new DataNotFoundException(localizationUtils.getLocalizedMessage(
                        MessageKeys.NOTIFICATION_NOT_FOUND, notificationId)));

        if (!Objects.equals(notification.getUser().getId(), userId)) {
            throw new DataNotFoundException(
                    localizationUtils.getLocalizedMessage(MessageKeys.NOTIFICATION_DELETE_FORBIDDEN));
        }
        notificationRepository.delete(notification);
    }
}
