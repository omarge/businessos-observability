# BusinessOS Observability Stack

Enterprise-grade open-source observability platform for all BusinessOS / Kashbit engines (merchant, payment, fraud, financial-subledger, settlement, treasury, payout, reconciliation, chargeback-disputes, transport-fabric, security) and the aggregator integration layer.

## Stack (LGTM + more)

| Component | Purpose | Port |
|-----------|---------|------|
| **Grafana** | Unified UI (metrics, logs, traces, alerts) | 3000 |
| **Prometheus** | Metrics TSDB + alert evaluation | 9090 |
| **Loki** | Log aggregation | 3100 |
| **Tempo** | Distributed tracing | 3200 |
| **Alertmanager** | Alert routing, grouping, silencing | 9093 |
| **OpenTelemetry Collector** | OTLP receiver (metrics/logs/traces) | 4317 (gRPC), 4318 (HTTP) |
| **Grafana Alloy** | Unified agent for metrics, logs, traces (Docker discovery) | 12345 |
| **node-exporter** | Host metrics | 9100 |
| **cAdvisor** | Container metrics | 8080 |
| **Kafka Exporter** | Kafka consumer lag, topic metrics | 9308 |
| **Postgres Exporter** | PostgreSQL metrics | 9187 |

## Signals covered

- **Metrics**: Micrometer (Java engines) + Prometheus scrape + OTLP. Includes reliability (outbox/inbox), security decisions, reconciliation, health probes, JVM, Kafka lag, Postgres.
- **Logs**: Structured logs from engines (via Alloy or OTLP) with trace_id correlation. Error rates, unknown states, quarantine events.
- **Traces**: OpenTelemetry (Java agent or SDK) for end-to-end payment/settlement/payout flows. Correlated to logs and metrics.
- **Alerts**: Money-critical rules (liveness, Postgres down, Kafka down, reconciliation lag, unknown state) + RED metrics, lag, error rates.

## Quick start

```bash
cp .env.example .env
# Edit .env with your Kafka/Postgres endpoints if needed
docker compose up -d
```

Open Grafana: http://localhost:3000 (admin / admin)

Pre-provisioned dashboards will appear under the BusinessOS folder.

## Instrumenting engines

See the `instrumentation/` directory for:
- Adding `micrometer-registry-prometheus` + `/metrics` scrape endpoint to any Java engine.
- OpenTelemetry Java agent or manual SDK for traces + logs.
- Recommended metric names that match the dashboards and the existing metrics classes in the aggregator (`ReliabilityMetrics`, `SecurityMetrics`, `ReconciliationMetrics`, `HealthProbeMetrics`).

The aggregator already instruments reliability, security, reconciliation and health. Expose its MeterRegistry via Prometheus and add the scrape target.

## Enterprise features

- Cardinality control (no high-cardinality tags on business metrics).
- Correlation between traces, logs and metrics.
- Retention policies, remote-write ready for Mimir.
- Alertmanager with severity routing.
- Dashboards-as-code.
- Kafka + Postgres exporters.
- Fail-closed health probes as gauges.

## Production notes

This compose is suitable for staging / single-node. For full enterprise scale:
- Replace Prometheus with Grafana Mimir.
- Use object storage for Loki and Tempo.
- Deploy Alloy / OTel Collector as DaemonSets on Kubernetes.
- Consider Grafana Cloud or Enterprise for advanced RBAC and on-call.

Official minimal alternative: `grafana/otel-lgtm` image.
