package com.example.dalathasfarm.models;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Builder
public class DashboardStats {
    private BigDecimal revenueToday;
    private long ordersToday;
    private BigDecimal revenueWeek;
    private long ordersWeek;
    private BigDecimal revenueMonth;
    private long ordersMonth;
}