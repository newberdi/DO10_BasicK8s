package com.s21.devops.sample.gatewayservice;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MetricsConfig {

    @Bean
    public Counter gatewayRequests(MeterRegistry registry) {
        return Counter.builder("app.gateway.requests.total")
                .description("Total requests to gateway")
                .register(registry);
    }
}
