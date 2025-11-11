package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Integer> {
    boolean existsByPhoneNumber(String phoneNumber);
    boolean existsByEmail(String email);

    Optional<User> findByPhoneNumber(String phoneNumber);
    // SELECT * FROM USERS WHERE PHONENUMBER = ?

    Optional<User> findByEmail(String email);
    // SELECT * FROM USERS WHERE EMAIL = ?

    // chua hoan thanh
    @Query("SELECT o FROM User o WHERE o.isActive = true AND o.role.name = 'User' AND (:keyword IS NULL OR :keyword = '' OR " +
            "o.fullName LIKE %:keyword% " +
            "OR o.address LIKE %:keyword% " +
            "OR o.phoneNumber LIKE %:keyword%)")
    Page<User> findAll(@Param("keyword") String keyword, Pageable pageable);

    // doi sang ben user roles
//    List<User> findAllByROLENAMEFalse(); // user
//    List<User> findAllByROLENAMETrue(); // admin
}
