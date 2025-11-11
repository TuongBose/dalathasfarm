package com.example.dalathasfarm.responses;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;
import org.springframework.http.HttpStatus;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ResponseObject {
    private String message;
    private HttpStatus status;
    private Object data;
}
