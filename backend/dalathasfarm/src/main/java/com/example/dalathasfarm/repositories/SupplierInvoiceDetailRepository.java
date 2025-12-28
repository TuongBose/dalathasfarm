package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.SupplierInvoice;
import com.example.dalathasfarm.models.SupplierInvoiceDetail;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SupplierInvoiceDetailRepository extends JpaRepository<SupplierInvoiceDetail, Integer> {
    List<SupplierInvoiceDetail> findBySupplierInvoice(SupplierInvoice supplierInvoice);
}
