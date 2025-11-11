package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.Order;
import com.example.dalathasfarm.models.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface OrderRepository extends JpaRepository<Order, Integer> {
    List<Order> findByUser(User user);

    @Query("SELECT o FROM Order o WHERE " +
            "(:keyword IS NULL OR :keyword = '' OR o.fullName LIKE %:keyword% OR o.address LIKE %:keyword% " +
            "OR o.note LIKE %:keyword% OR o.email LIKE %:keyword%)")
    Page<Order> findByKeyword(@Param("keyword") String keyword, Pageable pageable);

    Optional<Order> findByVnpTxnRef(String vnpTxnRef);
}
