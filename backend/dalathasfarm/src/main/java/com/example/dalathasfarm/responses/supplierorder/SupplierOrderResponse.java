package com.example.dalathasfarm.responses.supplierorder;

import com.example.dalathasfarm.models.Supplier;
import com.example.dalathasfarm.models.SupplierOrder;
import com.example.dalathasfarm.models.SupplierOrderDetail;
import com.example.dalathasfarm.responses.orderdetail.OrderDetailResponse;
import com.example.dalathasfarm.responses.supplierorderdetail.SupplierOrderDetailResponse;
import com.example.dalathasfarm.responses.user.UserResponse;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class SupplierOrderResponse {
    private Integer id;
    private Supplier supplier;
    private UserResponse userResponse;
    private LocalDateTime orderDate;
    private String status;
    private BigDecimal totalMoney;
    private String note;
    private String orderFile;
    private List<SupplierOrderDetailResponse>supplierOrderDetailResponses;

    public static SupplierOrderResponse fromSupplierOrder(SupplierOrder supplierOrder, List<SupplierOrderDetailResponse> supplierOrderDetailResponses) {
        return SupplierOrderResponse.builder()
                .id(supplierOrder.getId())
                .supplier(supplierOrder.getSupplier())
                .userResponse(UserResponse.fromUser(supplierOrder.getUser()))
                .orderDate(supplierOrder.getOrderDate())
                .status(supplierOrder.getStatus().name())
                .totalMoney(supplierOrder.getTotalMoney())
                .note(supplierOrder.getNote())
                .orderFile(supplierOrder.getOrderFile())
                .supplierOrderDetailResponses(supplierOrderDetailResponses)
                .build();
    }
}
