# Instrumenting Java Engines with Micrometer + Prometheus

All BusinessOS engines are expected to be Java (Spring Boot or plain). The aggregator already uses Micrometer.

## 1. Dependencies (Gradle)

```gradle
implementation 'io.micrometer:micrometer-core:1.14.2'
implementation 'io.micrometer:micrometer-registry-prometheus:1.14.2'
```

## 2. Expose /metrics endpoint (plain Java example)

```java
import io.micrometer.prometheus.PrometheusMeterRegistry;
import io.micrometer.prometheus.PrometheusConfig;
import com.sun.net.httpserver.HttpServer;
import java.net.InetSocketAddress;

public class MetricsExporter {
    public static void start(PrometheusMeterRegistry registry, int port) throws Exception {
        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);
        server.createContext("/metrics", exchange -> {
            String body = registry.scrape();
            exchange.getResponseHeaders().set("Content-Type", "text/plain; version=0.0.4");
            exchange.sendResponseHeaders(200, body.getBytes().length);
            exchange.getResponseBody().write(body.getBytes());
            exchange.close();
        });
        server.start();
    }
}
```

Wire the same MeterRegistry that your ReliabilityMetrics / SecurityMetrics / etc. use.

## 3. Recommended metric names (already used in aggregator)

- `businessos_integration_outbox_*`
- `businessos_integration_inbox_*`
- `businessos_integration_security_*`
- `businessos_integration_reconciliation_*`
- `businessos_health_probe{probe="..."}`
- `businessos_readiness`, `businessos_liveness`

Add engine-specific counters with low-cardinality tags only (e.g. `engine="payment"`, `status="success"`).

## 4. OpenTelemetry (optional but recommended for traces)

Use the OpenTelemetry Java agent:

```bash
java -javaagent:opentelemetry-javaagent.jar \
  -Dotel.service.name=payment-engine \
  -Dotel.exporter.otlp.endpoint=http://otel-collector:4318 \
  -jar your-engine.jar
```

Or the Micrometer OTel bridge for automatic metrics export via OTLP.

## 5. Structured logs

Use Logback/Log4j2 JSON encoder and include `trace_id` / `span_id` (MDC). Alloy will pick them up from Docker stdout.
