package com.example.dalathasfarm.controllers;

import com.example.dalathasfarm.components.SecurityUtils;
import com.example.dalathasfarm.dtos.SupplierOrderDto;
import com.example.dalathasfarm.models.SupplierOrder;
import com.example.dalathasfarm.models.User;
import com.example.dalathasfarm.responses.ResponseObject;
import com.example.dalathasfarm.responses.supplierorder.SupplierOrderResponse;
import com.example.dalathasfarm.services.SupplierOrder.ISupplierOrderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.*;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@RestController
@RequestMapping("${api.prefix}/supplier-orders")
// Dependency Injection
@RequiredArgsConstructor
public class SupplierOrderController {
    private final ISupplierOrderService supplierOrderService;
    private final SecurityUtils securityUtils;

    @PostMapping("")
    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_EMPLOYEE')")
    public ResponseEntity<ResponseObject> createSupplierOrder(
            @Valid @RequestBody SupplierOrderDto supplierOrderDto,
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

        User loginUser = securityUtils.getLoggedInUser();
        if (supplierOrderDto.getUserId() != loginUser.getId()) {
            throw new Exception("You can not create supplier order as another user");
        }

        SupplierOrderResponse supplierOrderResponse = supplierOrderService.createSupplierOrder(supplierOrderDto);
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Create Supplier Order successfully")
                .status(HttpStatus.CREATED)
                .data(supplierOrderResponse)
                .build());
    }

    @GetMapping("")
    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_EMPLOYEE')")
    public ResponseEntity<ResponseObject> getAllSupplierOrder(
    ) {
        List<SupplierOrderResponse> suppliers = supplierOrderService.getAllSupplierOrder();
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Get list of supplier orders successfully")
                .status(HttpStatus.OK)
                .data(suppliers)
                .build());
    }

    @GetMapping("/files/{fileName}")
    public ResponseEntity<?> viewFile(@PathVariable String fileName) {
        try {
            Path imagePath = Paths.get("uploads/files/supplier-orders/" + fileName);
            UrlResource resource = new UrlResource(imagePath.toUri());

            if (resource.exists()) {
                return ResponseEntity.ok()
                        .contentType(MediaType.APPLICATION_PDF)
                        .body(resource);
            } else {
                return ResponseEntity.notFound().build();
                //return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PutMapping("/status/{supplierOrderId}/{status}")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> updateStatusSupplierOrder(
            @Valid @PathVariable int supplierOrderId,
            @Valid @PathVariable String status
    ) throws Exception {
        supplierOrderService.updateStatusSupplierOrder(supplierOrderId, status);
        String message = status.equals(SupplierOrder.SupplierOrderStatus.Confirmed.name()) ? "Successfully Confirmed Supplier Order." : "Successfully Unconfirmed Supplier Order.";
        return ResponseEntity.ok().body(ResponseObject.builder()
                .message(message)
                .status(HttpStatus.OK)
                .data(null)
                .build());

    }

//    @PutMapping("/{id}")
//    @PreAuthorize("hasRole('ROLE_ADMIN')")
//    public ResponseEntity<ResponseObject> updateSupplier(
//            @PathVariable Integer id,
//            @Valid @RequestBody  supplierDto
//    ) throws Exception {
//        Supplier supplier = supplierService.updateSupplier(supplierDto,id);
//        return ResponseEntity.ok(ResponseObject.builder()
//                .message("Update Supplier successfully")
//                .status(HttpStatus.OK)
//                .data(supplier)
//                .build());
//    }

//    @DeleteMapping("/{id}")
//    @PreAuthorize("hasRole('ROLE_ADMIN')")
//    public ResponseEntity<ResponseObject> deleteSupplier(@PathVariable Integer id) throws Exception {
//        supplierService.deleteSupplier(id);
//        return ResponseEntity.ok(ResponseObject.builder()
//                .status(HttpStatus.OK)
//                .message("Delete Supplier successfully")
//                .data(null)
//                .build());
//    }

//    @GetMapping("/{id}")
//    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_EMPLOYEE')")
//    public ResponseEntity<ResponseObject> getSupplierById(
//            @PathVariable Integer id
//    ) throws Exception {
//        Supplier supplier = supplierService.getSupplierById(id);
//        return ResponseEntity.ok(ResponseObject.builder()
//                .data(supplier)
//                .message("Get Supplier information successfully")
//                .status(HttpStatus.OK)
//                .build());
//    }
}
