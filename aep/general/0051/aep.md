# REST vs. Alternative API Architectures

This AEP examines REST alongside alternative API styles and explains why our organization chooses REST as the default
for public and most internal HTTP APIs. It provides a pragmatic comparison, acknowledges REST’s limitations, and
documents when exceptions (GraphQL, gRPC, event-driven) are appropriate.

**Note:** Our organizational standard for APIs is JSON REST over HTTP. JSON is our default representation, but APIs
**may** use other media types when appropriate (e.g., `multipart/form-data` for file uploads, `text/event-stream` for
SSE, `application/octet-stream` for binary). Alternatives to REST are allowed only by exception.

## Summary of our decision

- JSON REST over HTTP is our default API style for external-facing and _**most**_ internal integrations.
- We allow targeted exceptions:
    - GraphQL for client-driven aggregation across many bounded contexts when REST causes persistent over/under-fetching
      and schema churn. In our org, GraphQL is primarily used as a Backend-for-Frontend (BFF): FE → GraphQL BFF → JSON
      REST APIs.
    - gRPC for low-latency, strongly-typed service-to-service calls inside trusted networks, especially when streaming
      is required.
    - Event-driven (pub/sub, streams) for asynchronous workflows and decoupled propagation of state changes.
- Teams proposing alternatives **must** document benefits, costs, and mitigation plans and obtain approval per our
  Architecture Review process.

## Architecture comparison matrix (practical trade-offs)

The following summarizes typical characteristics. Real implementations may vary; treat this as guidance, not dogma.

| Criterion            | REST (HTTP)                                                                                         | GraphQL                                  | gRPC                                  | JSON-RPC/HTTP RPC      |
|----------------------|-----------------------------------------------------------------------------------------------------|------------------------------------------|---------------------------------------|------------------------|
| Transport/Protocol   | HTTP/1.1, HTTP/2, HTTP/3                                                                            | HTTP over single endpoint                | HTTP/2 by default                     | HTTP (varies)          |
| Interface Model      | Resource/representation                                                                             | Typed schema & query language            | IDL (proto) RPC                       | Ad-hoc RPC             |
| Caching              | Native via HTTP cache, ETag, Cache-Control                                                          | Harder at intermediaries; client caches  | Typically app-level only              | None by default        |
| Data Fetching        | Fixed server-driven shapes; multiple endpoints                                                      | Client-driven selection; single endpoint | Server-defined methods/messages       | Server-defined methods |
| Versioning           | Additive evolution friendly; URLs/media types                                                       | Schema evolution via deprecation         | Proto evolution tools; new methods    | Ad-hoc, often brittle  |
| Streaming            | SSE/WebSocket/HTTP streaming; Webhooks for push notifications                                       | Subscriptions (server push)              | Native streams (bi/uni)               | Not typical            |
| Typing               | JSON by default; multiple media types via content negotiation (documented with OpenAPI/JSON Schema) | Strong schema (SDL)                      | Strong (proto)                        | Weak                   |
| Tooling              | Ubiquitous; browsers, CDNs, gateways                                                                | Good client tooling; schema-first        | Excellent codegen; perf               | Minimal                |
| Observability        | Easy: status codes, headers, logs                                                                   | OK but single endpoint complicates       | Great inside mesh; needs interceptors | Minimal                |
| External Adoption    | Very high                                                                                           | Growing for public APIs                  | Mostly internal microservices         | Low                    |
| Browser-friendliness | Excellent                                                                                           | Good (same-origin/CORS)                  | Poor (no browser)                     | Good                   |
| Performance          | Good; benefits from caches/CDN                                                                      | Good; risk of N+1 server issues          | Excellent latency/binary              | Varies                 |
| Complexity           | Low–moderate                                                                                        | Moderate–high (gateway + resolvers)      | Moderate–high (IDL, infra)            | Low                    |

### Where each excels (fit-for-purpose)

- REST
    - Public/external APIs where interoperability, simplicity, and cacheable GETs matter.
    - Cross-team contracts that need stable URIs, standard semantics, and broad tooling.
    - Content distribution scenarios leveraging CDNs and HTTP caching.
- GraphQL
    - Product UIs/mobile needing flexible, client-driven data shapes across many backends.
    - Reducing over/under-fetching when REST endpoints would proliferate or churn.
    - Schema-first product iteration where a gateway can encapsulate backend changes.
- gRPC
    - Low-latency, high-throughput internal service-to-service calls in a trusted network.
    - Bidirectional streaming, flow control, and strong typing with code generation.
    - Polyglot microservices within a service mesh.
- JSON-RPC / HTTP RPC
    - Simple internal tools and automations where resource modeling adds little value.
    - Point-to-point calls without need for intermediaries or caching.

## Why we chose REST as the default

### Organizational context and priorities

- Interoperability first: We integrate with external partners, vendors, and diverse client platforms. REST over HTTP is
  the broadest common denominator.
- Maintainability at scale: Uniform semantics (methods, status codes, headers) reduce cognitive load across many teams.
- Operability and observability: HTTP is transparent; gateways, proxies, CDNs, and logs speak it natively.
- Risk management: REST’s simplicity lowers the blast radius of design errors and eases onboarding.

### Developer experience considerations

- Ubiquity: Most engineers and tools (browsers, curl, OpenAPI, etc.) work out of the box.
- Learnability: Resource-oriented modeling and standard methods are easy to teach and review consistently.
- Documentation and discovery: OpenAPI/JSON Schema enable contract-first or code-first workflows, client generation, and
  validation. OpenAPI also lets us document multiple content types per operation (e.g., JSON for requests,
  `multipart/form-data`
  for uploads, `application/octet-stream` for downloads), making non-JSON use cases first-class while keeping JSON as
  default.

