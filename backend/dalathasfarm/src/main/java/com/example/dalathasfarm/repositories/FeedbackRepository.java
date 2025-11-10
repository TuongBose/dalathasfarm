package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.Feedback;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FeedbackRepository extends JpaRepository<Integer, Feedback> {
}
