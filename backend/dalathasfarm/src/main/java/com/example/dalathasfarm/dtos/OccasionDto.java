package com.example.dalathasfarm.dtos;

import lombok.*;

import java.util.Date;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Getter
@Setter
public class OccasionDto {
    private String name;
    private String thumbnail;
    private Date startDate;
    private Date endDate;
    private String bannerImage;
}
