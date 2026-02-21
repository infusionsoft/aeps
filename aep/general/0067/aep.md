# PUT

In REST APIs, it is customary to make a `PUT` request to a resource's URI (for example,
`/publishers/{publisher_id}/books/{book_id}`) to replace that resource entirely with a new representation.
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
  resource state

### PATCH and PUT

**`PUT` is not an update.** `PUT` means complete replacement: "delete everything at this location and put _THIS_ exact
representation in its place." Any fields omitted from a `PUT` request will be lost or reset to default values.

[PATCH] is designed for updates. `PATCH` requests only modify the fields explicitly included in the request, preserving
all other fields. This makes `PATCH` forward-compatible with schema evolution. If new fields are added to a resource,
existing `PATCH` operations will not inadvertently remove them.

APIs **must not** use `PUT` for updates. Use [PATCH] for updates and reserve `PUT` for the [Apply] action (complete
replacement or creation with client-specified IDs).

### Concurrency

For concurrent modification scenarios, APIs **may** implement optimistic concurrency control using [ETag]:

* The server **may** include an [ETag] header in `GET` and `PUT` responses representing the resource version.
* Clients **may** include an [If-Match] header with the [ETag] value when making `PUT` requests.
* The server **must** return [412 Precondition Failed] if the [ETag] has changed, indicating another client has modified
  the resource.
* If no [If-Match] header is provided, the server **may** either accept the request (last-write-wins) or reject it with
  [428 Precondition Required], depending on the API's concurrency policy.

Example: Successful update with concurrency control

```http request
# Client retrieves the current resource
GET /books/123
ETag: "v1"

{
"id": "123",
"title": "Original Title",
"author": "Jane Doe"
}

# Client updates the resource with the ETag
PUT /books/123
If-Match: "v1"
Content-Type: application/json

{
"id": "123",
"title": "Updated Title",
"author": "Jane Doe"
}

# Server accepts the update
200 OK
ETag: "v2"

{
"id": "123",
"title": "Updated Title",
"author": "Jane Doe"
}
```

Example: Concurrent modification conflict

```http request
# Client A retrieves the resource
GET /books/123
ETag: "v1"

# Client B also retrieves the resource
GET /books/123
ETag: "v1"

# Client A successfully updates
PUT /books/123
If-Match: "v1"
...
200 OK
ETag: "v2"

# Client B attempts to update with stale ETag
PUT /books/123
If-Match: "v1"
Content-Type: application/json

{
"id": "123",
"title": "Different Title",
"author": "Jane Doe"
}

# Server rejects due to ETag mismatch
412 Precondition Failed

{
"error": "Precondition Failed",
"message": "The resource has been modified by another client. Please retrieve the latest version and retry."
}
```

[RFC 9110 Section 9.3.4]: https://datatracker.ietf.org/doc/html/rfc9110#section-9.3.4

[safe]: /64#common-method-properties

[idempotent]: /64#common-method-properties

[Content-Type]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Type

[location]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Location

[POST]: /http-post

[PATCH]: /http-patch

[If-Match]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/If-Match

[If-Unmodified-Since]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/If-Unmodified-Since

[ETag]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/ETag

[412 Precondition Failed]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/412

[428 Precondition Required]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/428

[apply]: /apply

## Changelog

* **2026-02-20**: Move this from AEP-133 to AEP-67. Separate out guidelines for `Apply` in new AEP-137.
* **2026-01-21**: Standardize HTTP status code references.
* **2025-12-02**: Initial creation, adapted from [Google AIP-134][] and aep.dev [AEP-134][].

[Google AIP-134]: https://google.aip.dev/134

[AEP-134]: https://aep.dev/134
