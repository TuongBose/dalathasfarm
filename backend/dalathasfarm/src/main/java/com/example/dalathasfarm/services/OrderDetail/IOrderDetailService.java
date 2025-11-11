package com.example.dalathasfarm.services.OrderDetail;

import com.example.dalathasfarm.dtos.OrderDetailDto;
import com.example.dalathasfarm.exceptions.DataNotFoundException;
import com.example.dalathasfarm.models.OrderDetail;

import java.util.List;

public interface IOrderDetailService {
    OrderDetail createOrderDetail(OrderDetailDto orderDetailDto) throws Exception;
    OrderDetail getOrderDetailById(Integer id) throws Exception;
    OrderDetail updateOrderDetail(Integer id, OrderDetailDto orderDetailDto) throws DataNotFoundException;
    void deleteOrderDetail(Integer id);
    List<OrderDetail> getOrderDetailByOrderId(Integer orderId) throws Exception;
}
