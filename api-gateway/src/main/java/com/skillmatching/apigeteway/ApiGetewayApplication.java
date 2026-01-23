package com.skillmatching.apigeteway;


import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.gateway.route.RouteLocator;
import org.springframework.cloud.gateway.route.builder.RouteLocatorBuilder;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class ApiGetewayApplication {

	public static void main(String[] args) {
		SpringApplication.run(ApiGetewayApplication.class, args);
	}

	@Bean
	public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
		return builder.routes()
				.route("user-service", r -> r
						.path("/api/users/**")
						.uri("http://user-service:8081"))
				.route("profile-service", r -> r
						.path("/api/profiles/**")
						.uri("http://profile-service:8082"))
				.route("job-service", r -> r
						.path("/api/jobs/**")
						.uri("http://job-service:8083"))
				.route("matching-service", r -> r
						.path("/api/matches/**")
						.uri("http://matching-service:8084"))
				.route("notification-service", r -> r
						.path("/api/notifications/**")
						.uri("http://notification-service:8085"))
				.route("messaging-service", r -> r
						.path("/api/messages/**")
						.uri("http://messaging-service:8086"))
				.build();
	}
}