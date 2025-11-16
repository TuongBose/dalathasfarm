package com.example.dalathasfarm.controllers;

import com.example.dalathasfarm.components.LocalizationUtils;
import com.example.dalathasfarm.models.User;
import com.example.dalathasfarm.responses.ResponseObject;
import com.example.dalathasfarm.responses.notification.NotificationResponse;
import com.example.dalathasfarm.services.Notification.INotificationService;
import com.example.dalathasfarm.utils.MessageKeys;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("${api.prefix}/notifications")
@RequiredArgsConstructor
public class NotificationController {
    private final LocalizationUtils localizationUtils;
    private final INotificationService notificationService;

    @GetMapping("")
    @PreAuthorize("hasRole('ROLE_CUSTOMER')")
    public ResponseEntity<ResponseObject> getNotificationByUserId() throws Exception {
        User loginUser = (User) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        int userId = loginUser.getId();
        List<NotificationResponse> notificationResponses = notificationService.getNotificationByUserId(userId);
        return ResponseEntity.ok(ResponseObject.builder()
                .message(localizationUtils.getLocalizedMessage(
                        MessageKeys.NOTIFICATION_FETCHED_SUCCESSFULLY, userId))
                .status(HttpStatus.OK)
                .data(notificationResponses)
                .build());
    }

    @PatchMapping("mark-as-read/{notificationId}")
    @PreAuthorize("hasRole('ROLE_CUSTOMER')")
    public ResponseEntity<ResponseObject> markAsReadNotification(@PathVariable int notificationId) throws Exception {
        User loginUser = (User) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        int userId = loginUser.getId();
        NotificationResponse notificationResponses = notificationService.markAsReadNotification(userId, notificationId);
        return ResponseEntity.ok(ResponseObject.builder()
                .message(localizationUtils.getLocalizedMessage(
                        MessageKeys.NOTIFICATION_MARK_SUCCESS, notificationId))
                .status(HttpStatus.OK)
                .data(notificationResponses)
                .build());
    }

    @GetMapping("/unread")
    @PreAuthorize("hasRole('ROLE_CUSTOMER')")
    public ResponseEntity<ResponseObject> getUnreadNotifications() throws Exception{
        User loginUser = (User) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        int userId = loginUser.getId();
        List<NotificationResponse> unreadNotifications = notificationService.getUnreadNotificationsByUserId(userId);
        return ResponseEntity.ok(ResponseObject.builder()
                .message(localizationUtils.getLocalizedMessage(
                        MessageKeys.UNREAD_NOTIFICATION_FETCHED_SUCCESSFULLY, userId))
                .status(HttpStatus.OK)
                .data(unreadNotifications)
                .build());
    }

    @DeleteMapping("/delete/{notificationId}")
    @PreAuthorize("hasRole('ROLE_CUSTOMER')")
    public ResponseEntity<ResponseObject> deleteNotificationById(@PathVariable int notificationId) throws Exception{
        User loginUser = (User) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        int userId = loginUser.getId();
        notificationService.deleteNoitificationById(userId, notificationId);
        return ResponseEntity.ok(ResponseObject.builder()
                .message(localizationUtils.getLocalizedMessage(
                        MessageKeys.NOTIFICATION_DELETE_SUCCESS, notificationId))
                .status(HttpStatus.OK)
                .data(null)
                .build());
    }

    @PostMapping("/mark-all-as-read")
    @PreAuthorize("hasRole('ROLE_CUSTOMER')")
    public ResponseEntity<ResponseObject> markAllAsRead() throws Exception {
        User loginUser = (User) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        int userId = loginUser.getId();
        notificationService.markAllAsReadNotification(userId);
        return ResponseEntity.ok(ResponseObject.builder()
                .message(localizationUtils.getLocalizedMessage(MessageKeys.ALL_NOTIFICATIONS_MARKED_READ, userId))
                .status(HttpStatus.OK)
                .data(null)
                .build());
    }
}
