package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.Feedback;
import com.example.dalathasfarm.models.Product;
import com.example.dalathasfarm.models.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface FeedbackRepository extends JpaRepository<Feedback, Integer> {
    List<Feedback> findByUser(User user);
    List<Feedback> findByProduct (Product product);
    List<Feedback> findByUserAndProduct(User user, Product product);
}
