#!/usr/bin/env bash
# Example environment for running any BusinessOS engine with the OpenTelemetry Java agent.
# Download the agent once:
#   curl -L -o opentelemetry-javaagent.jar https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar

export JAVA_TOOL_OPTIONS="-javaagent:/opt/otel/opentelemetry-javaagent.jar"
export OTEL_SERVICE_NAME="${ENGINE_NAME:-payment-engine}"
export OTEL_EXPORTER_OTLP_ENDPOINT="http://otel-collector:4317"
export OTEL_EXPORTER_OTLP_PROTOCOL="grpc"
export OTEL_TRACES_EXPORTER="otlp"
export OTEL_METRICS_EXPORTER="none"          # Prometheus scrape already covers metrics
export OTEL_LOGS_EXPORTER="otlp"
export OTEL_RESOURCE_ATTRIBUTES="deployment.environment=production,engine=${ENGINE_NAME:-unknown}"

# Optional sampling
export OTEL_TRACES_SAMPLER="parentbased_traceidratio"
export OTEL_TRACES_SAMPLER_ARG="0.1"

echo "OTel agent configured for $OTEL_SERVICE_NAME -> $OTEL_EXPORTER_OTLP_ENDPOINT"
