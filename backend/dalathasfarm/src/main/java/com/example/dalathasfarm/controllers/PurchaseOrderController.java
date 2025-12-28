package com.example.dalathasfarm.controllers;

import com.example.dalathasfarm.components.SecurityUtils;
import com.example.dalathasfarm.models.User;
import com.example.dalathasfarm.responses.ResponseObject;
import com.example.dalathasfarm.responses.purchaseorder.PurchaseOrderResponse;
import com.example.dalathasfarm.responses.supplierinvoice.SupplierInvoiceResponse;
import com.example.dalathasfarm.services.PurchaseOrder.IPurchaseOrderService;
import com.example.dalathasfarm.services.SupplierInvoice.ISupplierInvoiceService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@RestController
@RequestMapping("${api.prefix}/purchase-orders")
// Dependency Injection
@RequiredArgsConstructor
public class PurchaseOrderController {
    private final IPurchaseOrderService purchaseOrderService;
    private final SecurityUtils securityUtils;

    @GetMapping("")
    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_EMPLOYEE')")
    public ResponseEntity<ResponseObject> getAllPurchaseOrder(
    ) {
        List<PurchaseOrderResponse> purchaseOrderResponses = purchaseOrderService.getAllPurchaseOrder();
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Get list of purchase order successfully")
                .status(HttpStatus.OK)
                .data(purchaseOrderResponses)
                .build());
    }

    @GetMapping("/files/{fileName}")
    public ResponseEntity<?> viewFile(@PathVariable String fileName) {
        try {
            Path imagePath = Paths.get("uploads/files/purchase-orders/" + fileName);
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

//    @PutMapping("/block/{id}/{isUsed}")
//    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_EMPLOYEE')")
//    public ResponseEntity<ResponseObject> blockOrEnable(
//            @Valid @PathVariable int id,
//            @Valid @PathVariable int isUsed
//    ) throws Exception {
//        User loginUser = securityUtils.getLoggedInUser();
//        supplierInvoiceService.blockOrEnable(id, isUsed > 0,loginUser.getId());
//        String message = isUsed > 0 ? "Supplier invoice is used successfully" : "Supplier invoice isn't used successfully.";
//        return ResponseEntity.ok().body(ResponseObject.builder()
//                .message(message)
//                .status(HttpStatus.OK)
//                .data(null)
//                .build());
//
//    }

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
