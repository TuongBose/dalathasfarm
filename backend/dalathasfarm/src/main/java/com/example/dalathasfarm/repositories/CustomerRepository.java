package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.Customer;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CustomerRepository extends JpaRepository<Integer, Customer> {
}
