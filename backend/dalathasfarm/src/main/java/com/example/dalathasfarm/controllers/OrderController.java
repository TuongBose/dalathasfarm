package com.example.dalathasfarm.controllers;

import com.example.dalathasfarm.components.LocalizationUtils;
import com.example.dalathasfarm.components.SecurityUtils;
import com.example.dalathasfarm.dtos.OrderDto;
import com.example.dalathasfarm.models.Order;
import com.example.dalathasfarm.models.Role;
import com.example.dalathasfarm.models.User;
import com.example.dalathasfarm.responses.ResponseObject;
import com.example.dalathasfarm.responses.order.OrderListResponse;
import com.example.dalathasfarm.responses.order.OrderResponse;
import com.example.dalathasfarm.services.Order.IOrderService;
import com.example.dalathasfarm.utils.MessageKeys;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.UrlResource;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.*;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Objects;

@RestController
@RequestMapping("${api.prefix}/orders")
@RequiredArgsConstructor
public class OrderController {
    private final IOrderService orderService;
    private final LocalizationUtils localizationUtils;
    private final SecurityUtils securityUtils;

    @PostMapping("")
//    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_CUSTOMER') or hasRole('ROLE_EMPLOYEE')")
    public ResponseEntity<ResponseObject> createOrder(
            @RequestBody @Valid OrderDto orderDto,
            BindingResult result
    ) throws Exception {
        if (result.hasErrors()) {
            List<String> errorMessage = result.getFieldErrors().stream().map(FieldError::getDefaultMessage).toList();
            return ResponseEntity.badRequest().body(ResponseObject.builder()
                    .message(String.join("; ", errorMessage))
                    .status(HttpStatus.BAD_REQUEST)
                    .build());
        }
        User loginUser = securityUtils.getLoggedInUser();
        if (loginUser != null) {
            if (orderDto.getUserId() != loginUser.getId()) {
                throw new Exception("You can not order as another user");
            }
        }else if (orderDto.getUserId() != 1) {
            throw new Exception("You can not order as another user");
        }

        OrderResponse orderResponse = orderService.createOrder(orderDto);
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Insert order successfully")
                .status(HttpStatus.OK)
                .data(orderResponse)
                .build());
    }

    @GetMapping("/user/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_CUSTOMER') or hasRole('ROLE_EMPLOYEE')")
    public ResponseEntity<ResponseObject> getOrderByUserId(@Valid @PathVariable Integer id) throws Exception {
        User loginUser = securityUtils.getLoggedInUser();
        boolean isUserIdBlank = id <= 0;
        List<Order> orders = orderService.getOrderByUserId(isUserIdBlank ? loginUser.getId() : id);
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Get list of orders successfully")
                .status(HttpStatus.OK)
                .data(orders)
                .build());
    }

    @GetMapping("/{id}")
//    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_CUSTOMER') or hasRole('ROLE_EMPLOYEE')")
    public ResponseEntity<ResponseObject> getOrderById(@Valid @PathVariable Integer id) throws Exception {
        OrderResponse orderResponse = orderService.getOrderById(id);
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Get list of orders successfully")
                .status(HttpStatus.OK)
                .data(orderResponse)
                .build());
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_CUSTOMER') or hasRole('ROLE_EMPLOYEE')")
    public ResponseEntity<ResponseObject> updateOrder(
            @Valid @PathVariable Integer id,
            @Valid @RequestBody OrderDto orderDto
    ) throws Exception {
        User loginUser = securityUtils.getLoggedInUser();
        if (orderDto.getUserId() != loginUser.getId()) {
            if (loginUser.getRole().getId() == Role.CUSTOMER) {
                throw new Exception("You can not update order as another user");
            }
        }

        Order order = orderService.updateOrder(id, orderDto);
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Update order successfully")
                .status(HttpStatus.OK)
                .data(order)
                .build());
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> deleteOrder(@Valid @PathVariable Integer id) throws Exception {
        orderService.deleteOrder(id);
        return ResponseEntity.ok(ResponseObject.builder()
                .message(localizationUtils.getLocalizedMessage(MessageKeys.DELETE_DONHANG_SUCCESSFULLY, id))
                .status(HttpStatus.OK)
                .data(null)
                .build());
    }

    @PutMapping("/status")
