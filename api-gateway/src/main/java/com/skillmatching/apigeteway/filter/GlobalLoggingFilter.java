package com.skillmatching.apigeteway.filter;

import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.time.LocalDateTime;

@Component
public class GlobalLoggingFilter implements GlobalFilter {

    private static final Logger logger = LoggerFactory.getLogger(GlobalLoggingFilter.class);

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {

        long startTime = System.currentTimeMillis();
        String method = exchange.getRequest().getMethod().toString();
        String path = exchange.getRequest().getPath().toString();

        logger.info("[{}] {} - Started at: {}", method, path, LocalDateTime.now());

        return chain.filter(exchange).doFinally(signalType -> {
            long duration = System.currentTimeMillis() - startTime;
            int status = exchange.getResponse().getStatusCode() != null ?
                    exchange.getResponse().getStatusCode().value() : 0;

            logger.info("[{}] {} - Status: {} - Duration: {}ms",
                    method, path, status, duration);
        });
    }
}