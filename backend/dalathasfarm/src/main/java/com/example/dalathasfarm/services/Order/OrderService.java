package com.example.dalathasfarm.services.Order;

import com.example.dalathasfarm.components.LocalizationUtils;
import com.example.dalathasfarm.dtos.CartItemDto;
import com.example.dalathasfarm.dtos.OrderDto;
import com.example.dalathasfarm.exceptions.DataNotFoundException;
import com.example.dalathasfarm.models.*;
import com.example.dalathasfarm.repositories.*;
import com.example.dalathasfarm.responses.order.OrderResponse;
import com.example.dalathasfarm.responses.orderdetail.OrderDetailResponse;
import com.example.dalathasfarm.utils.MessageKeys;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OrderService implements IOrderService {
    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final ProductRepository productRepository;
    private final OrderDetailRepository orderDetailRepository;
    private final CouponRepository couponRepository;
    private final LocalizationUtils localizationUtils;
    private final NotificationRepository notificationRepository;
    private final ModelMapper modelMapper;

    @Override
    public OrderResponse createOrder(OrderDto orderDto) throws Exception {
        // Tìm xem User có tồn tại không
        User existingUser = userRepository
                .findById(orderDto.getUserId())
                .orElseThrow(() -> new RuntimeException("User does not exists"));

        // Convert OrderDto => Order, dùng thư viện Model Mapper
        // Tạo 1 luồng bảng ánh xạ riêng để kiểm soát việc ánh xạ
        modelMapper.typeMap(OrderDto.class, Order.class)
                .addMappings(mapper -> mapper.skip(Order::setId));

        // Cập nhật các trường của Order từ OrderDto
        Order order = new Order();
        modelMapper.map(orderDto, order);
        order.setUser(existingUser);
        order.setOrderDate(LocalDate.now());
        order.setStatus(Order.OrderStatus.Pending);
        order.setIsActive(true);
        order.setTotalMoney(orderDto.getTotalPrice());

        if ("BankTransfer".equalsIgnoreCase(orderDto.getPaymentMethod()) && orderDto.getVnpTxnRef() != null) {
            order.setVnpTxnRef(orderDto.getVnpTxnRef());
        }

        // Xu ly coupon
        String couponCode = orderDto.getCouponCode();
        if (couponCode != null) {
            Coupon coupon = couponRepository.findByCode(couponCode)
                    .orElseThrow(() -> new IllegalArgumentException("Coupon not found"));

            if (!coupon.getIsActive()) {
                throw new IllegalArgumentException("Coupon is not active");
            }

            order.setCoupon(coupon);
        } else {
            order.setCoupon(null);
        }

        orderRepository.save(order);

        List<OrderDetail> orderDetails = new ArrayList<>();
        for (CartItemDto cartItemDto : orderDto.getCartItems()) {
            OrderDetail orderDetail = new OrderDetail();
            orderDetail.setOrder(order);
            int productId = cartItemDto.getProductId();
            int quantity = cartItemDto.getQuantity();

            Product product = productRepository.findById(productId)
                    .orElseThrow(() -> new RuntimeException("Product ID does not exists"));

            orderDetail.setProduct(product);
            orderDetail.setQuantity(quantity);
            orderDetail.setPrice(product.getPrice());
            orderDetail.setTotalMoney(product.getPrice().multiply(BigDecimal.valueOf(quantity)));
            orderDetail.setCoupon(order.getCoupon());

            if (quantity > product.getStockQuantity()) {
                throw new RuntimeException("Quantity in stock does not enough");
            } else {
                product.setStockQuantity(product.getStockQuantity() - quantity);
            }

            orderDetails.add(orderDetail);
        }

        orderDetailRepository.saveAll(orderDetails);

        List<OrderDetailResponse> orderDetailResponses = orderDetails.stream().map(OrderDetailResponse::fromOrderDetail).toList();
        OrderResponse orderResponse = modelMapper.map(order, OrderResponse.class);
        orderResponse.setOrderDetailResponses(orderDetailResponses);

        Notification newNotification = Notification.builder()
                .user(existingUser)
                .title(localizationUtils.getLocalizedMessage(MessageKeys.CREATE_DONHANG_SUCCESSFULLY, orderResponse.getId()))
                .content("Join us to protect your rights, only receive goods and pay when the order is in \"delivery\" status")
                .type(Notification.Importance.Normal)
                .isRead(false)
                .build();
        notificationRepository.save(newNotification);

        return orderResponse;
    }

    @Override
    public OrderResponse getOrderById(Integer id) throws Exception {
        Order existingOrder = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Cannot find Order"));

        modelMapper.typeMap(Order.class, OrderResponse.class);
        OrderResponse orderResponse = modelMapper.map(existingOrder, OrderResponse.class);

        List<OrderDetail> orderDetails = orderDetailRepository.findByOrder(existingOrder);
        List<OrderDetailResponse> orderDetailResponses = new ArrayList<>();

        if (orderDetails.isEmpty())
            orderResponse.setOrderDetailResponses(null);
        else {
            for (OrderDetail orderDetail : orderDetails) {
                orderDetailResponses.add(OrderDetailResponse.fromOrderDetail(orderDetail));
            }
            orderResponse.setOrderDetailResponses(orderDetailResponses);
        }

        return orderResponse;
    }

    @Override
    public List<Order> getOrderByUserId(Integer userId) throws Exception {
        User existingUser = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Cannot find User"));
        return orderRepository.findByUser(existingUser);
    }

    @Override
    public Order updateOrder(Integer id, OrderDto orderDto) throws Exception {
        Order existingOrder = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Cannot find Order"));
        User existingUser = userRepository.findById(orderDto.getUserId())
                .orElseThrow(() -> new RuntimeException("Cannot find User"));

        existingOrder.setUser(existingUser);

        if (orderDto.getFullName() != null && !orderDto.getFullName().trim().isEmpty()) {
            existingOrder.setFullName(orderDto.getFullName());
        }
        if (orderDto.getEmail() != null && !orderDto.getEmail().trim().isEmpty()) {
            existingOrder.setEmail(orderDto.getEmail().trim());
        }
        if (orderDto.getPhoneNumber() != null && !orderDto.getPhoneNumber().trim().isEmpty()) {
            existingOrder.setPhoneNumber(orderDto.getPhoneNumber().trim());
        }
        if (orderDto.getAddress() != null && !orderDto.getAddress().trim().isEmpty()) {
            existingOrder.setAddress(orderDto.getAddress());
        }
        if (orderDto.getNote() != null && !orderDto.getNote().trim().isEmpty()) {
            existingOrder.setNote(orderDto.getNote());
        }
        if (orderDto.getTotalPrice() != null) {
            existingOrder.setTotalMoney(orderDto.getTotalPrice());
        }
        if (orderDto.getPaymentMethod() != null && !orderDto.getPaymentMethod().trim().isEmpty()) {
            try {
                Order.PaymentMethod newPaymentMethod = Order.PaymentMethod.valueOf(orderDto.getPaymentMethod().trim());
                existingOrder.setPaymentMethod(newPaymentMethod);
            } catch (IllegalArgumentException e) {
                throw new IllegalArgumentException("Invalid order status: " + orderDto.getPaymentMethod());
            }
        }
        if (orderDto.getStatus() != null && !orderDto.getStatus().trim().isEmpty()) {
            try {
                Order.OrderStatus newStatus = Order.OrderStatus.valueOf(orderDto.getStatus().trim());
                existingOrder.setStatus(newStatus);
            } catch (IllegalArgumentException e) {
                // Nếu status gửi lên không hợp lệ (không nằm trong enum)
                throw new IllegalArgumentException("Invalid order status: " + orderDto.getStatus());
            }
        }

        orderRepository.save(existingOrder);
        return existingOrder;
    }

    @Override
    public void deleteOrder(Integer id) throws Exception {
        Order existingOrder = orderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Cannot find Order"));

        if (existingOrder != null) {
            existingOrder.setIsActive(false);
            orderRepository.save(existingOrder);
        }
    }

    @Override
    public Page<OrderResponse> getAllOrderByKeyword(String keyword, Pageable pageable) {
        Page<Order> orderPage = orderRepository.findByKeyword(keyword, pageable);
        return orderPage.map(order -> {
            List<OrderDetailResponse> orderDetailResponses = orderDetailRepository.findByOrder(order)
                    .stream()
                    .map(OrderDetailResponse::fromOrderDetail)
                    .collect(Collectors.toList());
            return OrderResponse.fromOrder(order, orderDetailResponses);
        });
    }

    @Override
    public OrderResponse updateStatus(String status, String vnpTxnRef) throws Exception {
        Optional<Order> orderOptional = orderRepository.findByVnpTxnRef(vnpTxnRef);

        if (orderOptional.isEmpty()) {
            throw new DataNotFoundException("Does not exist Order");
        }

        Order existingOrder = orderOptional.get();
        if (status != null && !status.trim().isEmpty()) {
            try {
                Order.OrderStatus newStatus = Order.OrderStatus.valueOf(status.trim());
                existingOrder.setStatus(newStatus);
            } catch (IllegalArgumentException e) {
                // Nếu status gửi lên không hợp lệ (không nằm trong enum)
                throw new IllegalArgumentException("Invalid order status: " + status);
            }
        }
        orderRepository.save(existingOrder);


        List<OrderDetailResponse> orderDetailResponses = orderDetailRepository.findByOrder(existingOrder)
                .stream()
                .map(OrderDetailResponse::fromOrderDetail)
                .collect(Collectors.toList());

        OrderResponse orderResponse = OrderResponse.fromOrder(existingOrder, orderDetailResponses);

        User existingUser = userRepository.findById(orderResponse.getUserId())
                .orElseThrow(() -> new DataNotFoundException(localizationUtils.getLocalizedMessage(MessageKeys.USER_NOT_FOUND)));

        Notification newNotification = Notification.builder()
                .user(existingUser)
                .title("Order with ID: " + orderResponse.getId() + " have been " + status)
                .content("Join us to protect your rights, only receive goods and pay when the order is in \"delivery\" status")
                .type(Notification.Importance.Normal)
                .isRead(false)
                .build();
        notificationRepository.save(newNotification);

        return orderResponse;
    }
}
