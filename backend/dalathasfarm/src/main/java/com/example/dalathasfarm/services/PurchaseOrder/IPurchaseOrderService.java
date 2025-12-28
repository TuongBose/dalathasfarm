package com.example.dalathasfarm.services.PurchaseOrder;

import com.example.dalathasfarm.dtos.PurchaseOrderDto;
import com.example.dalathasfarm.responses.purchaseorder.PurchaseOrderResponse;

import java.util.List;

public interface IPurchaseOrderService {
    List<PurchaseOrderResponse> getAllPurchaseOrder();
    void deletePurchaseOrder();
    void updatePurchaseOrder();
    void createPurchaseOrder(PurchaseOrderDto purchaseOrderDto);
}
