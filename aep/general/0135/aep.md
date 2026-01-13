# DELETE

In REST APIs, it is customary to make a DELETE request to a resource's URI (for example,
`/publishers/{publisher_id}/books/{book_id}`) to remove that resource. As defined in
[RFC 9110 Section 9.3.5], `DELETE` requests that the origin server remove the association between the target resource
and its current functionality. In effect, this method is similar to the `rm` command in UNIX: it expresses a deletion
operation on the URI mapping of the origin server rather than an expectation that the previously associated information
be deleted.

## Guidance

### When to use DELETE

Use `DELETE` for operations that remove a resource from the system.

**Use `DELETE` when:**

* Removing a specific resource by its identifier (e.g., "Delete book 123").
* The operation permanently removes the resource or marks it as deleted.

**Do NOT use `DELETE` when:**

* You're deactivating or archiving a resource rather than deleting it; use [PATCH] or [PUT] to update the resource
  instead.
    * (e.g., `PATCH /users/123` with `{"state": "inactive"}`).
* The operation involves complex business logic beyond simple deletion; consider using [POST] to a reified resource or
  custom method
    * e.g.,`POST /orders/123/cancellations` or `POST /orders/123:cancel`.
* You're removing a relationship between resources rather than the resource itself; use `DELETE` on the relationship
  endpoint or use [PATCH] to update a reference field.

### General requirements

`DELETE` requests:

* **must** be used to remove a resource at a known URI.
* **must** be made to the resource's canonical [URI path] (e.g., `/publishers/{publisher_id}/books/{book_id}`).
* **must not** include a request body.
    * If a `DELETE` request contains a body, the body **must** be ignored.
* **must** be [idempotent]. Deleting the same resource multiple times **must** produce the same result; subsequent
  deletions of an already-deleted resource must succeed without error.
* **may** accept query parameters for additional options (e.g., `cascade=true`), but the core deletion operation must be
  determined by the URI alone.

Some resources take longer to be deleted than is reasonable for a regular API request. In this situation, the API should
use a [long-running operation].

{% tab proto %}

{% tab oas %}

{% sample '../example.oas.yaml', '$.paths./publishers/{publisher_id}/books/{book_id}.delete.parameters' %}

{% endtabs %}

### Idempotency

`DELETE` operations **must** be idempotent. This means that deleting a resource multiple times must produce the same
result as deleting it once. APIs **must** implement permissive idempotency for `DELETE` operations. When a client
attempts to delete a resource that has already been deleted or does not exist, the API must return `204 No Content` (or
`200 OK` if returning a response body), treating the operation as successful.

```http request
# First delete call removes the resource and returns a 204
DELETE /books/123
204 No Content

# Subsequent delete calls don't remove the non-existant resource,
# but still return 204
DELETE /books/123
204 No Content
```

This approach treats deletion as "ensure this resource does not exist." Both the first and subsequent deletions return
`204 No Content`, indicating successful completion of the operation regardless of whether the resource existed. This
better aligns with the idempotency principle and simplifies client retry logic by eliminating the need for special
handling of 404 errors during retries.

APIs **must not** return `404 Not Found` for deletion attempts on non-existent resources, as this breaks idempotency
guarantees and complicates client error handling.

### Soft delete vs hard delete

APIs should clearly distinguish between soft deletion (marking a resource as deleted while preserving data) and hard
deletion (permanently removing data).

**Soft delete:** The resource is marked as deleted but remains in the system.

* The resource **should** no longer appear in list operations by default.
* The resource **should** return `404 Not Found` or `410 Gone` on `GET` requests, unless specifically querying for
  deleted resources.
* The resource **may** be recoverable through an undelete operation (e.g., `POST /books/123:undelete`).
* Soft delete **may** be implemented either as a `DELETE` operation that marks the resource as deleted, or as a `PATCH`
  operation that updates a state field (e.g., `{"state": "deleted"}`). Both approaches are valid; choose based on your
  API's semantic requirements and whether you want deletion to feel like removal or state change.