//    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_CUSTOMER') or hasRole('ROLE_EMPLOYEE')")
    public ResponseEntity<ResponseObject> updateStatusOrder(
            @RequestParam(name = "status") String status,
            @RequestParam(name = "vnpTxnRef") String vnpTxnRef
    ) throws Exception {
        OrderResponse orderResponse = orderService.updateStatus(status, vnpTxnRef);
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Update status order successfully")
                .status(HttpStatus.OK)
                .data(orderResponse)
                .build());
    }

    @GetMapping("/get-all-order-by-keyword")
    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_EMPLOYEE')")
    public ResponseEntity<ResponseObject> getAllOrderByKeyword(
            @RequestParam(defaultValue = "", required = false) String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int limit
    ) {
        PageRequest pageRequest = PageRequest.of(
                page, limit,
                Sort.by("id").ascending()
        );
        Page<OrderResponse> orderResponsePage = orderService.getAllOrderByKeyword(keyword, pageRequest);

        int totalPages = orderResponsePage.getTotalPages();
        List<OrderResponse> orderResponses = orderResponsePage.getContent();
        OrderListResponse orderListResponse = OrderListResponse
                .builder()
                .orderResponses(orderResponses)
                .totalPages(totalPages)
                .build();

        return ResponseEntity.ok(ResponseObject.builder()
                .message("Get all order successfully")
                .status(HttpStatus.OK)
                .data(orderListResponse)
                .build());
    }

    @PutMapping("/cancel/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_CUSTOMER') or hasRole('ROLE_EMPLOYEE')")
    public ResponseEntity<ResponseObject> cancelOrder(@Valid @PathVariable Integer id) throws Exception {
        OrderResponse orderResponse = orderService.getOrderById(id);

        // Kiểm tra xem người dùng hiện tại có phải là người đã đặt đơn hàng hay không
        User loginUser = securityUtils.getLoggedInUser();
        if (!Objects.equals(loginUser.getId(), orderResponse.getUserId())) {
            return ResponseEntity.badRequest().body(ResponseObject.builder()
                    .message("You do not have permission to cancel this order")
                    .status(HttpStatus.BAD_REQUEST)
                    .data(null)
                    .build());
        }

        Order.OrderStatus statusEnum = Order.OrderStatus.valueOf(orderResponse.getStatus());
        if (statusEnum == Order.OrderStatus.Delivered ||
                statusEnum == Order.OrderStatus.Shipping ||
                statusEnum == Order.OrderStatus.Processing) {

            String message = "You cannot cancel an order with status: " + orderResponse.getStatus();
            return ResponseEntity.badRequest().body(ResponseObject.builder()
                    .message(message)
                    .status(HttpStatus.BAD_REQUEST)
                    .data(null)
                    .build());
        }

        OrderDto orderDto = OrderDto.builder()
                .userId(orderResponse.getUserId())
                /*
                .email(order.getEmail())
                .note(order.getNote())
                .address(order.getAddress())
                .fullName(order.getFullName())
                .totalMoney(order.getTotalMoney())
                .couponCode(order.getCoupon().getCode())
                */
                .status(Order.OrderStatus.Cancelled.name())
                .build();

        Order order = orderService.updateOrder(id, orderDto);
        return ResponseEntity.ok(
                ResponseObject.builder()
                        .message("Cancel order successfully")
                        .status(HttpStatus.OK)
                        .data(order)
                        .build());
    }

    @GetMapping("/files/{fileName}")
    public ResponseEntity<?> viewFile(@PathVariable String fileName) {
        try {
            Path imagePath = Paths.get("uploads/files/orders/" + fileName);
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
}
