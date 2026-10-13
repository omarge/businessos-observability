# Prueba end-to-end local

## 1. Levantar el stack

```bash
cd businessos-observability
cp .env.example .env
docker compose up -d
```

Grafana: http://localhost:3000 (admin/admin)

## 2. Apuntar scrape targets

Edita `configs/prometheus/prometheus.yml` y ajusta los puertos a los de tus engines locales. Ejemplo:

```yaml
- job_name: 'businessos-payment'
  metrics_path: /actuator/prometheus
  static_configs:
    - targets: ['host.docker.internal:8082']
      labels:
        engine: payment
```

Reinicia Prometheus:
```bash
docker compose restart prometheus
```

## 3. Validar

1. Targets: http://localhost:9090/targets → deben estar UP.
2. Métricas: ejecuta un flujo de negocio en un engine y consulta `/actuator/prometheus`.
3. Dashboards: abre **Domain Metrics** y **SLO Overview** en Grafana.
4. Alertas: fuerza una condición (ej. detén Postgres) y revisa Alertmanager (http://localhost:9093).

## 4. Traces (opcional)

Arranca un engine con el Java agent apuntando a `http://localhost:4317` y busca el trace en el dashboard **Distributed Traces**.
