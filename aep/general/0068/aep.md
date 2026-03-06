# PATCH

In REST APIs, it is customary to make a PATCH request to a resource's URI (for example,
`/publishers/{publisherId}/books/{bookId}`) to partially update that resource. Unlike [PUT], which replaces the entire
resource, `PATCH` applies a set of changes to modify only specific fields. As defined in [RFC 5789], `PATCH` requests
that a set of changes described in the request be applied to the resource identified by the request URI.

## Guidance

### When to use PATCH

Use `PATCH` for operations that modify specific fields of a resource without requiring the client to send the complete
resource representation.

**Use `PATCH` when:**

* Updating one or more specific fields of a resource (e.g., "Update the title of book 123").
* The client does not have or does not want to send the complete resource representation.
* You want to minimize bandwidth by only sending changed fields.
* The resource is large and sending the complete representation for small changes would be inefficient.

**Do NOT use `PATCH` when:**

* Replacing the entire resource; use [PUT] instead.

### General requirements

`PATCH` requests:

* **must** have the [Content-Type] header set appropriately to indicate the format of the request body.
* **must not** be _assumed_ to be [idempotent].
    * `PATCH` operations **may** be designed to be idempotent.
    * APIs **must** document if a `PATCH` endpoint is idempotent.

### Idempotency

While it is not strictly required to be so by the HTTP specification, `PATCH` **may** be idempotent. The idempotency of
a `PATCH` operation depends on the patch format and the nature of the changes. The field mask approach is _typically_
idempotent (applying the same patch multiple times produces the same result); however, it shouldn't be assumed a `PATCH`
is idempotent unless it is clearly documented. APIs **must** clearly document if a `PATCH` endpoint is idempotent.
`PATCH` operations that require idempotency **should** support an [Idempotency-Key].

## Further Reading

- [AEP-154: Preconditions](/154) - Guidance on using ETags and conditional headers for concurrency control.

[RFC 5789]: https://datatracker.ietf.org/doc/html/rfc5789

[GET]: /http-get

[PUT]: /http-put

[DELETE]: /http-delete

[idempotent]: /64#common-method-properties

[Idempotency-Key]: /idempotency-key

[Content-Type]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Type

## Changelog

* **2026-02-20**: Move this from AEP-134 to AEP-68. Separate out guidelines for `Update` in new AEP-134.
* **2026-01-30**: Change `update_mask` to `updateMask` to match query param spec
* **2026-01-21**: Standardize HTTP status code references.
* **2025-12-09**: Initial creation
