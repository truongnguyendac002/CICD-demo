package com.example.orderservice;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class HealthDemoControllerTest {

    @Test
    void pingShouldReturnPong() {
        final HealthDemoController controller = new HealthDemoController();
        assertThat(controller.ping()).isEqualTo("pong");
    }
}
