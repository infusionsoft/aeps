# Delete

In REST APIs, it is customary to make a [DELETE] request to a resource's URI
(for example, `/v1/publishers/{publisherId}/books/{bookId}`) in order to delete
that resource.

Resource-oriented design (AEP-121) honors this pattern through the `Delete`
action. This action accepts the URI representing that resource and usually
returns an empty response.

## Guidance

APIs **should** generally provide a delete action for resources unless it is
not valuable for users to do so.

The `Delete` action **should** succeed even if nothing was deleted. If the
resource did not exist, the action **should not** return [404 Not Found]. See
[idempotency](#idempotency).

The action **must** have [strong consistency][]: the completion of a delete
action **must** mean that the existence of the resource has reached a
steady-state and reading resource state returns a consistent [404 Not Found]
response.

### Operation

Delete actions are specified using the following pattern:

- The action **must** be used to remove a resource at a known URI.
- Some resources take longer to delete than is reasonable for a regular API
  request. In this situation, the API should use a
  [long-running operation](/long-running-operations).

`Delete` operations **must** be made by sending a [DELETE] request to the
resource's canonical [URI path]:

```http
DELETE /v1/publishers/{publisherId}/books/{bookId}
```

### Requests

Delete actions implement a common request pattern:

- The HTTP method **must** be [DELETE], and **must** follow the `DELETE` method
  guidelines in AEP-69.
- If a delete request contains a body, the body **must** be ignored and **must
  not** cause an error (this is required by [RFC 9110][])
- The request **must not** _require_ any query parameters.
  - Optional query parameters **may** be included for additional options (e.g.,
    `cascade=true`), but the core deletion operation must be determined by the
    URI alone.

{% tab proto %}

{% tab oas %}

{% sample '../example.oas.yaml', '$.paths./publishers/{publisherId}/books/{bookId}.delete.parameters' %}

{% endtabs %}

### Responses

- Delete actions **should** return [204 No Content] with no response body if
  the delete was successful.
  - A response body **may** be included if there is a valid need for additional
    information. See [Delete with response body](#delete-with-response-body).

{% tab proto %}

{% tab oas %}

{% sample '../example.oas.yaml', '$.paths./publishers/{publisherId}/books/{bookId}.delete.responses.204' %}

{% endtabs %}

### Errors

A `Delete` action **must** return appropriate error responses. For additional
guidance, see [Errors] and [HTTP status codes].

Most common error scenarios:

- [409 Conflict] **should** be returned if the `cascade` field is `false` (or
  unset) and child resources are present.
- See [authorization checks](/authorization) for details on responses based on
  permissions.

### Soft delete

See the full [Soft delete](/soft-delete) AEP-164 for guidance.

### Cascading delete

Sometimes, it may be necessary for users to be able to delete a resource as
well as all applicable child resources. However, since deletion is usually
permanent, it is also important that users do not do so accidentally, as
reconstructing wiped-out child resources may be quite difficult.

If an API allows deletion of a resource that may have child resources, the API
**should** provide a `bool` `cascade` field on the request, which the user sets
to explicitly opt in to a cascading delete.

The API **should** fail with a [409 Conflict] error if the `cascade` field is
`false` (or unset) and child resources are present.

{% tab proto -%}

{% tab oas -%}

{% sample 'cascading_delete.oas.yaml', '$.paths' %}

{% endtabs %}

### Idempotency

`Delete` operations **must** be idempotent. When a client attempts to delete a
resource that has already been deleted or does not exist, the API **must**
treat the operation as successful and return the same response as if the
resource was just deleted.

This treats deletion as "ensure this resource does not exist" rather than
"remove this specific resource." The approach simplifies client retry logic and
aligns with idempotency principles: repeated identical requests produce the
same result.

APIs **must not** return [404 Not Found] for deletion attempts on non-existent
resources, as this breaks idempotency guarantees.

```http
# First delete removes the resource
DELETE /books/123
204 No Content

# Subsequent deletes return the same response
DELETE /books/123
204 No Content
```

### Delete with response body

Delete actions **should** return [204 No Content] with no response body.
However, APIs **may** return [200 OK] with a response body when additional
information is useful:

```http
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

- Providing confirmation details about what was deleted
- Returning information about cascade-deleted child resources
- Including metadata like deletion timestamps or audit information

## Interface Definitions

{% tab proto %}

{% tab oas %}

{% sample '../example.oas.yaml', '$.paths./publishers/{publisherId}/books/{bookId}.delete' %}

{% endtabs %}

## Further reading

- For soft delete and undelete, see AEP-164.
- For bulk deleting large numbers of resources based on a filter, see AEP-165.

## Rationale

**Not Found vs No Content Response**

Idempotency is crucial for `DELETE` because it allows clients to safely retry
deletion operations without fear of unintended consequences. Network failures,
timeouts, and other transient issues are common in distributed systems, and
idempotent operations enable automatic retry logic. The debate between
returning [404 Not Found] versus [204 No Content] for already-deleted resources
centers on the definition of "idempotent." Both approaches achieve the same end
state (resource doesn't exist), but differ in how they signal completion.
Returning `204` for all deletions (permissive idempotency) is recommended
because it treats the operation as "ensure this resource is deleted" rather
than "delete this specific resource," which better matches client expectations
and simplifies error handling.

## Changelog

- **2026-02-20:** Initial creation, adapted from [Google AIP-135][] and aep.dev
  [AEP-135][].

[Google AIP-135]: https://google.aip.dev/135
[AEP-135]: https://aep.dev/135
[DELETE]: /delete
[strong consistency]: ./0121.md#strong-consistency
[long-running operation]: /long-running-operations
[URI path]: /paths
[RFC 9110]: https://datatracker.ietf.org/doc/html/rfc9110#name-delete
[errors]: /errors
[HTTP status codes]: /status-codes
[200 OK]: /63#200-ok
[204 No Content]: /63#204-no-content
[404 Not Found]: /63#404-not-found
[409 Conflict]: /63#409-conflict
