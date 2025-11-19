# API Versioning Strategy

Organizations need clear, consistent versioning strategies that balance evolution flexibility with client simplicity.
This document establishes the standard approach for versioning APIs within our microservices architecture, ensuring
uniform practices across all services

## Guidance

### Global API Versioning

APIs **must** use [Semantic Versioning].

All APIs **must** use global versioning. The version identifier applies to the entire API surface of a microservice and
is exposed as a path prefix.

**URI Format**

* The version **must** appear at the start of the path.
* APIs **must** use only the major version component (e.g., `v1`, `v5`). Minor and patch versions **must not** be
  exposed in the URI.
* Format: `/v{major}/...`

Examples:

```http
GET /v5/books/123
POST /v5/publishers
GET /v5/books/456/reviews
```

**Version Scope**

Each microservice **must** represent a single versioning boundary. All resources and endpoints within a microservice
**must** share the same version namespace.

When *any* endpoint requires a breaking change, the entire API version for that service **must** be incremented.

**Example service evolution:**

Version 1:

```
/v1/books
/v1/publishers
/v1/reviews
```

Version 2 (even if only `books` changed):

```
/v2/books        (New behavior)
/v2/publishers   (Identical behavior to v1, but distinct endpoint)
/v2/reviews      (Identical behavior to v1, but distinct endpoint)
```

### Implementation Strategy

To support the global versioning strategy defined above, the following internal code structure is recommended.

**Code Organization**

Projects **should** organize their code by API version using separate directories. While teams may choose other
patterns, this structure is strongly encouraged to ensure clean separation of contracts.

Example Java project structure:

```text
api/
  v1/
    books/
      BooksController.java
      BookModel.java
    publishers/
      PublishersController.java
  v2/
    books/
      BooksController.java
      BookModel.java
    publishers/
      PublishersController.java
```

**Migration Process**

When creating a new API version, teams **should**:

1. Duplicate the entire previous version directory (e.g., copy `v1/` to `v2/`)
2. Apply breaking changes only in the new directory (`v2/`)
3. Serve both versions simultaneously
4. When the old version reaches its sunset date, delete the `v1/` directory entirely

This "Copy-Modify-Delete" approach ensures that old versions remain stable and touch-free while new versions are
developed. It also makes removing dead code trivial (delete the folder) compared to unwinding complex inheritance or
shared logic.

### AEP Versioning

APIs **must** declare which API specification version they follow using a custom header. See AEP-3 for complete details.

Response header:

```
X-AEP-Version: v3
```

This identifies which set of organizational API design standards the service follows, independent of the API's own
version number.

### Resource-level versioning

APIs **must not** use resource-level versioning (having different resources at different versions within the same API).

Not allowed:

```
/v5/publishers/...  (at version 5)
/v2/books/...       (at version 2 in the same API)
```

Not allowed:

```
/v5/books?version=v2
/v5/legacy-v2/books/...
```

