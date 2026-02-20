# POST

In REST APIs, the `POST` method is used to create new resources, perform operations that don't fit other HTTP methods,
or execute actions on existing resources. Unlike `GET`, `POST` requests are neither [safe] nor [idempotent], meaning
they may modify server state and repeated identical requests may produce different results.

As defined in [RFC 9110 Section 9.3.3], `POST` is used to request that the target resource process the representation
enclosed in the request according to the resource's own specific semantics.

## Guidance

### When to use POST

Use `POST` for operations that create new resources where the server assigns the resource identifier, or for operations
that do not align with the semantics of other HTTP methods.

**Use `POST` when:**

* Creating a new resource with a server-generated ID (e.g., "Create a new book").
* Triggering an action or operation on a resource (e.g., "Send email", "Reset password").
* Performing complex queries that cannot be expressed via `GET` due to URL length or complexity constraints
  (see [GET with body]).
* Executing batch operations or operations with side effects that do not map to resource creation, replacement, or
  deletion.

**Do NOT use `POST` when:**

* The operation is purely read-only without side effects; use [GET] instead.
* You are creating a new resource at a known URI (client-generated ID); use [PUT] instead.
* You are partially updating a resource; use [PATCH] instead.
* You are deleting a resource; use [DELETE] instead.

### General requirements

`POST` requests:

* **must** have the [Content-Type] header set appropriately to indicate the format of the request body.
* **must** include a request body unless the operation explicitly requires no input data.
* **must not** be _assumed_ to be [idempotent].
    * Clients **should not** automatically retry failed `POST` requests without considering the consequences.
    * If an endpoint is designed to be idempotent (for example, by accepting an [Idempotency-Key]), this **must** be
      clearly documented.
* **should** be used for operations that modify server state or have side effects.

APIs **must** use more specific HTTP methods when appropriate ([PUT] for full replacement, [PATCH] for partial
updates, [DELETE] for removal) rather than overloading `POST`.

### Custom methods

`POST` is the primary method used for "reifying" concepts; converting a process, verb, or relationship into a distinct
resource. For best practices around this, refer to AEP-121.

`POST` is used to implement custom methods for operations that don't fit standard CRUD patterns. Custom methods are
covered in detail in AEP-136.

### Error handling

If a `POST` operation is partially completed before encountering an error, the service **should** roll back changes when
possible. If rollback is not possible, the service **must** clearly document the potential for partial state changes.

### Idempotency

For `POST` operations where duplicate execution would be problematic (such as payment processing or order submission),
APIs **should** support an [Idempotency-Key] to allow safe retries.

[RFC 9110 Section 9.3.3]: https://datatracker.ietf.org/doc/html/rfc9110#section-9.3.3

[safe]: /64#common-method-properties

[idempotent]: /64#common-method-properties

[GET with body]: /131#get-with-body

[GET]: /http-get

[PUT]: /http-put

[PATCH]: /http-patch

[DELETE]: /http-delete

[Idempotency-Key]: /idempotency-key

[Content-Type]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Type

## Changelog

* **2026-02-19**: Move this from AEP-132 to AEP-66. Separate out guidelines for `Create`s in new AEP-133; this AEP will
  focus on general `POST` requests.
* **2026-01-21**: Standardize HTTP status code references.
* **2025-12-09**: Point to resource-oriented design (AEP-121) instead of re-iterating the same concepts in it
* **2025-12-02**: Initial creation, adapted from [Google AIP-133][] and aep.dev [AEP-133][].

[Google AIP-133]: https://google.aip.dev/133

[AEP-133]: https://aep.dev/133
