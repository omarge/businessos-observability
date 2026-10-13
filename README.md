# BusinessOS Observability Stack

Enterprise-grade open-source observability platform for all BusinessOS / Kashbit engines (merchant, payment, fraud, financial-subledger, settlement, treasury, payout, reconciliation, chargeback-disputes, transport-fabric, security) and the aggregator integration layer.

**Documentación completa en español:** [README.es.md](README.es.md)

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
| **Domain Metrics (All Engines)** | Payment, Fraud, Settlement, Payout, Reconciliation, Chargeback, Merchant, Security, **Liquidity** domain counters & latencies |
| **SLO Overview** | Gauges and timeseries based on recording rules |
| **Executive Summary** | High-level KPIs |
| **Errors & Logs (Troubleshooting)** | Loki-powered error/warn logs, top error messages, trace_id correlation |
| **Kafka & Reliability** | Outbox/inbox, consumer lag, quarantine, by tenant |
| **Payment Engine** | Payment-specific RED metrics + logs, filtered by tenant |
| **Fraud Engine** | Fraud decisions, latency, risk-related errors |
| **Settlement / Payout / Reconciliation** | Breaks, pending reports, outbox, related logs |
| **Distributed Traces** | Tempo TraceQL search, service map, slow traces |
| **Security & Compliance** | Denials, allowed, denial rate, quarantine, policy/audit logs |
| **Audit Trail** | Full audit log trail, security decisions (allowed/denied), quarantine, alerts |
| Plus: Anomaly Detection, Performance, Treasury | |

Dashboards appear under the **BusinessOS** folder after `docker compose up`.

## Signals covered

- **Metrics**: Micrometer (Java engines) + Prometheus scrape + OTLP. Includes domain metrics (`businessos.payment.*`, `businessos.fraud.*`, `businessos.treasury.liquidity.*`, etc.), reliability (outbox/inbox), security decisions, reconciliation, health probes, JVM, Kafka lag, Postgres.
- **Logs**: Structured logs from engines (via Alloy or OTLP) with `trace_id` and `tenant` correlation. Error rates, unknown states, quarantine events.
- **Traces**: OpenTelemetry Java agent (baked into every engine Dockerfile) for end-to-end flows. Correlated to logs and metrics.
- **Alerts**: Money-critical rules + SLO error/latency alerts + security/compliance + **liquidity** (reservation failures, funding failed, insufficient liquidity, reservation latency).

## Quick start

```bash
cp .env.example .env
# Edit .env with your Kafka/Postgres endpoints if needed
docker compose up -d
```

Open Grafana: http://localhost:3000 (admin / admin)

## Instrumenting engines

See the `instrumentation/` directory and the Spanish documentation ([README.es.md](README.es.md)) for:
- Adding `micrometer-registry-prometheus` + Actuator `/actuator/prometheus`.
- Domain metric classes following the Aggregator cardinality law.
- Scrape job configuration.

All main engines expose domain Micrometer metrics via Actuator and ship with an OpenTelemetry Java agent Dockerfile. Adjust ports in `configs/prometheus/prometheus.yml` to match your deployment.

### OpenTelemetry Java agent (runtime)

Every engine now has a `Dockerfile` that downloads the agent and starts with `-javaagent`.

Reusable pattern and compose overlay live in `production/otel/`:
- `Dockerfile.engine`
- `docker-compose.engines.yml`
- `javaagent-env.sh` (for non-Docker runs)
- `README.md`

## Enterprise features

- Multi-tenancy variables on major dashboards.
- Cardinality control (no high-cardinality tags on business metrics).
- Full correlation between traces (Tempo), logs (Loki) and metrics (Prometheus).
- Recording rules for rates, error ratios and p95 latencies.
- SLO and Executive Summary dashboards.
- Liquidity panels and alerts.
- Error-focused logs and Audit Trail dashboards.
- Alertmanager with severity routing (env-var placeholders for Slack/PagerDuty/email).
- Dashboards-as-code.
- Kafka + Postgres exporters.

## Production notes

This compose is suitable for staging / single-node. For full enterprise scale see `production/`:
- Replace Prometheus with Grafana Mimir.
- Use object storage for Loki and Tempo.
- Deploy Alloy / OTel Collector as DaemonSets on Kubernetes.
- Apply the OTel Java agent via the engine Dockerfiles or `production/otel/`.

Official minimal alternative: `grafana/otel-lgtm` image.
