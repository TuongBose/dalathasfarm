package com.example.dalathasfarm.services.Dashboard;

import com.example.dalathasfarm.models.DailyRevenue;
import com.example.dalathasfarm.models.DashboardStats;
import com.example.dalathasfarm.models.Product;
import com.example.dalathasfarm.models.TopProduct;
import com.example.dalathasfarm.repositories.OrderDetailRepository;
import com.example.dalathasfarm.repositories.OrderRepository;
import com.example.dalathasfarm.repositories.ProductRepository;
import com.example.dalathasfarm.repositories.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DashboardService {
    private final OrderRepository orderRepository;
    private final OrderDetailRepository orderDetailRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;

    // 1. Sản phẩm sắp hết hàng (stock < 10)
    public List<Product> getLowStockProducts(int threshold) {
        return productRepository.findByStockQuantityLessThanOrderByStockQuantityAsc(threshold);
    }

    // 2. Tổng doanh thu + số đơn theo ngày/tuần/tháng
    public DashboardStats getStats(LocalDate date) {
        LocalDate startOfDay = date;
        LocalDate endOfDay = date.plusDays(1);

        LocalDate startOfWeek = date.with(java.time.DayOfWeek.MONDAY);
        LocalDate endOfWeek = date.with(java.time.DayOfWeek.SUNDAY).plusDays(1);

        LocalDate startOfMonth = date.withDayOfMonth(1);
        LocalDate endOfMonth = date.withDayOfMonth(date.lengthOfMonth()).plusDays(1);

        BigDecimal revenueToday = orderRepository.sumTotalMoneyByDateRange(startOfDay, endOfDay);
        long ordersToday = orderRepository.countByDateRange(startOfDay, endOfDay);

        BigDecimal revenueWeek = orderRepository.sumTotalMoneyByDateRange(startOfWeek, endOfWeek);
        long ordersWeek = orderRepository.countByDateRange(startOfWeek, endOfWeek);

        BigDecimal revenueMonth = orderRepository.sumTotalMoneyByDateRange(startOfMonth, endOfMonth);
        long ordersMonth = orderRepository.countByDateRange(startOfMonth, endOfMonth);

        return DashboardStats.builder()
                .revenueToday(revenueToday != null ? revenueToday : BigDecimal.ZERO)
                .ordersToday(ordersToday)
                .revenueWeek(revenueWeek != null ? revenueWeek : BigDecimal.ZERO)
                .ordersWeek(ordersWeek)
                .revenueMonth(revenueMonth != null ? revenueMonth : BigDecimal.ZERO)
                .ordersMonth(ordersMonth)
                .build();
    }

    // 3. Số lượng khách mới trong tháng
    public long getNewCustomersThisMonth() {
        LocalDate now = LocalDate.now();
        LocalDate startOfMonth = now.withDayOfMonth(1);
        LocalDate endOfMonth = now.withDayOfMonth(now.lengthOfMonth()).plusDays(1);

        return userRepository.countByRoleIdAndCreatedAtBetween(3, startOfMonth.atStartOfDay(), endOfMonth.atStartOfDay());
    }

    // 4. Doanh thu 10 ngày gần nhất
    public List<DailyRevenue> getLast10DaysRevenue() {
        LocalDate endDate = LocalDate.now();
        LocalDate startDate = endDate.minusDays(9);

        List<Object[]> results = orderRepository.getDailyRevenue(startDate, endDate.plusDays(1));

        List<DailyRevenue> dailyRevenues = new ArrayList<>();
        BigDecimal previousRevenue = BigDecimal.ZERO;

        for (int i = 0; i < 10; i++) {
            LocalDate date = startDate.plusDays(i);
            BigDecimal revenue = BigDecimal.ZERO;

            for (Object[] row : results) {
                LocalDate rowDate = ((java.sql.Date) row[0]).toLocalDate();
                if (rowDate.equals(date)) {
                    revenue = (BigDecimal) row[1];
                    break;
                }
            }

            double changePercent = previousRevenue.compareTo(BigDecimal.ZERO) == 0 ? 0 :
                    revenue.subtract(previousRevenue).divide(previousRevenue, 4, RoundingMode.HALF_UP)
                            .multiply(BigDecimal.valueOf(100)).doubleValue();

            dailyRevenues.add(DailyRevenue.builder()
                    .date(date)
                    .revenue(revenue)
                    .changePercent(changePercent)
                    .build());

            previousRevenue = revenue;
        }

        return dailyRevenues;
    }

    // 5. Top 5 sản phẩm bán chạy
    public List<TopProduct> getTopProducts(Period period) {
        LocalDate end = LocalDate.now();
        LocalDate start;

        switch (period) {
            case TODAY -> start = end;
            case WEEK -> start = end.minusDays(6);
            case MONTH -> start = end.withDayOfMonth(1);
            default -> start = end;
        }

        List<Object[]> rawResults = orderDetailRepository.getTopRawProducts(start, end.plusDays(1), 5);

        return rawResults.stream()
        .map(row -> TopProduct.builder()
            .productId(((Number) row[0]).intValue())
            .productName((String) row[1])
            .thumbnail((String) row[2])
            .quantitySold(((Number) row[3]).longValue())
            .revenue((BigDecimal) row[4])
            .build())
        .toList();
    }

    public enum Period {
        TODAY, WEEK, MONTH
    }
}
