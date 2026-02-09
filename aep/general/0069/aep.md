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
* The operation marks a resource as deleted.
* The operation permanently removes the resource.

**Do NOT use `DELETE` when:**

* You're deactivating, archiving, or otherwise doing something that equates to a state change in a resource. Rather than
  deleting it, use a state change as described in AEP-216.
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
* **should** return [204 No Content], unless there is a valid need for additional information in the response body.
  See [DELETE with response body](#delete-with-response-body).

Some resources take longer to be deleted than is reasonable for a regular API request. In this situation, the API should
use a [long-running operation].

{% tab proto %}

{% tab oas %}

{% sample '../example.oas.yaml', '$.paths./publishers/{publisher_id}/books/{book_id}.delete.parameters' %}

{% endtabs %}

### Idempotency

`DELETE` operations **must** be idempotent. This means that deleting a resource multiple times must produce the same
result as deleting it once. APIs **must** implement permissive idempotency for `DELETE` operations. When a client
attempts to delete a resource that has already been deleted or does not exist, the API **must**
return [204 No Content] (or [200 OK] if returning a response body), treating the operation as successful.

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
[204 No Content], indicating successful completion of the operation regardless of whether the resource existed. This
better aligns with the idempotency principle and simplifies client retry logic by eliminating the need for special
handling of 404 errors during retries.

APIs **must not** return [404 Not Found] for deletion attempts on non-existent resources, as this breaks idempotency
guarantees and complicates client error handling.

### Soft deletes

See the full [Soft delete](/soft-delete) AEP-164 for guidance.

### Cascade deletion

Sometimes, it may be necessary for users to be able to delete a resource as well as all applicable child resources.
However, since deletion is usually permanent, it is also important that users do not do so accidentally, as
reconstructing wiped-out child resources may be quite difficult.

If an API allows deletion of a resource that may have child resources, the API **must** provide a `bool` `cascade` field
on the request, which the user sets to explicitly opt in to a cascading delete.

{% tab proto -%}

{% tab oas -%}

{% sample 'cascading_delete.oas.yaml', '$.paths' %}

The API **must** fail with a [409 Conflict] error if the `cascade` field is `false` (or unset) and child resources are
present.

{% endtabs %}

### DELETE with response body

Delete methods **should** return [204 No Content] with no response body. This is the preferred method. However,
exceptions exist, and APIs **may** return [200 OK] with a response body when additional information is useful:

```http request
DELETE /books/123

200 OK
Content-Type: application/json

{
  "id": "123",
  "deletedTime": "2024-12-02T10:30:00Z",
  "cascadeDeleted": [
    {"type": "review", "id": "review-1"},
    {"type": "review", "id": "review-2"}
  ]
}
```

This approach is useful when:

* Providing confirmation details about what was deleted
* Returning information about cascade-deleted resources
* Including metadata like deletion timestamps or audit information

## Rationale

**Not Found vs No Content Response**

Idempotency is crucial for `DELETE` because it allows clients to safely retry deletion operations without fear of
unintended consequences. Network failures, timeouts, and other transient issues are common in distributed systems, and
idempotent operations enable automatic retry logic. The debate between returning [404 Not Found] versus [204 No Content]
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

[custom method]: /custom-methods

[200 OK]: /63#200-ok

[204 No Content]: /63#204-no-content

[404 Not Found]: /63#404-not-found

[409 Conflict]: /63#409-conflict

## Changelog

* **2026-01-21**: Refine soft delete guidance to disallow delete via `PATCH`. Move Soft delete section to its own
  AEP-164.
* **2026-01-21**: Standardize HTTP status code references.
* **2024-12-10:** Initial version, adapted from [Google AIP-135][] and aep.dev [AEP-135][].

[Google AIP-135]: https://google.aip.dev/135

[AEP-135]: https://aep.dev/135
