package com.example.dalathasfarm.controllers;

import com.example.dalathasfarm.responses.ResponseObject;
import com.example.dalathasfarm.services.Dashboard.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.Map;

@RestController
@RequestMapping("${api.prefix}/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping
    @PreAuthorize("hasRole('ROLE_ADMIN') or hasRole('ROLE_EMPLOYEE')")
    public ResponseEntity<ResponseObject> getDashboard() {
        LocalDate today = LocalDate.now();

        return ResponseEntity.ok(ResponseObject.builder()
                .status(HttpStatus.OK)
                .message("Dashboard data")
                .data(Map.of(
                        "lowStockProducts", dashboardService.getLowStockProducts(10),
                        "stats", dashboardService.getStats(today),
                        "newCustomersThisMonth", dashboardService.getNewCustomersThisMonth(),
                        "last10DaysRevenue", dashboardService.getLast10DaysRevenue(),
                        "topProductsToday", dashboardService.getTopProducts(DashboardService.Period.TODAY),
                        "topProductsWeek", dashboardService.getTopProducts(DashboardService.Period.WEEK),
                        "topProductsMonth", dashboardService.getTopProducts(DashboardService.Period.MONTH)
                ))
                .build());
    }
}
