package com.example.dalathasfarm.services.OrderDetail;

import com.example.dalathasfarm.dtos.OrderDetailDto;
import com.example.dalathasfarm.exceptions.DataNotFoundException;
import com.example.dalathasfarm.models.Order;
import com.example.dalathasfarm.models.OrderDetail;
import com.example.dalathasfarm.models.Product;
import com.example.dalathasfarm.repositories.OrderDetailRepository;
import com.example.dalathasfarm.repositories.OrderRepository;
import com.example.dalathasfarm.repositories.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class OrderDetailService implements IOrderDetailService {
    private final OrderDetailRepository orderDetailRepository;
    private final ProductRepository productRepository;
    private final OrderRepository orderRepository;

    @Override
    public OrderDetail createOrderDetail(OrderDetailDto orderDetailDto) throws Exception {
        Order existingOrder = orderRepository.findById(orderDetailDto.getOrderId())
                .orElseThrow(() -> new RuntimeException("Cannot find Order"));

        Product existingProduct = productRepository.findById(orderDetailDto.getProductId())
                .orElseThrow(() -> new RuntimeException("Cannot find Product"));

        OrderDetail newOrderDetail = OrderDetail
                .builder()
                .order(existingOrder)
                .product(existingProduct)
                .quantity(orderDetailDto.getQuantity())
                .price(orderDetailDto.getPrice())
                .totalMoney(orderDetailDto.getTotalPrice())
                .build();

        return orderDetailRepository.save(newOrderDetail);
    }

    @Override
    public OrderDetail getOrderDetailById(Integer id) throws Exception {
        return orderDetailRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Cannot find OrderDetail with id: " + id));
    }

    @Override
    public OrderDetail updateOrderDetail(Integer id, OrderDetailDto orderDetailDto) throws DataNotFoundException {
        OrderDetail existingOrderDetail = orderDetailRepository.findById(id)
                .orElseThrow(() -> new DataNotFoundException("Cannot find OrderDetail with id: " + id));

        Order existingOrder = orderRepository.findById(orderDetailDto.getOrderId())
                .orElseThrow(() -> new RuntimeException("Cannot find Order"));

        Product existingProduct = productRepository.findById(orderDetailDto.getProductId())
                .orElseThrow(() -> new RuntimeException("Cannot find Product"));

        existingOrderDetail.setOrder(existingOrder);
        existingOrderDetail.setProduct(existingProduct);
        existingOrderDetail.setQuantity(orderDetailDto.getQuantity());
        existingOrderDetail.setPrice(orderDetailDto.getPrice());
        existingOrderDetail.setTotalMoney(orderDetailDto.getTotalPrice());

        orderDetailRepository.save(existingOrderDetail);
        return existingOrderDetail;
    }

    @Override
    public void deleteOrderDetail(Integer id) {
        orderDetailRepository.deleteById(id);
    }

    @Override
    public List<OrderDetail> getOrderDetailByOrderId(Integer orderId) throws Exception {
        Order existingOrder = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Cannot find Order"));
        return orderDetailRepository.findByOrder(existingOrder);
    }
}