**Hard delete:** The resource is permanently removed.

* The resource and its data are completely removed from the system.
* The deletion should be irreversible.
* The resource **should** return `404 Not Found` or `410 Gone` (if you maintain deletion history) on `GET` requests to
  previously deleted resources.

### Cascade deletion

Sometimes, it may be necessary for users to be able to delete a resource as well as all applicable child resources.
However, since deletion is usually permanent, it is also important that users do not do so accidentally, as
reconstructing wiped-out child resources may be quite difficult.

If an API allows deletion of a resource that may have child resources, the API **must** provide a `bool` `cascade` field
on the request, which the user sets to explicitly opt in to a cascading delete.

{% tab proto -%}

{% tab oas -%}

{% sample 'cascading_delete.oas.yaml', '$.paths' %}

The API **must** fail with a `409 Conflict` error if the `cascade` field is `false` (or unset) and child resources are
present.

{% endtabs %}

### Deletion with response body

Delete methods **should** return `204 No Content` with no response body. This is the preferred method. However,
exceptions exist, and APIs **may** return `200 OK` with a response body when additional information is useful:

```http request
DELETE /books/123

200 OK
Content-Type: application/json

{
  "id": "123",
  "deleted_at": "2024-12-02T10:30:00Z",
  "cascade_deleted": [
    {"type": "review", "id": "review-1"},
    {"type": "review", "id": "review-2"}
  ]
}
```

This approach is useful when:

* Providing confirmation details about what was deleted
* Returning information about cascade-deleted resources
* Including metadata like deletion timestamps or audit information

### Response codes

`DELETE` requests **must** return appropriate HTTP status codes:

* `200 OK` for successful deletion with a response body
* `202 Accepted` for deletion operations that have been accepted but not yet completed
* `204 No Content` for successful deletion with no response body (most common)
* `400 Bad Request` for malformed requests or invalid parameters
* `401 Unauthorized` when authentication is required but not provided
* `403 Forbidden` when the client is authenticated but lacks permission to delete the resource
* `409 Conflict` when the deletion cannot be completed due to the current state (e.g., cannot delete a resource with
  active dependencies)
* `410 Gone` when the resource previously existed but has been permanently deleted (_optional_, used to distinguish from
  resources that never existed, if there is an audit trail to know the resource once existed)
* `500 Internal Server` Error for unexpected server errors

If the user does not have permission to access the resource, regardless of whether it exists, the service **must** error
with `403 Forbidden`. Permission **must** be checked before checking if the resource exists.

If the user does have proper permission, but the requested resource does not exist, the service **must** error with
`404 Not found`.

## Rationale

**Not Found vs No Content Response**

Idempotency is crucial for `DELETE` because it allows clients to safely retry deletion operations without fear of
unintended consequences. Network failures, timeouts, and other transient issues are common in distributed systems, and
idempotent operations enable automatic retry logic. The debate between returning `404 Not Found` versus `204 No Content`
for already-deleted resources centers on the definition of "idempotent." Both approaches achieve the same end state
(resource doesn't exist), but differ in how they signal completion. Returning `204` for all deletions (permissive
idempotency) is recommended because it treats the operation as "ensure this resource is deleted" rather than "delete
this specific resource," which better matches client expectations and simplifies error handling.

[RFC 9110 Section 9.3.5]: https://datatracker.ietf.org/doc/html/rfc9110#section-9.3.5

[POST]: /post

[PATCH]: /patch

[PUT]: /put

[URI path]: /paths

[idempotent]: /130#common-method-properties

[long-running operation]: /long-running-operations

## Changelog

**2024-12-10:** Initial version, adapted from [Google AIP-135][] and aep.dev [AEP-135][].

[Google AIP-135]: https://google.aip.dev/135

[AEP-135]: https://aep.dev/135
