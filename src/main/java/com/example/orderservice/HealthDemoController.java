package com.example.orderservice;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthDemoController {

    @Value("${spring.profiles.active:default}")
    private String profile;

    @GetMapping("/api/ping")
    public String ping() {
        return "pong";
    }

    @GetMapping("/api/hello")
    public String hello() {
        return "Hello from " + profile;
    }
}
