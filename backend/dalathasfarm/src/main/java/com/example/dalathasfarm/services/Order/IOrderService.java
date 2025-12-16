package com.example.dalathasfarm.services.Order;

import com.example.dalathasfarm.dtos.OrderDto;
import com.example.dalathasfarm.models.Order;
import com.example.dalathasfarm.responses.order.OrderListResponse;
import com.example.dalathasfarm.responses.order.OrderResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface IOrderService {
    OrderResponse createOrder(OrderDto orderDto) throws Exception;
    OrderResponse getOrderById(Integer id) throws Exception;
    List<OrderResponse> getOrderByUserId(Integer userId) throws Exception;
    Order updateOrder(Integer id, OrderDto orderDto) throws Exception;
    void deleteOrder(Integer id) throws Exception;
    Page<OrderResponse> getAllOrderByKeyword(String keyword, Pageable pageable);
    OrderResponse updateStatus(String status, String vnpTxnRef) throws Exception;
}
