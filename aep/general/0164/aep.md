# Soft delete

There are several reasons why a client could desire soft delete and undelete
functionality, but one over-arching reason stands out: recovery from mistakes.
A service that supports undelete makes it possible for users to recover
resources that were deleted by accident.

## Guidance

APIs **should** clearly distinguish between soft deletion and hard deletion.

**Soft delete:** The resource is marked as deleted but remains in the system.

* The resource **must not** appear in collection ([GET]) responses by default.
  See [Reading deleted resources](#reading-deleted-resources).
* A [GET] request for an individual soft-deleted resource **must** return [404 Not Found] or [410 Gone] by
  default. See [Reading deleted resources](#reading-deleted-resources).
* The resource **may** be recoverable through an undelete operation (e.g., `POST /books/123:undelete`). See
  [Undelete](#undelete).

Soft delete **should** be implemented as a [DELETE] operation that marks the resource as deleted (this is the
recommended method). However, if there is a need, soft deletes **may** be modeled as explicit lifecycle transitions (see
AEP-216) using a transition resource or [custom method](/custom-methods). `PATCH` **must not** be used to update a
`state` field for deletes, as `state` fields are output only (see AEP-216).

**Hard delete:** The resource is permanently removed.

* The resource and its data are completely removed from the system.
* The deletion **must** be irreversible.
* The resource **must** return [404 Not Found] or [410 Gone] (if you maintain deletion history) on `GET` requests.

### Undelete

Services **may** support the ability to "undelete", to allow for situations
where users mistakenly delete resources and need the ability to recover.

If a resource needs to support `undelete`, the [DELETE] method **must** simply
mark the resource as having been deleted, but not completely remove it from the
system. If the method behaves this way, it **should** still return [204 No Content]
with no response body as described in [DELETE with response body].

Resources that support soft delete **should** have a `purgeTime` field as
described below in [Purging resources](#purging-resources). Additionally, resources **should** include a `DELETED`
state value if the resource includes a `state` field AEP-216.

A resource that supports soft delete **may** provide an `undelete` method:

{% tab proto %}

{% tab oas %}

{% sample 'undelete.oas.yaml', '$.paths' %}

- The HTTP method **must** be `POST`.
- The response message **must** be the resource itself.
    - The response **should** include the fully populated resource unless it is
      infeasible to do so.
- The operation **must not** require any other fields, and **should not**
  contain other optional query parameters except those described in this or
  another AEP.

{% endtabs %}

### Creating deleted resources

If a user attempts to create on a soft-deleted resource (i.e., the resource has the same unique identifier), the
operation **must** return [409 Conflict]. The error response **should** include a
message indicating that a soft-deleted resource with that identifier exists and direct
the user to either use the undelete operation or choose a different identifier.

For example:

```text
{
  "message": "A deleted resource with identifier 'victor-123' already exists.
  Use the undelete operation POST /v1/users/victor-123:undelete to restore it,
  or choose a different identifier."
  // ...rest of error...
}
```

See AEP-193 for full details on error responses.

### Reading deleted resources

APIs **may** provide an optional `show_deleted` query parameter on collection and individual [GET] requests. If `true`,
the API **must** return the resource(s) (with the `DELETED` state value if the resource includes a
[`state` field](/states)).

Soft-deleted resources **must not** be included in responses made to `GET` collection requests (unless the query
parameter `show_deleted` is true).

A `GET` request for a soft deleted individual resource **must not** return the resource (unless the query
parameter `show_deleted` is true). If `show_deleted` is omitted or `false`, these requests **must**
return [404 Not Found] or [410 Gone], see below.

### 404 Not Found vs. 410 Gone

When a client attempts to `GET` a soft-deleted resource without explicitly opting in to view deleted resources, the API
**must** return either [404 Not Found] or [410 Gone].

APIs **should** prefer [404 Not Found] by default.

APIs **may** return [410 Gone] when the service _intentionally_ wants to signal that the identifier is known to the
system, but the resource is no longer available. This is most appropriate when the service:

* needs to distinguish "never existed" from "previously existed but deleted", or
* supports `:undelete` and `410` helps clients present better guidance.

Regardless of whether `404` or `410` is used, when the client explicitly requests deleted data (`show_deleted=true`),
the API **must** return the deleted resource if it exists and is still retained.

### Long-running undelete

Some services take longer to undelete a resource than is reasonable for a regular API request. In this situation, the
API **should** use a [long-running operation] instead.

### Purging resources

Resources that support soft delete **should** have a `purgeTime` field which indicates the time when a soft deleted
resource will be purged (hard deleted) from the system. This field **must** be named `purgeTime`.

Services that soft delete resources **may** choose a reasonable strategy for purging those resources, including:

* automatic purging after a reasonable time (such as 30 days)
* allowing users to set an expiry time AEP-214
* retaining the resources indefinitely (`purgeTime = null`)

Regardless of what strategy is selected, the service **should** document _when_ soft deleted resources will be
completely removed.

### Declarative-friendly resources

Soft delete creates a challenge for declarative tooling (such as
Terraform, Kubernetes, or other infrastructure-as-code tools). When a resource
identifier has been soft-deleted, that identifier cannot be reused without first
calling the undelete operation.

This creates friction for declarative clients because they typically only understand
create and delete operations, not undelete. Consider this workflow:

1. Declarative config specifies resource `users/victor-123` should exist
2. User removes it from config; tool soft-deletes `users/victor-123`
3. User adds it back to config; tool attempts to create `users/victor-123`
4. API returns [409 Conflict] because the identifier belongs to a soft-deleted resource

To resolve this, users must either:

* Explicitly call the undelete operation (an imperative action outside the declarative workflow), or
* Use a different identifier for the new resource

Declarative tools **may** choose not to map any operations to undelete at all,
requiring users to perform undelete when needed. Alternatively,
declarative tools **may** implement logic to automatically call undelete when
encountering a [409 Conflict] on create, ideally with user confirmation to ensure
the restoration is intentional.

### Errors

Also see [errors](/errors) for additional guidance.

If the user calling `undelete` has proper permission, but the requested resource does not
exist (either it was never created or already expunged), the service **must**
error with [404 Not Found].

If the user calling `undelete` has proper permission, but the requested
resource is not deleted, the service **must** error with [409 Conflict].

## Rationale

### 404 over 410 responses

The choice to prefer [404 Not Found] over [410 Gone] was made because `404` treats soft-deleted resources as
non-existent for typical read paths, which:

* reduces accidental reliance on deleted resources,
* simplifies client logic (the same handling as "never existed"), and
* avoids revealing whether a given identifier previously existed when the client has not explicitly requested deleted
  data.

## Further reading

- For the `DELETE` method, see AEP-135.
- For long-running operations, see AEP-151.
- For resource freshness validation (`etag`), see AEP-154.

## Changelog

* **2026-01-21**: Initial creation, adapted from [Google AIP-164][] and aep.dev [AEP-164][].

[Google AIP-164]: https://google.aip.dev/164

[AEP-164]: https://aep.dev/164

[GET]: /get

[DELETE]: /delete

[DELETE with response body]: /135#delete-with-response-body

[long-running operation]: /long-running-operations

[204 No Content]: /63#204-no-content

[404 Not Found]: /63#404-not-found

[409 Conflict]: /63#409-conflict

[410 Gone]: /63#410-gone
