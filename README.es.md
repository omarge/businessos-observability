# BusinessOS Observability Stack — Documentación en Español

Plataforma de observabilidad open-source de grado empresarial para todos los engines de BusinessOS / Kashbit (merchant, payment, fraud, settlement, treasury, payout, reconciliation, chargeback-disputes, security) y la capa de integración del Aggregator.

## Stack (LGTM + más)

| Componente | Propósito | Puerto |
|------------|-----------|--------|
| **Grafana** | Interfaz unificada (métricas, logs, traces, alertas) | 3000 |
| **Prometheus** | TSDB de métricas + evaluación de alertas | 9090 |
| **Loki** | Agregación de logs | 3100 |
| **Tempo** | Tracing distribuido | 3200 |
| **Alertmanager** | Enrutamiento, agrupación y silenciado de alertas | 9093 |
| **OpenTelemetry Collector** | Receptor OTLP (métricas/logs/traces) | 4317 (gRPC), 4318 (HTTP) |
| **Grafana Alloy** | Agente unificado (métricas, logs, traces + descubrimiento Docker) | 12345 |
| **node-exporter** | Métricas del host | 9100 |
| **cAdvisor** | Métricas de contenedores | 8080 |
| **Kafka Exporter** | Lag de consumidores y métricas de topics | 9308 |
| **Postgres Exporter** | Métricas de PostgreSQL | 9187 |

## Inicio rápido

```bash
cp .env.example .env
# Edita .env con los endpoints de Kafka/Postgres si es necesario
docker compose up -d
```

Abre Grafana: http://localhost:3000 (admin / admin)

Los dashboards pre-provisionados aparecen en la carpeta **BusinessOS**.

## Señales cubiertas

### Métricas
- Micrometer (engines Java) + scrape de Prometheus + OTLP.
- Métricas de dominio: `businessos.payment.*`, `businessos.fraud.*`, `businessos.settlement.*`, `businessos.payout.*`, `businessos.reconciliation.*`, `businessos.merchant.*`, `businessos.chargeback.*`, `businessos.security.*`, **`businessos.treasury.liquidity.*`**.
- Confiabilidad (outbox/inbox), decisiones de seguridad, reconciliación, health probes, JVM, lag de Kafka, Postgres.
- Recording rules pre-calculadas (tasas, ratios de error, latencias p95, heap).

### Logs
- Logs estructurados de los engines (vía Alloy u OTLP).
- Correlación con `trace_id` y `tenant`.
- Detección de errores, estados desconocidos y eventos de quarantine.

### Traces
- OpenTelemetry **Java agent** incluido en el Dockerfile de cada engine.
- Correlación con logs y métricas en Grafana.
- Configuración y overlay en `production/otel/`.

### Alertas
- Críticas de dinero (liveness, Postgres down, Kafka down, lag de reconciliación).
- Confiabilidad (outbox pending, denials de seguridad).
- Compliance y aislamiento de tenants.
- SLO de errores y latencia (PaymentErrorRatioHigh, FraudDeclineRatioHigh, LatencySLOBreach, HttpErrorRatioHigh, DomainLatencySpike).
- **Liquidez**: LiquidityReservationFailureHigh, LiquidityFundingFailed, LiquidityInsufficientSpike, LiquidityReservationLatencyHigh.

## Métricas de Liquidez

Implementadas en el engine `businessos-treasury-liquidity-engine` mediante las clases `LiquidityMetrics` y `TreasuryMetrics`, registradas por aspectos AOP.

### Contadores de reserva
| Métrica | Descripción |
|----------|-------------|
| `businessos_treasury_liquidity_reservation_created_total` | Reservas de liquidez creadas |
| `businessos_treasury_liquidity_reservation_released_total` | Reservas liberadas |
| `businessos_treasury_liquidity_reservation_expired_total` | Reservas expiradas |
| `businessos_treasury_liquidity_reservation_failed_total` | Reservas fallidas |

### Posición de caja y observaciones
| Métrica | Descripción |
|----------|-------------|
| `businessos_treasury_liquidity_position_updated_total` | Actualizaciones de posición de caja |
| `businessos_treasury_liquidity_position_queried_total` | Consultas de posición de caja |
| `businessos_treasury_liquidity_observation_recorded_total` | Observaciones de caja registradas |

### Funding
| Métrica | Descripción |
|----------|-------------|
| `businessos_treasury_liquidity_funding_planned_total` | Planes de funding creados |
| `businessos_treasury_liquidity_funding_executed_total` | Ejecuciones de funding completadas |
| `businessos_treasury_liquidity_funding_failed_total` | Ejecuciones de funding fallidas |

