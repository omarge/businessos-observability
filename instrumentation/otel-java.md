# OpenTelemetry for BusinessOS Java Engines

## Quick start with Java Agent (recommended)

1. Download the agent: https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases
2. Start any engine with:

```bash
java -javaagent:opentelemetry-javaagent.jar \
  -Dotel.service.name=payment-engine \
  -Dotel.resource.attributes=engine=payment,deployment.environment=prod \
  -Dotel.exporter.otlp.endpoint=http://otel-collector:4318 \
  -Dotel.traces.exporter=otlp \
  -Dotel.metrics.exporter=otlp \
  -Dotel.logs.exporter=otlp \
  -jar engine.jar
```

Traces appear in Tempo, metrics in Prometheus (via collector), logs in Loki.

## Manual SDK (for fine control)

Add dependencies and configure SdkTracerProvider / SdkMeterProvider / SdkLoggerProvider that export via OTLP to the collector.

## Correlation

Always inject `trace_id` into logs (MDC) and into Kafka headers so the aggregator and downstream engines can continue the trace.

See the existing `TransportHeaders` in the aggregator for the canonical header names.
