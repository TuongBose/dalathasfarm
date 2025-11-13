package com.example.dalathasfarm.controllers;

import com.example.dalathasfarm.components.LocalizationUtils;
import com.example.dalathasfarm.dtos.OrderDetailDto;
import com.example.dalathasfarm.exceptions.DataNotFoundException;
import com.example.dalathasfarm.models.OrderDetail;
import com.example.dalathasfarm.responses.ResponseObject;
import com.example.dalathasfarm.responses.orderdetail.OrderDetailResponse;
import com.example.dalathasfarm.services.OrderDetail.IOrderDetailService;
import com.example.dalathasfarm.utils.MessageKeys;
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
@RequestMapping("${api.prefix}/order_details")
@RequiredArgsConstructor
public class OrderDetailController {
    private final IOrderDetailService orderDetailService;
    private final LocalizationUtils localizationUtils;

    @PostMapping("")
//    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_USER') or hasRole('ROLE_EMPLOYEE')")
    public ResponseEntity<ResponseObject> createOrderDetail(
            @Valid @RequestBody OrderDetailDto orderDetailDto,
            BindingResult result
    ) throws Exception {
        if (result.hasErrors()) {
            List<String> errorMessage = result.getFieldErrors().stream().map(FieldError::getDefaultMessage).toList();
            return ResponseEntity.badRequest().body(ResponseObject.builder()
                    .message("Create order details failed")
                    .status(HttpStatus.BAD_REQUEST)
                    .build());
        }
        OrderDetail newOrderDetail = orderDetailService.createOrderDetail(orderDetailDto);
        OrderDetailResponse newOrderDetailResponse = OrderDetailResponse.fromOrderDetail(newOrderDetail);
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Create order detail successfully")
                .status(HttpStatus.CREATED)
                .data(newOrderDetailResponse)
                .build());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_USER') or hasRole('ROLE_EMPLOYEE')")
    public ResponseEntity<ResponseObject> getOrderDetailById(@Valid @PathVariable Integer id) throws Exception{
        OrderDetail newOrderDetail = orderDetailService.getOrderDetailById(id);
        OrderDetailResponse newOrderDetailResponse = OrderDetailResponse.fromOrderDetail(newOrderDetail);
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Get order detail by Id successfully")
                .status(HttpStatus.OK)
                .data(newOrderDetailResponse)
                .build());
    }

    @GetMapping("/order/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_USER') or hasRole('ROLE_EMPLOYEE')")
    public ResponseEntity<ResponseObject> getOrderDetailByOrderId(@Valid @PathVariable Integer id) throws Exception {
        List<OrderDetail> orderDetails = orderDetailService.getOrderDetailByOrderId(id);
        List<OrderDetailResponse> orderDetailResponses = orderDetails.stream().map(OrderDetailResponse::fromOrderDetail).toList();
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Get order details by orderId successfully")
                .status(HttpStatus.OK)
                .data(orderDetailResponses)
                .build());
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_USER') or hasRole('ROLE_EMPLOYEE')")
    public ResponseEntity<ResponseObject> updateOrderDetail(
            @Valid @PathVariable Integer id,
            @RequestBody OrderDetailDto orderDetailDto
    ) throws DataNotFoundException, Exception {
        OrderDetail orderDetail = orderDetailService.updateOrderDetail(id, orderDetailDto);
        OrderDetailResponse orderDetailResponse = OrderDetailResponse.fromOrderDetail(orderDetail);
        return ResponseEntity.ok(ResponseObject.builder()
                .message("Update order detail successfully")
                .status(HttpStatus.OK)
                .data(orderDetailResponse)
                .build());
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ROLE_ADMIN')")
    public ResponseEntity<ResponseObject> deleteOrderDetail(@Valid @PathVariable Integer id) {
        orderDetailService.deleteOrderDetail(id);
        return ResponseEntity.ok(ResponseObject.builder()
                .message(localizationUtils.getLocalizedMessage(MessageKeys.DELETE_CHITIETDONHANG_SUCCESSFULLY, id))
                .status(HttpStatus.OK)
                .build());
    }
}
