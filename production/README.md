# Production Enterprise Configurations

These examples implement the three recommended production steps from the main documentation.

## 1. Replace Prometheus with Grafana Mimir (multi-tenant)

File: `mimir/mimir.yaml`

- Enables multi-tenancy.
- Uses S3 for block storage.
- Configured for horizontal scale (replication factor 3).

Point Grafana datasource to Mimir instead of Prometheus. Engines can remote-write to Mimir or continue scraping via a Prometheus that remote-writes to Mimir.

## 2. Object storage for Loki and Tempo (S3/GCS)

- `object-storage/loki-s3.yaml` — Loki with S3 backend, retention and compaction.
- `object-storage/tempo-s3.yaml` — Tempo with S3 backend and metrics generator remote-write.

Replace the local filesystem configs in the docker-compose / Helm values with these. Set bucket names and credentials via environment or IAM roles.

## 3. Deploy Alloy and OpenTelemetry Collector as DaemonSets on Kubernetes

- `k8s/alloy-daemonset.yaml` — Alloy DaemonSet for node-level metrics, logs and traces discovery.
- `k8s/otel-collector-daemonset.yaml` — OTel Collector DaemonSet for OTLP reception and processing.

Create the `observability` namespace, ConfigMaps for the configs, and apply the manifests. Adjust resource limits and volume mounts for your cluster.

## Next steps

- Use Grafana Helm charts or the official Mimir/Loki/Tempo Helm charts for full production.
- Enable IRSA / Workload Identity for S3 access.
- Add network policies and RBAC.
- Integrate with the existing Alertmanager and Grafana provisioning.
