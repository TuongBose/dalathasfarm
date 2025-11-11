package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.Order;
import com.example.dalathasfarm.models.OrderDetail;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OrderDetailRepository extends JpaRepository<OrderDetail, Integer> {
    List<OrderDetail> findByOrder(Order order);
}
