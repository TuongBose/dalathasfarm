package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.PurchaseOrder;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PurchaseOrderRepository extends JpaRepository<PurchaseOrder, Integer> {
}
