package com.example.dalathasfarm.services.Supplier;

import com.example.dalathasfarm.dtos.SupplierDto;
import com.example.dalathasfarm.exceptions.DataNotFoundException;
import com.example.dalathasfarm.models.Product;
import com.example.dalathasfarm.models.Supplier;
import com.example.dalathasfarm.repositories.ProductRepository;
import com.example.dalathasfarm.repositories.SupplierRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SupplierService implements ISupplierService {
    private final SupplierRepository supplierRepository;
    private final ProductRepository productRepository;

    @Override
    public List<Supplier> getAllSupplier() {
        return supplierRepository.findAll();
    }

    @Override
    public void deleteSupplier(Integer id) throws Exception {
        Supplier existingSupplier = supplierRepository.findById(id)
                .orElseThrow(() -> new DataNotFoundException("Supplier not found"));

        List<Product> products = productRepository.findBySupplier(existingSupplier);
        if (!products.isEmpty()) {
            throw new IllegalArgumentException("Cannot delete supplier with associated products");
        } else {
            supplierRepository.deleteById(id);
        }
    }

    @Override
    public Supplier updateSupplier(SupplierDto supplierDto,Integer id) throws Exception {
        Supplier existingSupplier = getSupplierById(id);
        if (!(supplierRepository.existsByName(supplierDto.getName())
                && supplierRepository.existsByEmail(supplierDto.getEmail())
                && supplierRepository.existsByPhoneNumber(supplierDto.getPhoneNumber()))) {
            existingSupplier.setName(supplierDto.getName());
            existingSupplier.setEmail(supplierDto.getEmail());
            existingSupplier.setPhoneNumber(supplierDto.getPhoneNumber());
            existingSupplier.setAddress(supplierDto.getAddress());
            return existingSupplier;
        } else {
            throw new Exception("Supplier already exist");
        }
    }

    @Override
    public Supplier createSupplier(SupplierDto supplierDto) throws Exception {
        if (!(supplierRepository.existsByName(supplierDto.getName())
                && supplierRepository.existsByEmail(supplierDto.getEmail())
                && supplierRepository.existsByPhoneNumber(supplierDto.getPhoneNumber()))) {
            Supplier newSupplier = Supplier.builder()
                    .name(supplierDto.getName())
                    .email(supplierDto.getEmail())
                    .address(supplierDto.getAddress())
                    .phoneNumber(supplierDto.getPhoneNumber())
                    .build();
            return supplierRepository.save(newSupplier);
        } else {
            throw new Exception("Supplier already exist");
        }
    }

    @Override
    public Supplier getSupplierById(Integer id) throws Exception {
        return supplierRepository.findById(id)
                .orElseThrow(() -> new DataNotFoundException("Supplier not found"));
    }
}
