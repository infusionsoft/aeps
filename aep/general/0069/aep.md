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

* **must not** include a request body.
    * If a `DELETE` request contains a body, the body **must** be ignored.
* **must** be [idempotent]. Deleting the same resource multiple times **must** produce the same result; subsequent
  deletions of an already-deleted resource must succeed without error.
* **may** accept query parameters for additional options (e.g., `cascade=true`), but the core deletion operation must be
  determined by the URI alone.

{% tab proto %}

{% tab oas %}

{% sample '../example.oas.yaml', '$.paths./publishers/{publisher_id}/books/{book_id}.delete.parameters' %}

{% endtabs %}

[RFC 9110 Section 9.3.5]: https://datatracker.ietf.org/doc/html/rfc9110#section-9.3.5

[POST]: /http-post

[PATCH]: /http-patch

[PUT]: /http-put

[idempotent]: /64#common-method-properties

## Changelog

* **2026-02-20:** Move this from AEP-135 to AEP-69. Separate out guidelines for `Delete` in new AEP-135.
* **2026-01-21**: Refine soft delete guidance to disallow delete via `PATCH`. Move Soft delete section to its own
  AEP-164.
* **2026-01-21**: Standardize HTTP status code references.
* **2024-12-10:** Initial version, adapted from [Google AIP-135][] and aep.dev [AEP-135][].

[Google AIP-135]: https://google.aip.dev/135

[AEP-135]: https://aep.dev/135
