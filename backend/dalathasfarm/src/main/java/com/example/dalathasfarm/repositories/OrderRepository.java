package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.Order;
import com.example.dalathasfarm.models.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface OrderRepository extends JpaRepository<Order, Integer> {
    List<Order> findByUser(User user);

    @Query("SELECT o FROM Order o WHERE " +
            "(:keyword IS NULL OR :keyword = '' OR o.fullName LIKE %:keyword% OR o.address LIKE %:keyword% " +
            "OR o.note LIKE %:keyword% OR o.email LIKE %:keyword%)")
    Page<Order> findByKeyword(@Param("keyword") String keyword, Pageable pageable);

    Optional<Order> findByVnpTxnRef(String vnpTxnRef);

    @Query("SELECT SUM(o.totalMoney) FROM Order o WHERE o.orderDate >= :start AND o.orderDate < :end AND o.status = 'Processing'")
    BigDecimal sumTotalMoneyByDateRange(@Param("start") LocalDate start, @Param("end") LocalDate end);

    @Query("SELECT COUNT(o) FROM Order o WHERE o.orderDate >= :start AND o.orderDate < :end AND o.status = 'Processing'")
    long countByDateRange(@Param("start") LocalDate start, @Param("end") LocalDate end);

    @Query(value = """
            SELECT DATE(o.order_date) as orderDate, COALESCE(SUM(o.total_money), 0) as revenue
            FROM orders o
            WHERE o.order_date >= :start AND o.order_date < :end AND o.status = 'Processing'
            GROUP BY DATE(o.order_date)
            ORDER BY orderDate
            """, nativeQuery = true)
    List<Object[]> getDailyRevenue(@Param("start") LocalDate start, @Param("end") LocalDate end);
}
