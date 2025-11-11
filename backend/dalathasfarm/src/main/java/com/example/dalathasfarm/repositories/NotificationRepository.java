package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.Notification;
import com.example.dalathasfarm.models.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification, Integer> {
    List<Notification> findByUserOrderByCreatedAtDesc(User user);

    @Query(value = "SELECT COUNT(*) FROM notifications WHERE user_id = :userId AND is_read = false", nativeQuery = true)
    Long countNotificationItems (@Param("userId") int userId);

    List<Notification> findByUserAndIsReadFalseOrderByCreatedAtDesc(User user);
    List<Notification> findByUser(User user);
}
