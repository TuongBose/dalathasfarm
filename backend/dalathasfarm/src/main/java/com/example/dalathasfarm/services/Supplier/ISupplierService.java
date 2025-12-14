package com.example.dalathasfarm.services.Supplier;

import com.example.dalathasfarm.dtos.SupplierDto;
import com.example.dalathasfarm.models.Supplier;

import java.util.List;

public interface ISupplierService {
    List<Supplier> getAllSupplier();
    void deleteSupplier(Integer id) throws Exception;;
    Supplier updateSupplier(SupplierDto supplierDto, Integer id) throws Exception;;
    Supplier createSupplier(SupplierDto supplierDto) throws Exception;;
    Supplier getSupplierById(Integer id) throws Exception;
}
