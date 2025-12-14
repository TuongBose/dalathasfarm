package com.example.dalathasfarm.dtos;

import jakarta.validation.constraints.NotNull;
import lombok.*;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class SupplierDto {
    @NotNull(message = "Tên nhà cung cấp không được bỏ trống")
    private String name;

    private String address;

    @NotNull(message = "Số điện thoại nhà cung cấp không được bỏ trống")
    private String phoneNumber;

    private String email;
}
