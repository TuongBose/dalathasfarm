package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.OrderDetail;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrderDetailRepository extends JpaRepository<Integer, OrderDetail> {
}
