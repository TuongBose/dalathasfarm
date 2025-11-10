package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.Notification;
import org.springframework.data.jpa.repository.JpaRepository;

public interface NotificationRepository extends JpaRepository<Integer, Notification> {
}
