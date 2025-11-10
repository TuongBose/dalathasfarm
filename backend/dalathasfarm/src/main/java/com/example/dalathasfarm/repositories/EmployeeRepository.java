package com.example.dalathasfarm.repositories;

import com.example.dalathasfarm.models.Employee;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EmployeeRepository extends JpaRepository<Integer, Employee> {
}
