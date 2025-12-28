package com.example.dalathasfarm.services.SupplierOrder;

import com.example.dalathasfarm.dtos.CartItemDto;
import com.example.dalathasfarm.dtos.SupplierOrderDto;
import com.example.dalathasfarm.exceptions.DataNotFoundException;
import com.example.dalathasfarm.models.*;
import com.example.dalathasfarm.repositories.*;
import com.example.dalathasfarm.responses.order.OrderResponse;
import com.example.dalathasfarm.responses.orderdetail.OrderDetailResponse;
import com.example.dalathasfarm.responses.supplierinvoice.SupplierInvoiceResponse;
import com.example.dalathasfarm.responses.supplierinvoicedetail.SupplierInvoiceDetailResponse;
import com.example.dalathasfarm.responses.supplierorder.SupplierOrderResponse;
import com.example.dalathasfarm.responses.supplierorderdetail.SupplierOrderDetailResponse;
import com.example.dalathasfarm.responses.user.UserResponse;
import com.example.dalathasfarm.services.InvoicePdfService;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.data.domain.Page;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
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
public class SupplierOrderService implements ISupplierOrderService {
    private final SupplierRepository supplierRepository;
    private final UserRepository userRepository;
    private final SupplierOrderRepository supplierOrderRepository;
    private final SupplierInvoiceRepository supplierInvoiceRepository;
    private final SupplierInvoiceDetailRepository supplierInvoiceDetailRepository;
    private final SupplierOrderDetailRepository supplierOrderDetailRepository;
    private final ProductRepository productRepository;
    private final ModelMapper modelMapper;

    @Override
    public List<SupplierOrderResponse> getAllSupplierOrder() {
        List<SupplierOrder> supplierOrders = supplierOrderRepository.findAll();
        return supplierOrders.stream().map(order -> {
            List<SupplierOrderDetailResponse> orderDetailResponses = supplierOrderDetailRepository.findBySupplierOrder(order)
                    .stream()
                    .map(SupplierOrderDetailResponse::fromSupplierOrderDetail)
                    .collect(Collectors.toList());
            return SupplierOrderResponse.fromSupplierOrder(order, orderDetailResponses);
        }).collect(Collectors.toList());
    }

    @Override
    public void deleteSupplierOrder() {

    }

    @Override
    public void updateSupplierOrder() {

    }

    @Override
    public SupplierOrderResponse createSupplierOrder(SupplierOrderDto supplierOrderDto) throws Exception {
        Supplier existingSupplier = supplierRepository.findById(supplierOrderDto.getSupplierId())
                .orElseThrow(() -> new DataNotFoundException("Supplier not fount"));
        User existingUser = userRepository.findById(supplierOrderDto.getUserId())
                .orElseThrow(() -> new DataNotFoundException("User not found"));

        if (existingUser.getRole().getId() == Role.CUSTOMER) {
            throw new Exception("You can not create supplier order as customer user");
        }

        SupplierOrder newSupplierOrder = SupplierOrder.builder()
                .supplier(existingSupplier)
                .user(existingUser)
                .orderDate(LocalDateTime.now())
                .status(SupplierOrder.SupplierOrderStatus.Unconfirmed)
                .totalMoney(supplierOrderDto.getTotalMoney())
                .note(supplierOrderDto.getNote())
                .orderFile("")
                .build();
        supplierOrderRepository.save(newSupplierOrder);

        List<SupplierOrderDetail> supplierOrderDetails = new ArrayList<>();
        for (CartItemDto cartItemDto : supplierOrderDto.getCartItems()) {
            SupplierOrderDetail supplierOrderDetail = new SupplierOrderDetail();
            supplierOrderDetail.setSupplierOrder(newSupplierOrder);
            int productId = cartItemDto.getProductId();
            int quantity = cartItemDto.getQuantity();

            Product product = productRepository.findById(productId)
                    .orElseThrow(() -> new RuntimeException("Product ID does not exists"));

            supplierOrderDetail.setProduct(product);
            supplierOrderDetail.setQuantity(quantity);
            supplierOrderDetail.setPrice(product.getPrice());
            supplierOrderDetail.setTotalMoney(product.getPrice().multiply(BigDecimal.valueOf(quantity)));

            supplierOrderDetails.add(supplierOrderDetail);
        }

        supplierOrderDetailRepository.saveAll(supplierOrderDetails);

        // Tạo PDF hóa đơn
        byte[] pdf = InvoicePdfService.generateSupplierOrderPdf(newSupplierOrder, supplierOrderDetails);

        // Lưu file PDF vào thư mục
        Path uploadDir = Paths.get("uploads/files/supplier-orders/");
        if (!Files.exists(uploadDir)) {
            Files.createDirectories(uploadDir);
        }

        String fileName = "invoice_supplier_order_" + newSupplierOrder.getId() + ".pdf";
        String uniqueFilename = UUID.randomUUID().toString() + "_" + fileName;
        Path destination = Paths.get(uploadDir.toString(), uniqueFilename);
        Files.write(destination, pdf);

        // Lưu đường dẫn file vào DB
        newSupplierOrder.setOrderFile(uniqueFilename);
        supplierOrderRepository.save(newSupplierOrder);

        List<SupplierOrderDetailResponse> supplierOrderDetailResponses = supplierOrderDetails.stream()
                .map(SupplierOrderDetailResponse::fromSupplierOrderDetail).toList();
        SupplierOrderResponse supplierOrderResponse = modelMapper.map(newSupplierOrder, SupplierOrderResponse.class);
        supplierOrderResponse.setSupplierOrderDetailResponses(supplierOrderDetailResponses);
        supplierOrderResponse.setUserResponse(UserResponse.fromUser(existingUser));

        return supplierOrderResponse;
    }

