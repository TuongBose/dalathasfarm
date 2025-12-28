package com.example.dalathasfarm.services.PurchaseOrder;

import com.example.dalathasfarm.dtos.PurchaseOrderDto;
import com.example.dalathasfarm.models.PurchaseOrder;
import com.example.dalathasfarm.models.SupplierInvoice;
import com.example.dalathasfarm.repositories.PurchaseOrderDetailRepository;
import com.example.dalathasfarm.repositories.PurchaseOrderRepository;
import com.example.dalathasfarm.responses.purchaseorder.PurchaseOrderResponse;
import com.example.dalathasfarm.responses.purchaseorderdetail.PurchaseOrderDetailResponse;
import com.example.dalathasfarm.responses.supplierinvoice.SupplierInvoiceResponse;
import com.example.dalathasfarm.responses.supplierinvoicedetail.SupplierInvoiceDetailResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PurchaseOrderService implements IPurchaseOrderService {
    private final PurchaseOrderRepository purchaseOrderRepository;
    private final PurchaseOrderDetailRepository purchaseOrderDetailRepository;

    @Override
    public List<PurchaseOrderResponse> getAllPurchaseOrder() {
        List<PurchaseOrder> purchaseOrders = purchaseOrderRepository.findAll();
        return purchaseOrders.stream().map(order -> {
            List<PurchaseOrderDetailResponse> purchaseOrderDetailResponses = purchaseOrderDetailRepository.findByPurchaseOrder(order)
                    .stream()
                    .map(PurchaseOrderDetailResponse::fromPurchaseOrderDetail)
                    .collect(Collectors.toList());
            return PurchaseOrderResponse.fromPurchaseOrder(order, purchaseOrderDetailResponses);
        }).collect(Collectors.toList());
    }

    @Override
    public void deletePurchaseOrder() {

    }

    @Override
    public void updatePurchaseOrder() {

    }

    @Override
    public void createPurchaseOrder(PurchaseOrderDto purchaseOrderDto) {

    }
}
