package com.example.dalathasfarm.services.SupplierInvoice;

import com.example.dalathasfarm.exceptions.DataNotFoundException;
import com.example.dalathasfarm.models.*;
import com.example.dalathasfarm.repositories.*;
import com.example.dalathasfarm.responses.supplierinvoice.SupplierInvoiceResponse;
import com.example.dalathasfarm.responses.supplierinvoicedetail.SupplierInvoiceDetailResponse;
import com.example.dalathasfarm.services.InvoicePdfService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SupplierInvoiceService implements ISupplierInvoiceService {
    private final SupplierInvoiceRepository supplierInvoiceRepository;
    private final SupplierInvoiceDetailRepository supplierInvoiceDetailRepository;
    private final PurchaseOrderRepository purchaseOrderRepository;
    private final PurchaseOrderDetailRepository purchaseOrderDetailRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;

    @Override
    public List<SupplierInvoiceResponse> getAllSupplierInvoice() {
        List<SupplierInvoice> supplierInvoices = supplierInvoiceRepository.findAll();
        return supplierInvoices.stream().map(order -> {
            List<SupplierInvoiceDetailResponse> supplierInvoiceDetailResponses = supplierInvoiceDetailRepository.findBySupplierInvoice(order)
                    .stream()
                    .map(SupplierInvoiceDetailResponse::fromSupplierInvoiceDetail)
                    .collect(Collectors.toList());
            return SupplierInvoiceResponse.fromSupplierInvoice(order, supplierInvoiceDetailResponses);
        }).collect(Collectors.toList());
    }

    @Override
    public void blockOrEnable(int id, boolean isUsed, Integer userId) throws Exception {
        SupplierInvoice existingSupplierInvoice = supplierInvoiceRepository.findById(id)
                .orElseThrow(() -> new DataNotFoundException("Supplier Invoice not fount"));
        List<SupplierInvoiceDetail> supplierInvoiceDetail = supplierInvoiceDetailRepository.findBySupplierInvoice(existingSupplierInvoice);
        User existingUser = userRepository.findById(userId)
                .orElseThrow(() -> new DataNotFoundException("User not fount"));

        if (existingSupplierInvoice.getIsUsed() && isUsed) return;

        existingSupplierInvoice.setIsUsed(isUsed);
        supplierInvoiceRepository.save(existingSupplierInvoice);

        PurchaseOrder newPurchaseOrder = PurchaseOrder.builder()
                .supplierInvoice(existingSupplierInvoice)
                .user(existingUser)
                .importDate(LocalDateTime.now())
                .receiptFile("")
                .build();
        purchaseOrderRepository.save(newPurchaseOrder);

        List<PurchaseOrderDetail> purchaseOrderDetails = new ArrayList<>();
        for (SupplierInvoiceDetail supplierInvoiceDetail1 : supplierInvoiceDetail) {
            PurchaseOrderDetail newPurchaseOrderDetail = new PurchaseOrderDetail();
            newPurchaseOrderDetail.setPurchaseOrder(newPurchaseOrder);
            int productId = supplierInvoiceDetail1.getProduct().getId();
            int quantity = supplierInvoiceDetail1.getQuantity();

            Product product = productRepository.findById(productId)
                    .orElseThrow(() -> new RuntimeException("Product ID does not exists"));
            product.setStockQuantity(product.getStockQuantity() + quantity);
            productRepository.save(product);

            newPurchaseOrderDetail.setProduct(product);
            newPurchaseOrderDetail.setQuantity(quantity);

            purchaseOrderDetails.add(newPurchaseOrderDetail);
        }

        purchaseOrderDetailRepository.saveAll(purchaseOrderDetails);

        // Tạo PDF hóa đơn
        byte[] pdf = InvoicePdfService.generatePurchaseOrderPdf(newPurchaseOrder, purchaseOrderDetails);

        // Lưu file PDF vào thư mục
        Path uploadDir = Paths.get("uploads/files/purchase-orders/");
        if (!Files.exists(uploadDir)) {
            Files.createDirectories(uploadDir);
        }

        String fileName = "invoice_supplier_" + newPurchaseOrder.getId() + ".pdf";
        String uniqueFilename = UUID.randomUUID().toString() + "_" + fileName;
        Path destination = Paths.get(uploadDir.toString(), uniqueFilename);
        Files.write(destination, pdf);

        // Lưu đường dẫn file vào DB
        newPurchaseOrder.setReceiptFile(uniqueFilename);
        purchaseOrderRepository.save(newPurchaseOrder);
    }

    @Override
    public void deleteSupplierInvoice() {

    }

    @Override
    public void updateSupplierInvoice() {

    }

    @Override
    public void createSupplierInvoice() {

    }
}
