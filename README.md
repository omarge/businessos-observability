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

## Pre-provisioned Enterprise Dashboards

All dashboards support **multi-tenancy** (tenant variable), correlation with logs/traces, and error troubleshooting:

| Dashboard | Purpose |
|-----------|---------|
| **BusinessOS Multi-Tenant Overview** | Engines health, request rates, latency, active tenants, security denials |
| **Errors & Logs (Troubleshooting)** | Loki-powered error/warn logs, top error messages, trace_id correlation |
| **Kafka & Reliability** | Outbox/inbox, consumer lag, quarantine, by tenant |
| **Payment Engine** | Payment-specific RED metrics + logs, filtered by tenant |
| **Fraud Engine** | Fraud decisions, latency, risk-related errors |
| **Settlement / Payout / Reconciliation** | Breaks, pending reports, outbox, related logs |
| **Distributed Traces** | Tempo TraceQL search, service map, slow traces |
| **Security & Compliance** | Denials, allowed, denial rate, quarantine, policy/audit logs |
| **Audit Trail** | Full audit log trail, security decisions (allowed/denied), quarantine, alerts |
| Plus existing: Overview, Reliability, Security, Engines overview | |

Dashboards appear under the **BusinessOS** folder after `docker compose up`.

## Signals covered

- **Metrics**: Micrometer (Java engines) + Prometheus scrape + OTLP. Includes reliability (outbox/inbox), security decisions, reconciliation, health probes, JVM, Kafka lag, Postgres. Tenant-aware where instrumented.
- **Logs**: Structured logs from engines (via Alloy or OTLP) with `trace_id` and `tenant` correlation. Error rates, unknown states, quarantine events.
- **Traces**: OpenTelemetry (Java agent or SDK) for end-to-end payment/settlement/payout flows. Correlated to logs and metrics.
- **Alerts**: Money-critical rules (liveness, Postgres down, Kafka down, reconciliation lag, unknown state) + RED metrics, lag, error rates. Extend with tenant labels as needed.

## Quick start

```bash
cp .env.example .env
# Edit .env with your Kafka/Postgres endpoints if needed
docker compose up -d
```

Open Grafana: http://localhost:3000 (admin / admin)

## Instrumenting engines

See the `instrumentation/` directory for:
- Adding `micrometer-registry-prometheus` + `/metrics` scrape endpoint (or Actuator `/actuator/prometheus`) to any Java engine.
- OpenTelemetry Java agent or manual SDK for traces + logs.
- Recommended metric names that match the dashboards and the existing metrics classes in the aggregator (`ReliabilityMetrics`, `SecurityMetrics`, `ReconciliationMetrics`, `HealthProbeMetrics`).
- Always tag with low-cardinality `tenant` (and `engine`/`job`) for multi-tenancy dashboards.

The aggregator and main engines already expose Prometheus metrics after the observability PRs.

## Enterprise features

- Multi-tenancy variables on all major dashboards.
- Cardinality control (no high-cardinality tags on business metrics).
- Full correlation between traces (Tempo), logs (Loki) and metrics (Prometheus).
- Error-focused logs dashboard for rapid troubleshooting.
- Dedicated Audit Trail dashboard for compliance and security decisions.
- Retention policies, remote-write ready for Mimir.
- Alertmanager with severity routing (including security-compliance channel).
- Dashboards-as-code.
- Kafka + Postgres exporters.
- Fail-closed health probes as gauges.

## Production notes

This compose is suitable for staging / single-node. For full enterprise scale:
- Replace Prometheus with Grafana Mimir (multi-tenant).
- Use object storage (S3/GCS) for Loki and Tempo.
- Deploy Alloy / OTel Collector as DaemonSets on Kubernetes.
- Enable Grafana RBAC / teams per tenant if needed (Grafana OSS supports basic org/user; Enterprise for advanced).
- Consider Grafana Cloud or Enterprise for advanced RBAC, reporting and on-call.

Official minimal alternative: `grafana/otel-lgtm` image.