### Infrastructure and tooling alignment

- Gateways and proxies: Off-the-shelf support for authN/Z, rate limiting, routing, mTLS, and WAF.
- Caching layers and CDNs: Native leverage of `Cache-Control`, `ETag`, and conditional requests.
- Security: Mature patterns for OAuth2/OIDC, TLS termination, and zero-trust networking.
- Observability: Standardized metrics (latency per method), logs, traces with clear operation names (method + URI).

### Performance vs. complexity trade-offs

- For most business workloads, REST performance is sufficient, especially when leveraging caching and proper resource
  design.
- Alternatives often introduce new infra (schema registries, gateways, meshes) and specialized skills; we adopt them
  only when the measurable benefit exceeds this complexity.

### Allowances and exceptions (when not REST)

- GraphQL gateway in front of existing REST/gRPC when product teams need client-driven aggregation.
- gRPC for internal microservice calls that are latency-sensitive or require streaming.
- Event-driven integrations for async workflows, backpressure, and decoupled propagation.

**Note:** We commonly use GraphQL as a Backend-for-Frontend (BFF) to tailor data for specific UIs while
keeping backend services as JSON REST APIs. The typical flow is: FE → GraphQL BFF → JSON REST API(s). This keeps REST
as the contract of record between services while enabling flexible client aggregation at the edge.

All exceptions require an [ADR (Architecture Decision Record)] that includes:

- Specific problems REST cannot solve for your use case
- Quantified benefits (performance, developer productivity, etc.)
- Infrastructure and operational costs
- Team expertise and learning curve
- Migration/rollback plan if needed

[ADR (Architecture Decision Record)]: https://github.com/infusionsoft/engineering-handbook/blob/main/architecture-guidelines/architectural-decision-records/README.md

## REST limitations and mitigation strategies

### Over-fetching / under-fetching

- Problem: Fixed representations cause clients to request more or fewer fields than needed.
- Mitigations:
    - Projection parameters (e.g., `fields=...`) with bounded, documented fields.
    - Embedded/expand parameters for related resources (e.g., `?expand=items,payments`).
    - Backend-for-Frontend (BFF) or aggregator endpoints where appropriate.

### Versioning challenges

- Problem: Evolving contracts without breaking existing clients.
- Mitigations:
    - Prefer additive, backward-compatible changes; avoid breaking renames.
    - Deprecation policy with timelines and communication expectations.
    - Versioning strategy per org policy (URI/header/media-type) and migration playbooks.

### Complex query needs

- Problem: Rich filtering, sorting, search, and analytics via query parameters can become unwieldy.
- Mitigations:
    - Consistent filtering/sorting conventions; pagination standards.
    - Dedicated search resources that accept structured bodies for complex queries.
    - Offload analytics to data services; avoid turning REST into adhoc query language.

### Real-time updates / streaming

- Problem: Clients need live updates or server-initiated messages.
- Mitigations:
    - Server-Sent Events (SSE) for unidirectional server → client streams over HTTP using the `text/event-stream` media
      type.
    - WebSockets for bidirectional, low-latency messaging when clients must also push events.
    - Webhooks for event notifications with follow-up GETs when clients can receive callbacks.
    - Prefer SSE for broadcast/append-only event feeds where HTTP semantics and intermediaries are beneficial; use
      WebSockets when client-to-server push or complex realtime patterns are required.

### Strong typing and schema guarantees

- Problem: JSON alone lacks strong typing and codegen ergonomics.
- Mitigations:
    - OpenAPI + JSON Schema for validation and client generation.
    - Contract tests and schema linting in CI.

### Large/binary payloads

- Problem: Inefficient transfer of large media or binary data.
- Mitigations:
    - Use `multipart/form-data` for file uploads when clients need to send files alongside JSON fields (e.g., metadata).
      Document field names, size limits, and validations.
    - Serve downloads as `application/octet-stream` (or a specific media type) and include `Content-Disposition` for
      filenames. Support Range Requests (HTTP 206) for efficient resume/seek.
    - Pre-signed URLs to object storage for direct upload/download paths to keep application nodes stateless and avoid
      buffering large bodies.
    - Consider resumable/multipart upload protocols when needed.
    - Content negotiation and compression where appropriate.
    - Provide integrity checks (e.g., checksum metadata or the HTTP `Digest` header where supported).

## References

- RFC 9110–9114: HTTP Semantics, HTTP Caching, HTTP/1.1, HTTP/2, HTTP/3
    - RFC 9110 (HTTP Semantics): https://datatracker.ietf.org/doc/html/rfc9110
    - RFC 9111 (HTTP Caching): https://datatracker.ietf.org/doc/html/rfc9111
    - RFC 9112 (HTTP/1.1): https://datatracker.ietf.org/doc/html/rfc9112
    - RFC 9113 (HTTP/2): https://datatracker.ietf.org/doc/html/rfc9113
    - RFC 9114 (HTTP/3): https://datatracker.ietf.org/doc/html/rfc9114
- RFC 7578: Returning Values from Forms: `multipart/form-data`: https://datatracker.ietf.org/doc/html/rfc7578
- MDN: Server-Sent Events (EventSource): https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events
    - MDN: `text/event-stream` media
      type: https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events#setting_the_right_content-type
- MDN: `Content-Disposition` header: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Disposition
- GraphQL Specification: https://spec.graphql.org/
- gRPC Core Concepts: https://grpc.io/docs/what-is-grpc/core-concepts/
    - Protocol Buffers Language Guide (proto3): https://protobuf.dev/programming-guides/proto3/

## Changelog

- **2025-10-31**: Initial creation.
