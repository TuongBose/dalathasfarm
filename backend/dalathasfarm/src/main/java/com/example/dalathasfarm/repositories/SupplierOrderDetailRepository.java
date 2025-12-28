package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.SupplierOrder;
import com.example.dalathasfarm.models.SupplierOrderDetail;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SupplierOrderDetailRepository extends JpaRepository<SupplierOrderDetail, Integer> {
    List<SupplierOrderDetail> findBySupplierOrder(SupplierOrder supplierOrder);
}
