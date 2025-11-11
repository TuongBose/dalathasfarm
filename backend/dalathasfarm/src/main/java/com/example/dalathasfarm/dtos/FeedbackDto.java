package com.example.dalathasfarm.dtos;

import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Getter
@Setter
public class FeedbackDto {
    private int userId;
    private String content;
    private int star;
    private int productId;
}
