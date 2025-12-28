package com.example.dalathasfarm.models;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@Builder
public class DailyRevenue {
    private LocalDate date;
    private BigDecimal revenue;
    private double changePercent;
}