    @Override
    public void updateStatusSupplierOrder(int id, String status) throws Exception {
        SupplierOrder existingSupplierOrder = supplierOrderRepository.findById(id)
                .orElseThrow(() -> new DataNotFoundException("Supplier Order not fount"));
        List<SupplierOrderDetail> orderDetails = supplierOrderDetailRepository.findBySupplierOrder(existingSupplierOrder);

        if(existingSupplierOrder.getStatus().name().equals(status)) return;

        if (status.equals(SupplierOrder.SupplierOrderStatus.Confirmed.name())) {
            existingSupplierOrder.setStatus(SupplierOrder.SupplierOrderStatus.Confirmed);
            supplierOrderRepository.save(existingSupplierOrder);
        } else {
            existingSupplierOrder.setStatus(SupplierOrder.SupplierOrderStatus.Unconfirmed);
            supplierOrderRepository.save(existingSupplierOrder);
            return;
        }

        SupplierInvoice newSupplierInvoice = SupplierInvoice.builder()
                .supplier(existingSupplierOrder.getSupplier())
                .invoiceNumber(UUID.randomUUID().toString().substring(0, 6))
                .invoiceDate(LocalDateTime.now())
                .totalMoney(existingSupplierOrder.getTotalMoney())
                .taxAmount(BigDecimal.valueOf(0.0))
                .paymentMethod(SupplierInvoice.SupplierInvoicePaymentMethod.BankTransfer)
                .paymentStatus(SupplierInvoice.SupplierInvoicePaymentStatus.Paid)
                .invoiceFile("")
                .isUsed(false)
                .build();
        supplierInvoiceRepository.save(newSupplierInvoice);

        List<SupplierInvoiceDetail> supplierInvoiceDetail = new ArrayList<>();
        for (SupplierOrderDetail supplierOrderDetail : orderDetails) {
            SupplierInvoiceDetail newSupplierInvoiceDetail = new SupplierInvoiceDetail();
            newSupplierInvoiceDetail.setSupplierInvoice(newSupplierInvoice);
            int productId = supplierOrderDetail.getProduct().getId();
            int quantity = supplierOrderDetail.getQuantity();
            Product product = productRepository.findById(productId)
                    .orElseThrow(() -> new RuntimeException("Product ID does not exists"));

            newSupplierInvoiceDetail.setProduct(product);
            newSupplierInvoiceDetail.setQuantity(quantity);
            newSupplierInvoiceDetail.setPrice(product.getPrice());
            newSupplierInvoiceDetail.setTotalMoney(product.getPrice().multiply(BigDecimal.valueOf(quantity)));

            supplierInvoiceDetail.add(newSupplierInvoiceDetail);
        }

        supplierInvoiceDetailRepository.saveAll(supplierInvoiceDetail);

        // Tạo PDF hóa đơn
        byte[] pdf = InvoicePdfService.generateSupplierInvoicePdf(newSupplierInvoice, supplierInvoiceDetail);

        // Lưu file PDF vào thư mục
        Path uploadDir = Paths.get("uploads/files/supplier-invoice/");
        if (!Files.exists(uploadDir)) {
            Files.createDirectories(uploadDir);
        }

        String fileName = "invoice_supplier_" + newSupplierInvoice.getId() + ".pdf";
        String uniqueFilename = UUID.randomUUID().toString() + "_" + fileName;
        Path destination = Paths.get(uploadDir.toString(), uniqueFilename);
        Files.write(destination, pdf);

        // Lưu đường dẫn file vào DB
        newSupplierInvoice.setInvoiceFile(uniqueFilename);
        supplierInvoiceRepository.save(newSupplierInvoice);

//        List<SupplierInvoiceDetailResponse> supplierInvoiceDetailResponses = supplierInvoiceDetail.stream()
//                .map(SupplierInvoiceDetailResponse::fromSupplierInvoiceDetail).toList();
//        SupplierInvoiceResponse supplierInvoiceResponse = modelMapper.map(newSupplierInvoice, SupplierInvoiceResponse.class);
//        supplierInvoiceResponse.setSupplierInvoiceDetailResponses(supplierInvoiceDetailResponses);
//
//        return supplierInvoiceResponse;
    }
}