### Reservas autoritativas
| Métrica | Descripción |
|----------|-------------|
| `businessos_treasury_liquidity_authoritative_authorized_total` | Reservas autoritativas autorizadas |
| `businessos_treasury_liquidity_authoritative_confirmed_total` | Reservas autoritativas confirmadas |

### Latencias
| Métrica | Descripción |
|----------|-------------|
| `businessos_treasury_liquidity_reservation_latency_seconds` | Latencia de reserva |
| `businessos_treasury_liquidity_position_latency_seconds` | Latencia de posición |
| `businessos_treasury_liquidity_funding_latency_seconds` | Latencia de funding |

### Métricas generales de Treasury (también cubren liquidez)
| Métrica | Descripción |
|----------|-------------|
| `businessos_treasury_liquidity_check_total` | Checks de liquidez |
| `businessos_treasury_liquidity_insufficient_total` | Eventos de liquidez insuficiente |
| `businessos_treasury_transfer_initiated_total` | Transfers iniciados |
| `businessos_treasury_transfer_completed_total` | Transfers completados |
| `businessos_treasury_transfer_failed_total` | Transfers fallidos |
| `businessos_treasury_transfer_latency_seconds` | Latencia de transfer |

### Servicios instrumentados
El aspecto `LiquidityMetricsAspect` cubre de forma precisa:
- `LiquidityReservationService`
- `CashPositionService`
- `CashObservationService`
- `FundingService`
- `AuthoritativeReservationService`

## Dashboards pre-provisionados

Todos soportan variables de multi-tenancy (cuando aplica), correlación con logs/traces y troubleshooting de errores.

| Dashboard | Propósito |
|-----------|-----------|
| **Multi-Tenant Overview** | Salud de engines, rates, latencia, tenants activos, denials |
| **Domain Metrics (All Engines)** | Contadores y latencias de dominio (incluye paneles de Liquidity Reservations y Funding & Position) |
| **SLO Overview** | Gauges y timeseries basados en recording rules (error ratios, latencias p95, heap) |
| **Executive Summary** | KPIs de alto nivel para dirección (engines up, error %, volúmenes, latencias) |
| **Errors & Logs (Troubleshooting)** | Logs de error/warn en Loki, top messages, correlación por trace_id |
| **Kafka & Reliability** | Outbox/inbox, consumer lag, quarantine |
| **Payment / Fraud / Settlement / Payout / Reconciliation** | Vistas específicas por engine |
| **Distributed Traces** | Búsqueda TraceQL, service map, traces lentos |
| **Security & Compliance** | Denials, allowed, quarantine, logs de policy/audit |
| **Audit Trail** | Trail completo de auditoría y decisiones de seguridad |
| **Anomaly Detection** | Spikes de volumen de logs, errores anómalos, latencia vs baseline |
| **Performance Metrics** | Throughput, percentiles, JVM, CPU, outbox/inbox |
| **Treasury Engine** | Rate, latency, JVM y logs del treasury |

## Instrumentación de engines

### Dependencias (Gradle)
```gradle
implementation 'io.micrometer:micrometer-core'
implementation 'io.micrometer:micrometer-registry-prometheus'
implementation 'org.springframework.boot:spring-boot-starter-actuator'
implementation 'org.springframework.boot:spring-boot-starter-aop'   # para aspectos de métricas
```

### Exposición (application.yml)
```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,prometheus,metrics
  metrics:
    tags:
      application: <nombre-engine>
      engine: <engine>
```

### Clases de métricas de dominio
Siguen el patrón del Aggregator (`ReliabilityMetrics`, `SecurityMetrics`):
- Constructor dual (`SimpleMeterRegistry` para tests / `MeterRegistry` inyectado).
- **Ley de cardinalidad**: no se permiten tags de alta cardinalidad (`tenant_id`, `payment_id`, `correlation_id`, etc.).
- Nombres semánticos estables (`businessos.<engine>.<accion>`).

Ejemplos implementados: `PaymentMetrics`, `FraudMetrics`, `SettlementMetrics`, `PayoutMetrics`, `ReconciliationEngineMetrics`, `MerchantMetrics`, `ChargebackMetrics`, `SecurityEngineMetrics`, `TreasuryMetrics`, **`LiquidityMetrics`**.

Los aspectos AOP registran las métricas en los flujos de negocio sin modificar la lógica.

### OpenTelemetry Java agent

Todos los engines incluyen un `Dockerfile` que descarga el agent y arranca con `-javaagent`.

