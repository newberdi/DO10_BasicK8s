package com.s21.devops.sample.bookingservice;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MetricsConfig {

    @Bean
    public Counter bookingsCounter(MeterRegistry registry) {
        return Counter.builder("app.bookings.total")
                .description("Total number of bookings")
                .register(registry);
    }

    @Bean
    public Counter rabbitmqSentMessages(MeterRegistry registry) {
        return Counter.builder("app.rabbitmq.messages.sent")
                .description("Number of messages sent to RabbitMQ")
                .register(registry);
    }
}
