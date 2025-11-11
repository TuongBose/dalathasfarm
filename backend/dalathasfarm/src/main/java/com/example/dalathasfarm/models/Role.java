package com.example.dalathasfarm.models;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "roles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder

public class Role {
    public static final int ADMIN = 1;
    public static final int EMPLOYEE = 2;
    public static final int CUSTOMER = 3;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, unique = true)
    private String name;
}
