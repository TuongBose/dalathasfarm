package com.example.dalathasfarm.controllers;

import com.example.dalathasfarm.dtos.SupplierDto;
import com.example.dalathasfarm.models.Supplier;
import com.example.dalathasfarm.responses.ResponseObject;
import com.example.dalathasfarm.services.Supplier.ISupplierService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("${api.prefix}/suppliers")
// Dependency Injection
@RequiredArgsConstructor
public class SupplierController {
private  final ISupplierService supplierService;

    @PostMapping("")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> createSupplier(
            @Valid @RequestBody SupplierDto supplierDto,
            BindingResult result) throws Exception {
        if (result.hasErrors()) {
            List<String> errorMessage = result.getFieldErrors()
                    .stream()
                    .map(FieldError::getDefaultMessage)
                    .toList();
            return ResponseEntity.badRequest().body(ResponseObject.builder()
                    .message(String.join("; ", errorMessage))
                    .status(HttpStatus.BAD_REQUEST)
                    .build());
        }
        Supplier supplier = supplierService.createSupplier(supplierDto);
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Create Supplier successfully")
                .status(HttpStatus.CREATED)
                .data(supplier)
                .build());
    }

    @GetMapping("")
    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_EMPLOYEE')")
    public ResponseEntity<ResponseObject> getAllSupplier(
    ) {
        List<Supplier> suppliers = supplierService.getAllSupplier();
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Get list of suppliers successfully")
                .status(HttpStatus.OK)
                .data(suppliers)
                .build());
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> updateSupplier(
            @PathVariable Integer id,
            @Valid @RequestBody SupplierDto supplierDto
    ) throws Exception {
        Supplier supplier = supplierService.updateSupplier(supplierDto,id);
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Update Supplier successfully")
                .status(HttpStatus.OK)
                .data(supplier)
                .build());
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> deleteSupplier(@PathVariable Integer id) throws Exception {
        supplierService.deleteSupplier(id);
        return ResponseEntity.ok(ResponseObject.builder()
                .status(HttpStatus.OK)
                .message("Delete Supplier successfully")
                .data(null)
                .build());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_EMPLOYEE')")
    public ResponseEntity<ResponseObject> getSupplierById(
            @PathVariable Integer id
    ) throws Exception {
        Supplier supplier = supplierService.getSupplierById(id);
        return ResponseEntity.ok(ResponseObject.builder()
                .data(supplier)
                .message("Get Supplier information successfully")
                .status(HttpStatus.OK)
                .build());
    }
}
