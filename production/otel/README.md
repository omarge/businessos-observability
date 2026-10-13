# OpenTelemetry Java Agent — Production

## 1. Download the agent (once per host or bake into image)

```bash
mkdir -p /opt/otel
curl -L -o /opt/otel/opentelemetry-javaagent.jar \
  https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar
```

## 2. Source the environment before starting each engine

```bash
source /path/to/businessos-observability/production/otel/javaagent-env.sh
export ENGINE_NAME=payment-engine   # or fraud-engine, treasury-liquidity-engine, etc.
java -jar payment-engine.jar
```

Or in Docker / Kubernetes set the same env vars and mount the agent jar.

## 3. Verify

- Collector receives on `4317`.
- Tempo shows traces in Grafana → Distributed Traces.
- Logs with `trace_id` appear in Loki.

Metrics continue to be scraped by Prometheus (agent has `OTEL_METRICS_EXPORTER=none`).
