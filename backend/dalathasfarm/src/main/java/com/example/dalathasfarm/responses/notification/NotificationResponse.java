package com.example.dalathasfarm.responses.notification;

import com.example.dalathasfarm.models.Notification;
import com.example.dalathasfarm.responses.BaseResponse;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class NotificationResponse extends BaseResponse {
    @JsonProperty("notification_id")
    private Integer id;

    @JsonProperty("user_id")
    private Integer userId;

    private String title;
    private String content;
    private String type;

    @JsonProperty("is_read")
    private Boolean isRead;

    public static NotificationResponse fromNotification (Notification notification) {
        NotificationResponse newNotificationResponse = NotificationResponse.builder()
                .id(notification.getId())
                .userId(notification.getUser().getId())
                .title(notification.getTitle())
                .content(notification.getContent())
                .type(notification.getType().name())
                .isRead(notification.getIsRead())
                .build();
        newNotificationResponse.setCreatedAt(notification.getCreatedAt());
        newNotificationResponse.setUpdatedAt(notification.getUpdatedAt());

        return newNotificationResponse;
    }
}
