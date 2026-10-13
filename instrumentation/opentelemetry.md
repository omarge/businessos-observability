# Instrumentación de traces con OpenTelemetry

Para correlacionar traces con logs y métricas en Tempo.

## Opción 1: Java Agent (recomendada, zero-code)

Descarga el agent:
```bash
wget https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar
```

Arranca el engine:
```bash
java -javaagent:opentelemetry-javaagent.jar \
  -Dotel.service.name=payment-engine \
  -Dotel.exporter.otlp.endpoint=http://localhost:4317 \
  -Dotel.metrics.exporter=none \
  -Dotel.logs.exporter=otlp \
  -jar payment-engine.jar
```

El Collector del stack (`otel-collector`) recibe en `4317` y exporta a Tempo + Loki.

## Opción 2: SDK manual (Spring Boot)

```gradle
implementation 'io.opentelemetry:opentelemetry-api'
implementation 'io.opentelemetry:opentelemetry-sdk'
implementation 'io.opentelemetry:opentelemetry-exporter-otlp'
```

Usa `@WithSpan` o el API de Tracer en los servicios críticos (authorize, evaluate, settle).

## Correlación

- Asegura que los logs incluyan `trace_id` (el agent lo hace automáticamente con logback/log4j2).
- En Grafana, desde un trace puedes saltar a logs y viceversa.

## Variables de entorno útiles

| Variable | Valor ejemplo |
|----------|---------------|
| `OTEL_SERVICE_NAME` | `payment-engine` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | `http://otel-collector:4317` |
| `OTEL_TRACES_EXPORTER` | `otlp` |
| `OTEL_METRICS_EXPORTER` | `none` (ya usamos Prometheus) |
| `OTEL_LOGS_EXPORTER` | `otlp` |
