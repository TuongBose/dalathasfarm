package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.Order;
import com.example.dalathasfarm.models.OrderDetail;
import com.example.dalathasfarm.models.TopProduct;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface OrderDetailRepository extends JpaRepository<OrderDetail, Integer> {
    List<OrderDetail> findByOrder(Order order);

    @Query(value = """
            SELECT p.id, p.name, p.thumbnail, SUM(od.quantity) as qty, SUM(od.total_money) as revenue
            FROM order_details od
            JOIN products p ON od.product_id = p.id
            JOIN orders o ON od.order_id = o.id
            WHERE o.order_date >= :start AND o.order_date < :end AND o.status = 'Processing'
            GROUP BY p.id, p.name, p.thumbnail
            ORDER BY qty DESC
            LIMIT :limit
            """, nativeQuery = true)
    List<Object[]> getTopRawProducts(@Param("start") LocalDate start, @Param("end") LocalDate end, @Param("limit") int limit);
}
