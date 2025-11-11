package com.example.dalathasfarm.controllers;


import com.example.dalathasfarm.responses.ResponseObject;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.InetAddress;

@RestController
@RequestMapping("${api.prefix}/healthcheck")
public class HealthCheckController {
    @GetMapping("/health")
    public ResponseEntity<ResponseObject> healthCheck() throws Exception {
        String computerName = InetAddress.getLocalHost().getHostName();
        return ResponseEntity.ok(ResponseObject.builder()
                .message("ok, Computer Name: " + computerName)
                .status(HttpStatus.OK)
                .build());
    }
}
