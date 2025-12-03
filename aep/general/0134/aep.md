# PUT

In REST APIs, it is customary to make a `PUT` request to a resource's URI (for example,
`/publishers/{publisher_id}/books/{book_id}`) to replace that resource entirely with a new representation.
`PUT` can also be used to create a resource at a specific URI when the client specifies the identifier. As defined in
[RFC 9110 Section 9.3.4], `PUT` requests that the state of the target resource be created or replaced with the state
defined by the representation enclosed in the request, and is [idempotent], but not [safe].

## Guidance

### When to use PUT

Use PUT for operations that completely replace a resource with a new representation or for creating a resource at a
client-specified URI.

**Use `PUT` when:**

* Replacing an entire resource with a new representation (e.g., "Replace book 123 with this complete book object").
* Creating a resource where the client specifies the full URI and identifier (e.g., "Create a book with ID 'isbn-123'").
* You want to ensure the complete state of a resource matches the provided representation.

**Do not use `PUT` when:**

* Only partial updates are needed (use [PATCH] instead)
* The server needs to generate or assign the resource identifier (use [POST] to a collection instead)
* The operation has side effects that should not be repeated (use [POST] instead)

A `PUT` request **must** include a complete representation of the resource in the request body.

### General requirements

`PUT` requests:

* **must** be used to replace the entire representation of a resource at a known URI.
* **may** be used to create a resource when the client specifies the complete URI.
* **must** include a complete representation of the resource in the request body.
    * Omitted fields **must** be treated as explicitly set to their default or null values, effectively removing
      previous values.
* **must** have the [Content-Type] header set appropriately to indicate the format of the request body.
* **must** be [idempotent]. Repeating the same PUT request must produce the same result and leave the resource in the
  same state.
* **must not** modify read-only or server-managed fields (e.g., created_at, id). If such fields are included in the
  request, they should be ignored or validated for consistency.

Some resources take longer to be updated than is reasonable for a regular API request. In this situation, the API should
use a [long-running operation].

### Replacing Resources

`PUT` requests for replacing existing resources:

* **must** be made to the resource's canonical [URI path] (e.g., `/publishers/{publisher_id}/books/{book_id}`).
* **must** return a `200 OK` status code with the updated resource representation in the response body.
* **may** return `204 No Content` if no response body is included.

### Creating Resources

`PUT` requests for creating resources:

* **must** be made to the desired resource [URI path] with the client-specified identifier.
* **must** return `201 Created` status code when a new resource is successfully created.
* **may** include a [Location] header containing the URI of the newly created resource.
* **should** include a representation of the created resource in the response body.
* **should** only be supported when client-assigned identifiers are semantically appropriate (e.g., ISBNs, email
  addresses, usernames).

### Partial representations

`PUT` requires a complete representation of the resource. If a field is omitted from the request, it should be treated
as absent from the desired state. Depending on your API's semantics:

* The field may be removed from the resource
* The field may be set to a default or null value
* The request may be rejected as invalid if required fields are missing (`400 Bad Request`)

Document clearly how your API handles omitted fields. If you need partial updates where omitted fields remain unchanged,
use [PATCH] instead.

**Warning:** This effectively deletes data. If a client performs a `GET`, modifies one field, and `PUT`s it back without
including the other fields, those other fields will be erased.

### Response codes

`PUT` requests **must** return appropriate HTTP status codes:

* `200 OK` for successful replacement of an existing resource with a response body
* `201 Created` for successful resource creation
* `204 No Content` for successful replacement or creation with no response body
* `400 Bad Request` for malformed or invalid request data
* `401 Unauthorized` when authentication is required but not provided
* `403 Forbidden` when the client is authenticated but lacks permission to perform the operation
* `404 Not Found` when the parent resource does not exist (e.g., creating a book under a non-existent publisher)
* `409 Conflict` when the request conflicts with the current state (e.g., version mismatch in optimistic concurrency)
* `412 Precondition Failed` when conditional headers like [If-Match] are not satisfied
* `422 Unprocessable Entity` when the request is well-formed but contains semantic errors
* `500 Internal Server Error` for unexpected server errors

### Idempotency

`PUT` is idempotent by definition. Making the same `PUT` request multiple times **must** result in the same resource
state. This means:

* The server replaces the entire resource with the provided representation on every request
* If you need to track modification metadata, use conditional requests with [ETag] headers rather than modifying the
  resource state

### Concurrency

For concurrent modification scenarios, APIs **may** implement optimistic concurrency control using [ETags]:

* The server **may** include an [ETag] header in `GET` and `PUT` responses representing the resource version.
* Clients **may** include an [If-Match] header with the [ETag] value when making `PUT` requests.
* The server **must** return `412 Precondition Failed` if the [ETag] has changed, indicating another client has modified
  the resource.
* If no [If-Match] header is provided, the server **may** either accept the request (last-write-wins) or reject it with
  `428 Precondition Required`, depending on the API's concurrency policy.

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

[safe]: /130#common-method-properties

[idempotent]: /130#common-method-properties

[Content-Type]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Type

[location]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Location

[If-Match]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/If-Match

[If-Unmodified-Since]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/If-Unmodified-Since

[POST]: /post

[PATCH]: /patch

[URI path]: /paths

[long-running operation]: /long-running-operations

## Changelog

**2025-12-02**: Initial creation, adapted from [Google AIP-134][] and aep.dev [AEP-134][].

[Google AIP-134]: https://google.aip.dev/134

[AEP-134]: https://aep.dev/134
