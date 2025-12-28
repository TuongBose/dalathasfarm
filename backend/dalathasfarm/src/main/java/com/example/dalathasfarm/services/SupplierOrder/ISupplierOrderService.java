package com.example.dalathasfarm.services.SupplierOrder;

import com.example.dalathasfarm.dtos.SupplierOrderDto;
import com.example.dalathasfarm.responses.supplierorder.SupplierOrderResponse;

import java.util.List;

public interface ISupplierOrderService {
    List<SupplierOrderResponse> getAllSupplierOrder();
    void deleteSupplierOrder();
    void updateSupplierOrder();
    SupplierOrderResponse createSupplierOrder(SupplierOrderDto supplierOrderDto) throws Exception;
    void updateStatusSupplierOrder(int id, String status) throws Exception;
}
