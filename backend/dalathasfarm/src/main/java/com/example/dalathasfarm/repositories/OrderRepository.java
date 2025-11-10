package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.Order;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrderRepository extends JpaRepository<Integer, Order> {
}
