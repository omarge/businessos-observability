# Conectar métricas de dominio al código real

Las clases (`PaymentMetrics`, `FraudMetrics`, etc.) ya existen. Para que los dashboards dejen de mostrar cero hay que invocarlas en los flujos de negocio.

## Patrón recomendado (Spring)

```java
@Service
public class PaymentService {
    private final PaymentMetrics metrics;

    public PaymentService(MeterRegistry registry) {
        this.metrics = new PaymentMetrics(registry);   // o inyectar la clase como @Bean
    }

    public PaymentResult authorize(AuthorizeRequest req) {
        long start = System.nanoTime();
        try {
            // ... lógica de negocio ...
            metrics.recordAuthorized();
            return result;
        } catch (Exception e) {
            metrics.recordFailed();
            throw e;
        } finally {
            metrics.recordLatency(Duration.ofNanos(System.nanoTime() - start));
        }
    }

    public void capture(String id) {
        // ...
        metrics.recordCaptured();
    }
}
```

## Puntos de enganche por engine

| Engine | Clase | Métodos a llamar | Lugar sugerido |
|--------|-------|-------------------|----------------|
| Payment | `PaymentMetrics` | `recordAuthorized()`, `recordCaptured()`, `recordFailed()`, `recordRefunded()`, `recordLatency()` | Servicio de authorize/capture/refund |
| Fraud | `FraudMetrics` | `recordEvaluated()`, `recordApproved()`, `recordDeclined()`, `recordReview()`, `recordLatency()` | Servicio de evaluación de riesgo |
| Settlement | `SettlementMetrics` | `recordCreated()`, `recordCompleted()`, `recordFailed()`, `recordLatency()` | Servicio de liquidación |
| Payout | `PayoutMetrics` | `recordInitiated()`, `recordCompleted()`, `recordFailed()`, `recordLatency()` | Servicio de payout |
| Reconciliation | `ReconciliationEngineMetrics` | `recordRun()`, `recordMatched()`, `recordBreak()`, `recordPending()` | Motor de reconciliación |
| Merchant | `MerchantMetrics` | `recordCreated()`, `recordActivated()`, `recordSuspended()`, etc. | Servicio de ciclo de vida |
| Chargeback | `ChargebackMetrics` | `recordOpened()`, `recordWon()`, `recordLost()`, `recordPending()` | Servicio de disputas |
| Security | `SecurityEngineMetrics` | `recordAllowed()`, `recordDenied()`, `recordTenantMismatch()`, `recordPolicyDenied()` | Verificador de autorización |

## Bean de Spring (opcional)

```java
@Configuration
public class MetricsConfig {
    @Bean
    public PaymentMetrics paymentMetrics(MeterRegistry registry) {
        return new PaymentMetrics(registry);
    }
}
```

Inyecta `PaymentMetrics` donde lo necesites.

## Verificación

1. Arranca el engine.
2. Ejecuta un flujo de negocio.
3. Consulta `http://<engine>:<port>/actuator/prometheus` y busca `businessos_payment_authorized_total` (o el equivalente).
4. En Grafana, el dashboard **Domain Metrics** debe mostrar actividad.