Archivos en `production/otel/`:
- `Dockerfile.engine` — patrón reutilizable
- `docker-compose.engines.yml` — overlay para levantar engines contra el Collector local
- `javaagent-env.sh` — variables para ejecución no-Docker
- `README.md` — pasos de uso

### Scrape de Prometheus
Los jobs están pre-configurados en `configs/prometheus/prometheus.yml`. Ajusta los puertos según tu despliegue:

| Job | Path | Puerto ejemplo |
|-----|------|----------------|
| businessos-aggregator | `/metrics` | 8080 |
| businessos-payment | `/actuator/prometheus` | 8082 |
| businessos-settlement | `/actuator/prometheus` | 8083 |
| businessos-payout | `/actuator/prometheus` | 8084 |
| businessos-reconciliation | `/actuator/prometheus` | 8085 |
| businessos-treasury | `/actuator/prometheus` | 8086 |
| businessos-fraud | `/actuator/prometheus` | 8087 |
| businessos-merchant | `/actuator/prometheus` | 8088 |
| businessos-chargeback | `/actuator/prometheus` | 8089 |
| businessos-security | `/actuator/prometheus` | 8090 |

## Recording Rules

Definidas en `configs/prometheus/recording-rules.yml`. Pre-calculan:
- Tasas de dominio (`businessos:payment_authorized:rate5m`, etc.).
- Ratios de error/decline.
- Latencias p95.
- Ratio HTTP 5xx y uso de heap JVM.

Usadas por los dashboards SLO y Executive Summary.

## Alertas principales

| Grupo | Alertas clave |
|-------|---------------|
| Money-critical | LivenessLoss, PostgresDown, KafkaDown, ReconciliationLag |
| Reliability | OutboxPendingHigh, SecurityDenialsSpike |
| Security & Compliance | SecurityDenialRateHigh, TenantIsolationViolationSuspected, QuarantineSpike |
| SLO Errores/Latencia | PaymentErrorRatioHigh, FraudDeclineRatioHigh, LatencySLOBreach, HttpErrorRatioHigh, DomainLatencySpike |
| **Liquidity** | LiquidityReservationFailureHigh, LiquidityFundingFailed, LiquidityInsufficientSpike, LiquidityReservationLatencyHigh |

Enrutamiento en Alertmanager por severidad. Los receptores de Slack/PagerDuty/email usan placeholders de variables de entorno (descomentar y setear secretos al desplegar).

## Características enterprise

- Variables de multi-tenancy en los dashboards principales.
- Control de cardinalidad (sin tags de alta cardinalidad en métricas de negocio).
- Correlación completa entre traces (Tempo), logs (Loki) y métricas (Prometheus).
- Dashboards-as-code.
- Retención configurable; listo para remote-write a Mimir.
- Exporters de Kafka y Postgres.
- Health probes fail-closed como gauges.
- Java agent de OpenTelemetry en todos los engines.

## Notas de producción (los 3 puntos)

Este compose es adecuado para staging / nodo único. Para escala enterprise se incluyen ejemplos listos en la carpeta `production/`:

1. **Reemplazar Prometheus por Grafana Mimir** (multi-tenant)  
   → `production/mimir/mimir.yaml`

2. **Object storage (S3) para Loki y Tempo**  
   → `production/object-storage/loki-s3.yaml`  
   → `production/object-storage/tempo-s3.yaml`

3. **Alloy y OpenTelemetry Collector como DaemonSets en Kubernetes**  
   → `production/k8s/alloy-daemonset.yaml`  
   → `production/k8s/otel-collector-daemonset.yaml`

4. **Java agent en runtime**  
   → `production/otel/` (Dockerfile, compose overlay, env script)

Ver `production/README.md` para instrucciones de uso. Adicionalmente:
- Habilita RBAC / teams por tenant en Grafana (OSS básico; Enterprise para avanzado).
- Considera Grafana Cloud o Enterprise para reporting avanzado y on-call.

Alternativa mínima oficial: imagen `grafana/otel-lgtm`.

## Estructura del repositorio

```
configs/
  prometheus/     # prometheus.yml, alert-rules.yml, recording-rules.yml
  grafana/        # provisioning + dashboards
  loki/
  tempo/
  alertmanager/
  alloy/
  otel-collector/
production/       # configs enterprise (Mimir, S3, DaemonSets K8s, OTel agent)
  otel/           # Dockerfile.engine, compose overlay, javaagent-env.sh
instrumentation/  # guías para agregar Micrometer/OTel a engines
docker-compose.yml
```

---

Documentación generada para el stack BusinessOS Observability.  
Repositorio: https://github.com/omarge/businessos-observability
