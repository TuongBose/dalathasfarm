package com.example.dalathasfarm.responses.order;

import lombok.*;

import java.util.List;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class OrderListResponse {
    private List<OrderResponse> orderResponses;
    private int totalPages;
}
