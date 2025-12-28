package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.PurchaseOrder;
import com.example.dalathasfarm.models.PurchaseOrderDetail;
import com.example.dalathasfarm.models.SupplierOrder;
import com.example.dalathasfarm.models.SupplierOrderDetail;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PurchaseOrderDetailRepository extends JpaRepository<PurchaseOrderDetail, Integer> {
    List<PurchaseOrderDetail> findByPurchaseOrder(PurchaseOrder purchaseOrder);
}
