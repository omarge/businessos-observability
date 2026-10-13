# Afinar aspectos de métricas de dominio

Los aspectos actuales usan pointcuts amplios por nombre de método. Para producción conviene restringirlos.

## 1. Pointcuts más precisos

En lugar de:
```java
@Around("execution(* com.kashbit.payout..*(..)) && execution(* *payout*(..))")
```

Usa la clase concreta:
```java
@Around("execution(* com.kashbit.payout.application.PayoutService.initiate(..)) || " +
        "execution(* com.kashbit.payout.application.PayoutService.complete(..))")
```

## 2. Inspeccionar el resultado

```java
@Around("execution(* com.businessos.fraud.app.evaluation.PredecisionChampionChallengerEvaluationService.evaluateAuthoritative(..))")
public Object record(ProceedingJoinPoint pjp) throws Throwable {
    long start = System.nanoTime();
    try {
        Object result = pjp.proceed();
        metrics.recordEvaluated();
        // Ejemplo: si el resultado expone un decision()
        if (result instanceof PredecisionChampionChallengerEvaluationResult r) {
            if (r.isApproved()) metrics.recordApproved();
            else metrics.recordDeclined();
        }
        return result;
    } catch (Throwable t) {
        metrics.recordEvaluated();
        metrics.recordDeclined();
        throw t;
    } finally {
        metrics.recordLatency(Duration.ofNanos(System.nanoTime() - start));
    }
}
```

## 3. Evitar doble conteo

Si un método llama a otro que también está en el pointcut, usa `pjp.getSignature().getDeclaringType()` o limita el pointcut a la capa de aplicación.

## 4. Dependencia

Asegura que el engine tenga:
```gradle
implementation 'org.springframework.boot:spring-boot-starter-aop'
```
