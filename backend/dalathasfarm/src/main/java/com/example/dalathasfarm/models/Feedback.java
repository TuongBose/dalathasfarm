package com.example.dalathasfarm.models;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "feedbacks")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Feedback extends BaseEntity{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String content;

    @Column(nullable = false)
    private Integer star;

    @ManyToOne
    @JoinColumn(name = "product_id", nullable = false)
    private Product product;

    @JoinColumn(name = "is_active")
    private Boolean isActive;

    @JoinColumn(name = "is_delete")
    private Boolean isDelete;
}
