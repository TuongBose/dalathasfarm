package com.example.dalathasfarm.services.SupplierInvoice;

import com.example.dalathasfarm.responses.supplierinvoice.SupplierInvoiceResponse;

import java.util.List;

public interface ISupplierInvoiceService {
    List<SupplierInvoiceResponse> getAllSupplierInvoice();
    void blockOrEnable(int id, boolean isUsed, Integer userId) throws Exception;
    void deleteSupplierInvoice();
    void updateSupplierInvoice();
    void createSupplierInvoice();
}
