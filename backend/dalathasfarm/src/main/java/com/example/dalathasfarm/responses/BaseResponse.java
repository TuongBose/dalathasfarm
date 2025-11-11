package com.example.dalathasfarm.responses;

import lombok.*;

import java.time.LocalDateTime;

@Data
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class BaseResponse {
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
