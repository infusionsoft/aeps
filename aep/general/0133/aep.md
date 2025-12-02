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

* Creating a new resource where the server generates the ID (e.g., "Create a new book").
* Triggering an action or operation on a resource (e.g., "Send email", "Reset password").
* Performing complex queries that cannot be expressed via `GET` due to URL length or complexity constraints (
  see [GET with body]).
* Executing batch operations or operations with side effects that do not map to resource creation, replacement, or
  deletion.

**Do NOT use `POST` when:**

* The operation is purely read-only without side effects; use [GET] instead.
* You are replacing an entire resource at a known URI; use [PUT] instead.
* You are partially updating a resource; use [PATCH] instead.
* You are deleting a resource; use [DELETE] instead.

### General requirements

POST requests:

* **must** be used to create a new resource when the server assigns the resource identifier.
* **must** have the [Content-Type] header set appropriately to indicate the format of the request body.
* **must** include a request body unless the operation explicitly requires no input data.
* **must not** be _assumed_ to be [idempotent].
    * Clients **should not** automatically retry failed `POST` requests without considering the consequences.
    * If an endpoint is designed to be idempotent (for example, by accepting an [Idempotency-Key]), this **must** be
      clearly documented.
* **should** be used for operations that modify server state or have side effects.

APIs **must** use more specific HTTP methods when appropriate ([PUT] for full replacement, [PATCH] for partial
updates, [DELETE] for removal) rather than overloading `POST`.

Some resources take longer to be created than is reasonable for a regular API request. In this situation, the
API should use a [long-running operation].

### Creating resources

When using `POST` to create new resources:

* The request **must** be sent to the collection URI (e.g., `/publishers/{publisher_id}/books`).
* The request body **must** contain the resource representation to be created.
* On successful creation, the response **must** return `201 Created`.
* The response **may** include a [Location] header containing the URI of the newly created resource.
* The response body **should** include the complete representation of the created resource, including any
  server-generated fields (e.g., `id`, `createdAt`, `updatedAt`).
    * For bulk creation operations, APIs **may** return a summary or list of IDs/Status objects instead of full
      resources to improve performance.

For example, this request:

```http request
POST /v1/publishers/123/books
Content-Type: application/json

{
    "title": "Les Misérables",
    "author": "Victor Hugo",
    "isbn": "9780451419439"
}
```

Will return:

```http request
201 Created
Location: /v1/publishers/123/books/456
Content-Type: application/json

{
    "id": "456",
    "title": "Les Misérables",
    "author": "Victor Hugo",
    "isbn": "9780451419439",
    "createdAt": "2025-11-12T10:30:00Z",
    "updatedAt": "2025-11-12T10:30:00Z"
}
```

### Creating subordinate resources

POST may be used to create subordinate resources that represent state transitions, actions, or relationships. These
resources are nouns that capture the result or record of an action. For example:

* To cancel an order, `POST` to `/orders/{order_id}/cancellations` to create a cancellation record
* To approve a document, `POST` to `/documents/{document_id}/approvals` to create an approval record
* To add a comment, `POST` to `/posts/{post_id}/comments` to create a comment resource
* To transfer funds, `POST` to `/accounts/{account_id}/transfers` to create a transfer record

This approach models actions as resources, which:

* Provides a clear audit trail of what actions were taken and when
* Allows actions to have their own properties (e.g., a cancellation reason, an approval timestamp)
* Enables querying the history of actions via `GET` on the collection
* Maintains RESTful principles by using nouns rather than verbs in URIs

### Creating related resources

`POST` may be used to create resources that establish relationships between existing resources:

* To assign a user to a team, `POST` to `/teams/{team_id}/members` with user information
* To add a tag to a resource, `POST` to `/users/{user_id}/tags` with tag information
* To create a subscription, `POST` to `/users/{user_id}/subscriptions` with subscription details

This pattern works well when the relationship itself has meaningful properties or when the relationship needs to be
tracked as a first-class resource.

### Custom methods

`POST` is used to implement custom methods for operations that don't fit standard CRUD patterns. Prefer
creating [subordinate resources](#creating-subordinate-resources) over custom methods whenever the action results in a
persisted record/audit trail. Custom methods are covered in detail in AEP-136.

### Response codes

`POST` requests **must** return appropriate HTTP status codes:

* `200 OK` for successful operations that don't create resources (e.g., query operations)
* `201 Created` for successful resource creation
* `202 Accepted` when the request has been accepted for processing but is not yet complete
  (see [long-running operations])
* `204 No Content` for successful operations with no response body
* `400 Bad Request` for invalid request body or parameters
* `401 Unauthorized` when authentication is required but not provided
* `403 Forbidden` when the client lacks permission to perform the operation
* `404 Not Found` when the parent resource does not exist (e.g., creating a book under a non-existent publisher)
* `409 Conflict` when the request conflicts with the current state (e.g., attempting to create a resource that already
  exists)
* `422 Unprocessable Entity` when the request is well-formed but contains semantic errors
* `500 Internal Server Error` for unexpected server errors

### Error handling

When a `POST` request fails during resource creation, the server **must not** create the resource. The operation
**must** be atomic from the client's perspective.

If a `POST` operation is partially completed before encountering an error, the service **should** roll back changes when
possible. If rollback is not possible, the service **must** clearly document the potential for partial state changes.

### Idempotency considerations

For POST operations where duplicate execution would be problematic (such as payment processing or order submission),
APIs **should** support idempotency keys to allow safe retries.

When implementing idempotency keys:

* The API **must** accept an idempotency key via a request header (e.g., [Idempotency-Key]).
* The server **must** store the key and associate it with the operation result.
* Subsequent requests with the same idempotency key **must** return the same result without re-executing the operation.
* The server should **retain** idempotency keys for a reasonable period (e.g., 24 hours).
* The API **must** document the idempotency key behavior, including retention period and scope.

[RFC 9110 Section 9.3.3]: https://datatracker.ietf.org/doc/html/rfc9110#section-9.3.3

[safe]: /130#common-method-properties

[idempotent]: /130#common-method-properties

[GET with body]: /131#get-with-body

[GET]: /get

[PUT]: /put

[PATCH]: /patch

[DELETE]: /delete

[location]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Location

[long-running operations]: /long-running-operations

[Idempotency-Key]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Idempotency-Key

[Content-Type]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Type

## Changelog

**2025-12-02**: Initial creation, adapted from [Google AIP-133][] and aep.dev [AEP-133][].

[Google AIP-133]: https://google.aip.dev/133

[AEP-133]: https://aep.dev/133