All resources within an API **must** share the same version. See the [Rationale](#why-global-versioning) section below
for the reasoning behind this decision.

### OpenAPI documentation

OpenAPI specifications **should** clearly document both the API version and specification version. For example:

{% tab proto %}

{% tab oas %}

```yaml
openapi: 3.1.0
info:
  title: Books API
  version: 5.0.0
  description: Books management API following AEP v3 specification
  x-aep-version: v3

servers:
  - url: https://api.company.com/v5
    description: Production server (v5)
  - url: https://api.company.com/v4
    description: Production server (v4 - deprecated)
```

{% endtabs %}

### Deprecation and Migration

When a new API version is released, the previous version enters its sunset phase.

**Support Window**

* Both old and new versions **must** remain fully supported.
* Teams **should** determine an appropriate window based on client needs, but deprecated versions **must** be removed
  within **12 months maximum**.
* Teams **should** provide clear migration guides explaining breaking changes.
* After the sunset date, old version endpoints **must** be removed.

**Deprecation Headers**

Deprecated API versions **should** include `Deprecation` and `Sunset` headers in all responses. These allow clients to
programmatically detect deprecated endpoints and plan migrations.

Example:

```http
Deprecation: true
Sunset: Sat, 01 Jan 2027 00:00:00 GMT
```

**Header Format Requirements**

* The `Deprecation` header **must** be a boolean (`true`/`false`).
* The `Sunset` header **must** use the HTTP-date format: `Day, DD Mon YYYY HH:MM:SS GMT`.
    * `Day`: Three-letter day abbreviation (e.g., `Sat`)
    * `DD`: Two-digit date (01-31)
    * `Mon`: Three-letter month abbreviation (e.g., `Jan`)
    * `YYYY`: Four-digit year
    * `HH:MM:SS`: Time in 24-hour format with leading zeros
    * `GMT`: Timezone **must** be GMT

### When to Version

Increment the major API version when making any of these breaking changes:

* Removing or renaming fields in responses
* Changing field types or formats
* Removing endpoints
* Changing endpoint behavior in incompatible ways
* Modifying required request parameters
* Changing authentication or authorization requirements
* Changing error codes, or error JSON response structure

Backward-compatible changes do not require version increments:

* Adding new optional fields to responses
* Adding new endpoints
* Adding new optional request parameters
* Fixing bugs that restore documented behavior

## Rationale

### Why global versioning

We prohibit resource-level versioning (different resources at different versions within the same API) for several
reasons:

* Resource-level versioning pushes complexity onto every API consumer. Clients must track which resources are at which
  versions, creating mental overhead and increasing the likelihood of errors. A developer using the Books API shouldn't
  need to remember "books are v2, publishers are v5, reviews are v3."
* With global versioning, documentation clearly states "Books API v5" and all endpoints are understood to be at that
  version. Resource-level versioning requires complex matrices showing which resources are at which versions, making
  documentation harder to maintain and understand.
* Global versioning allows straightforward testing of "the v5 API." Resource-level versioning creates combinatorial
  explosion: do v2 books work correctly with v5 publishers? What about v3 reviews with v2 books? The testing matrix
  becomes unmanageable.
* With resource-level versioning, deprecating old versions becomes ambiguous. If some resources are still on v1 while
  others moved to v5, when can you sunset v1? Global versioning provides clear deprecation timelines: "v4 will be
  deprecated on X date."
* Our microservices architecture already provides version granularity. Each microservice owns a bounded domain and can
  version independently of other services. Resource-level versioning adds unnecessary granularity within an
  already-small domain.
* Operations teams need clear answers to "what version is this service on?" Resource-level versioning makes this
  question unanswerable. Global versioning provides clear service version metrics.
* We optimize for client simplicity over implementation convenience. A small amount of consistency work for API teams
  prevents complexity from propagating to every consumer.

### Why path-based versioning

Path-based versioning (`/v5/books`) is chosen over alternatives (headers, query parameters, content negotiation) for
several reasons:

* The version is obvious in URLs, logs, documentation, and debugging tools without inspecting headers or parameters.
* CDNs, proxies, and API gateways can easily route and cache based on path. Header-based versioning complicates caching
  strategies.
* OpenAPI/Swagger, API testing tools, and development frameworks work naturally with path-based versions.
* Developers can call versioned APIs easily from browsers, curl, or any HTTP client without constructing complex
  headers.
* Path-based versioning is the de facto standard among major API providers (Stripe, GitHub, Twilio), making it familiar
  to developers.
* While path-based versioning technically violates pure REST/HATEOAS principles (URIs should be treated as identifiers
  discovered through hypermedia links rather than constructed by clients), the practical benefits far outweigh
  theoretical purity. We prioritize pragmatic REST principles that provide real value: resource-oriented design, proper
  HTTP methods, stateless requests, and appropriate status codes.
* Our organization already uses path-based versioning across most APIs, making it a familiar pattern for both API
  developers and consumers. While usage has been inconsistent, this AEP standardizes the approach rather than
  introducing an entirely new paradigm. Moving to header-based versioning would require retraining teams and updating
  existing integration patterns, creating unnecessary disruption for minimal benefit.

### Why version-specific directories

The recommended project structure intentionally duplicates code across version directories, which may appear to violate
the DRY (Don't Repeat Yourself) principle. However, this is a valid and beneficial exception for several reasons:

* Versions are independent contracts. Each API version represents a distinct contract with clients. Once published, a
  version should remain stable and unchanged. Sharing code between versions creates hidden coupling where a change
  intended for `v3` could inadvertently affect `v2`, violating the stability guarantee.
* When investigating issues or reviewing code, having self-contained version directories means developers can examine
  everything relevant to that version in one place. There's no need to trace through shared abstractions or conditional
  logic to understand how a specific version behaves.
* Teams can refactor and improve code in newer versions without fear of breaking older versions. If `v2` has technical
  debt, `v3` can be implemented with better patterns while `v2` remains untouched and stable for its remaining
  lifecycle.
* When a version reaches end-of-life, teams simply delete the entire directory. With shared code, determining what's
  safe to remove requires careful analysis of what other versions depend on it.
* Developers working on a specific version don't need to understand conditional logic, inheritance hierarchies, or
  abstractions created to share code between versions. Each version is straightforward and explicit.
* Code duplication between versions is time-bounded. Once the old version is sunset (within 12 months maximum), the
  duplicated code is deleted. This is fundamentally different from permanent duplication across a codebase.
* The cost of duplication (slightly more disk space and initial copying effort) is minimal compared to the benefits
  (version isolation, simpler debugging, safe cleanup). Modern version control systems handle file copying efficiently,
  and the duplication exists only during the transition period.
* The principle underlying this approach: Optimize for version independence and operational safety over code reuse. In
  versioned APIs, isolation is more valuable than abstraction.

## References

* [RFC 8594] The Sunset HTTP Header Field
* [RFC 9745] The Deprecation HTTP Response Header Field

[RFC 8594]: https://datatracker.ietf.org/doc/html/rfc8594

[RFC 9745]: https://datatracker.ietf.org/doc/html/rfc9745

[Semantic Versioning]: https://semver.org/

## Changelog

**2025-11-19**: Initial creation
