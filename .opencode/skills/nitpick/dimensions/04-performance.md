# Performance

Score the project's responsiveness, resource efficiency, and scalability headroom.

Before scoring, re-read `00-rubric.md` for severity definitions and score anchors.

> **Book source**: *Systems Performance* (Brendan Gregg) for USE and RED methodologies.

**Core principle**: Do not claim a performance problem without evidence. If you cannot confirm the issue from the code alone, mark it "needs verification" and describe what to measure.

## The USE Method

(Gregg: "For every resource, check Utilization, Saturation, and Errors. This solves about 80% of server issues with 5% of the effort.")

For each resource the system depends on, ask three questions:

| Resource | Utilization | Saturation | Errors |
|----------|-------------|------------|--------|
| CPU | % busy (per-core or average) | Run queue length (dispatcher queue) | Scheduler errors |
| Memory | % used / available free | Anonymous paging, swapping | OOM kills |
| Network I/F | RX/TX throughput / max bandwidth | Queue depth | Packet drops, late collisions |
| Storage device | I/O busy % | Wait queue length | Device errors (soft, hard) |
| Database | Connection pool usage % | Connection wait time | Query failures, deadlocks |
| Thread pool | Active threads / total | Queue length | Rejections, timeouts |
| Locks / mutexes | Hold time | Contention (wait time) | Deadlocks |

When reviewing a service, apply this table. For each resource:

- **Utilization**: does the code emit metrics/logs showing how busy each resource is? If not, flag P2 (you cannot debug what you cannot see).
- **Saturation**: is there protection (queues, backpressure, rate limiting, connection pooling)? If not, flag P2.
- **Errors**: are resource errors (connection failures, OOM, packet drops) logged and alerted? If not, flag P2.

(Gregg: "Errors should be investigated because they can degrade performance, and may not be immediately noticed when the failure mode is recoverable. This includes operations that fail and are retried, and devices from a pool of redundant devices that fail.")

## The RED Method

For each API endpoint or service call:

- **Rate**: requests per second (per endpoint)
- **Errors**: failing requests (count and rate)
- **Duration**: latency distribution — track p50, p95, p99, not averages

(Gregg: "Averages hide painful outliers. Monitor p50 for the typical experience and p95/p99 to catch slow requests that users feel during incidents.")

If the project is a service and has no RED metrics, flag P2 (you cannot investigate latency without them).

## Profiling Guidance

(Gregg: "If CPU usage is high, use on-CPU profiling (flame graphs) to see where time goes. If requests are waiting but CPU is low, use off-CPU profiling to see what blocks threads — locks, I/O, scheduler, remote calls.")

- Does the project have profiling tools configured (Node.js `--prof`, Python `cProfile`, Go `pprof`)?
- Are there benchmarks for critical paths?

## Diagnostic Questions

### F1: Database access patterns

- Search for query execution inside loops: `for`/`while`/`forEach` containing `await db.query`. Each is a potential N+1 (P1).
- Are there `SELECT *` queries that fetch columns never used? (P2)
- Are frequently-filtered columns indexed? Check migration files for `CREATE INDEX`.
- Is there pagination on list endpoints, or can they return unbounded results? (P1)

### F2: Caching opportunities

- Is there any caching (Redis, in-memory, HTTP cache headers)?
- Are there expensive computations called repeatedly with the same inputs?
- Are static assets served with cache headers?

### F3: Network efficiency

- Are multiple sequential API calls that could be parallel? (`await a(); await b();` instead of `await Promise.all([a(), b()])`) (P2)
- Are external API calls missing timeouts? (P1 — a hung call blocks everything downstream)

### F4: Frontend-specific (if applicable)

- Is there code splitting / lazy loading for routes?
- Are large dependencies imported for small features?
- Are there unstable dependency arrays in `useEffect`/`useMemo`?
- Are images optimized (WebP, responsive sizes, lazy loading)?

### F5: Memory and resource management

- Are event listeners / subscriptions cleaned up on unmount?
- Are there caches that grow without eviction?
- Are large files loaded into memory when streaming would work?
- Are thread-safe collections used where shared state exists? (Clean Code Ch.13: "Keep locked sections as small as possible.")

## Cross-Dimension Hooks

- If missing timeouts cause cascading failures → note this in Testing (resilience)
- If no tests exist to catch performance regressions → tag `@root:no-tests`
- If no metrics exist to apply USE/RED → note this in Testing (observability)
- If locked sections are too large causing contention → note this in Architecture (concurrency management)
