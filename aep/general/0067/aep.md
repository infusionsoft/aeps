# PUT

In REST APIs, it is customary to make a `PUT` request to a resource's URI (for example,
`/publishers/{publisherId}/books/{bookId}`) to replace that resource entirely with a new representation.
`PUT` can also be used to create a resource at a specific URI when the client specifies the identifier. As defined in
[RFC 9110 Section 9.3.4], `PUT` requests that the state of the target resource be created or replaced with the state
defined by the representation enclosed in the request, and is [idempotent], but not [safe].

## Guidance

### When to use PUT

Use `PUT` for operations that completely replace a resource with a new representation or for creating a resource at a
client-specified URI.

**Use `PUT` when:**

* Replacing an entire resource with a new representation (e.g., "Replace book 123 with this complete book object").
* Creating a resource where the client specifies the full URI and identifier (e.g., "Create a book with ID 'isbn-123'").
* You want to ensure the complete state of a resource matches the provided representation.

**Do not use `PUT` when:**

* Updating a resource (use [PATCH] instead)
* The server needs to generate or assign the resource identifier (use [POST] to a collection instead)
* The operation has side effects that should not be repeated (use [POST] instead)

### General requirements

`PUT` requests:

* **must** have the [Content-Type] header set appropriately to indicate the format of the request body.
* **must** be [idempotent]. Repeating the same `PUT` request must produce the same result and leave the resource in the
  same state.

### Idempotency

`PUT` is idempotent by definition. Making the same `PUT` request multiple times **must** result in the same resource
state. This means:

* The server replaces the entire resource with the provided representation on every request
* If you need to track modification metadata, use conditional requests with [ETag] headers rather than modifying the
  resource state. See AEP-154 for more details.

### PATCH and PUT

**`PUT` is not an update.** `PUT` means complete replacement: "delete everything at this location and put _THIS_ exact
representation in its place." Any fields omitted from a `PUT` request will be lost or reset to default values.

[PATCH] is designed for updates. `PATCH` requests only modify the fields explicitly included in the request, preserving
all other fields. This makes `PATCH` forward-compatible with schema evolution. If new fields are added to a resource,
existing `PATCH` operations will not inadvertently remove them.

APIs **must not** use `PUT` for updates. Use [PATCH] for updates and reserve `PUT` for the [Apply] action (complete
replacement or creation with client-specified IDs).

## Further Reading

- [AEP-154: Preconditions](/154) - Guidance on using ETags and conditional headers for concurrency control.

[RFC 9110 Section 9.3.4]: https://datatracker.ietf.org/doc/html/rfc9110#section-9.3.4

[safe]: /64#common-method-properties

[idempotent]: /64#common-method-properties

[Content-Type]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Type

[location]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Location

[POST]: /http-post

[PATCH]: /http-patch

[ETag]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/ETag

[apply]: /apply

## Changelog

* **2026-02-24**: Move concurrency to AEP-154.
* **2026-02-20**: Move this from AEP-133 to AEP-67. Separate out guidelines for `Apply` in new AEP-137.
* **2026-01-21**: Standardize HTTP status code references.
* **2025-12-02**: Initial creation, adapted from [Google AIP-134][] and aep.dev [AEP-134][].

[Google AIP-134]: https://google.aip.dev/134

[AEP-134]: https://aep.dev/134
