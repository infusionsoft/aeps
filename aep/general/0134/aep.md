# Update

In REST APIs, it is customary to make a [PATCH] request to a
resource's URI (for example, `/v1/publishers/{publisherId}/books/{bookId}`)
in order to update that resource.

Resource-oriented design AEP-121 honors this pattern through the `Update`
action (which mirrors the REST `PATCH` behavior). These actions accept the URI
representing that resource and return the resource.

Also see the [apply](/apply) action, with guidance on how to replace resources.

## Guidance

APIs **should** provide an update action for resources unless it is not
valuable for users to do so. The purpose of the update action is to make
changes to the resources without causing side effects.

### Operation

- The action **should** support partial resource update, and the HTTP method
  **must** be [PATCH].
    - `PATCH` **must** follow the guidelines in AEP-68.
- The operation **must** have [strong consistency][].
- It **must** be used to partially update a resource at a known URI.
- Some resources take longer to be updated than is reasonable for a regular API
  request. In this situation, the API should use a
  [long-running operation](/long-running-operations).
- They **must not** modify read-only or server-managed fields (e.g., `createdTime`).

`Update` operations **must** be made by sending a [PATCH] request to the resource's canonical [URI path]:

```http
PATCH /v1/publishers/{publisherId}/books/{bookId}
```

### Requests

Update actions implement a common request pattern:

- The action **must** use the [JSON Merge Patch with fieldMask](#json-merge-patch-with-fieldmask) as the update
  strategy.
    - It **must** adhere to the behavior specified in [RFC 7396] JSON Merge Patch.
- The server **must** support MIME type `application/merge-patch+json` to
  adhere to [RFC 7396].
- The request body **must** be a partial representation of the resource; only the fields to be updated. It **must**
  include a request body that describes the changes to be applied.
- If read-only fields are included in the request, they **should** be ignored or return [400 Bad Request], depending on
  your API's semantics.
- Unrecognized fields **may** be ignored or **may** cause a [400 Bad Request], depending on the API's semantics.
    - This **must** be documented.
- Fields omitted from the request **must** remain unchanged in the resource.

### JSON Merge Patch with fieldMask

APIs **must** use the [RFC 7396] JSON Merge Patch with field masking approach for `Update` operations. Field masking
uses a simple partial JSON object with an explicit field mask parameter to indicate which fields to update.

* The MIME Type of the request **must** be `application/merge-patch+json`.
* The field mask **must** be provided as a query parameter named `updateMask`.
* The field mask **must** be a comma-separated list of fields (e.g., `updateMask=field1,field2,nested.field`)
* If no `updateMask` is provided, the request **should** return [400 Bad Request] to ensure explicit intent.
* Only fields listed in the `updateMask` **must** be updated on the resource.
* Fields present in the request body but not in the `updateMask` **must** be ignored.
* Fields listed in the `updateMask` but not present in the request body **should** return [400 Bad Request].
* To clear a field value, include the field in both the `updateMask` and the request body with an explicit `null` value.
* Array fields **must** be replaced entirely when updated. A limitation of field masking is that it does not support
  individual array element updates. To modify an array, include the entire array field in the `updateMask` and provide
  the
  complete new array in the request body.
* Nested fields **should** be specified using dot notation (e.g., `address.city`, `contact.email`).
    * When updating nested fields, only the specified nested field is modified; sibling fields within the same parent
      object **must** remain unchanged.
    * To update multiple fields within a nested object, each field **must** be listed separately in the `updateMask` (
      e.g., `address.city`,`address.zip`).
    * To replace an entire nested object, specify only the parent field in the updateMask (e.g., `address`). In this
      case, the entire object is replaced with the provided value.

In the following example, only the `name` and `address.city` fields are updated. Any other fields this resource may
have (`address.street`, `address.state`, `email`, etc.) remain unchanged.

```http request
PATCH /users/456?updateMask=name,address.city
Content-Type: application/merge-patch+json

{
  "name": "Bruce Wayne",
  "address": {
    "city": "Gotham"
  }
}
```

### Responses

- On a successful update, the response **must** return [200 OK].
- The MIME Type of the response **must** be `application/json`. It **must not** be `application/merge-patch+json`.

The response body:

- **must** be the resource itself. There is no separate response schema.
- **should** include the complete representation of the updated resource.
- **must** include any fields that were provided unless they are input only.
- **must** include any server-generated fields (e.g., `id`, `createdTime`, `updatedTime`).
- **should** return the complete updated resource in the response, not just the fields that were modified. This allows
  clients to see the full result of their changes, including any server-side transformations or computed fields.
- For bulk update operations, APIs **may** return a summary or list of IDs/Status objects instead of full
  resources to improve performance.

{% tab proto %}

{% tab oas %}

{% sample '../example.oas.yaml', '$.paths./publishers/{publisherId}/books/{bookId}.patch.responses.200' %}

{% endtabs %}

### Errors

An `Update` action **must** return appropriate error responses. For additional guidance, see [Errors]
and [HTTP status codes].

Most common error scenarios:

* [400 Bad Request] **should** be returned if:
    * the request body is malformed
    * fields are listed in the `updateMask` but not present in the request body
    * no `updateMask` query parameter is provided
* [404 Not Found] **should** be returned if the resource does not exist.
* [409 Conflict] **should** be returned if the resource could not be updated due to a conflict with the current state of
  the resource.
* See [authorization checks](/authorization) for details on responses based on permissions.

### Side effects

In general, update actions are intended to update the data within the resource.
Update actions **should not** trigger other side effects. Instead, side effects
**should** be triggered by custom actions.

In particular, this entails that [state fields][] **must not** be directly
writable in update actions.

### PATCH and PUT

Updates **must** be done with a [PATCH]. Applies **must** be done with a [PUT]. See
the [PATCH and PUT](/67#patch-and-put) section of AEP-67 for more information.

### Etags and preconditions

See [etags](/etags) for more information about adding headers and metadata such
as `ETag` and `If-Match` for supporting resource freshness validation and other
preconditions.

### Changing resource ID

`Update` actions **must not** be used to change the ID of a resource. In a REST API, a resource's ID is a fundamental
part of its URI and **should** be treated as immutable. Changing the ID is considered a bad practice. If the ID must be
changed for business or technical reasons, then a new resource **must** be created using [Create] or [Apply], and the
old resource **should** be deleted.

APIs **may** provide a redirect from the old URI to the new one using [301 Moved Permanently] in requests to the old
URI. This ensures clients are aware of the move. The response **may** also include a [Location] header pointing to the
new URI.

## Interface Definitions

{% tab proto %}

{% tab oas %}

{% sample '../example.oas.yaml', '$.paths./publishers/{publisherId}/books/{bookId}.patch' %}

{% endtabs %}

## Rationale

**Why field masking?**

[RFC 7396] is a popular and well-understood standard for HTTP. Introducing a new standard would make our APIs less
idiomatic.

We've added field masking on top of JSON Merge Patch because it provides the optimal balance of simplicity,
explicitness, and functionality. The `updateMask` parameter makes intent completely clear, preventing accidental updates
and eliminating ambiguity about which fields are being modified. It also helps to alleviate the null-value ambiguity of
plain Merge Patch. Dot notation (e.g., `address.city`) provides a straightforward way to update specific fields within
nested objects.

## Changelog

* **2026-02-20**: Initial creation, adapted from [Google AIP-134][] and aep.dev [AEP-134][].

[Google AIP-134]: https://google.aip.dev/134

[AEP-134]: https://aep.dev/134

[state fields]: ./0216

[strong consistency]: /121#strong-consistency

[create]: /create

[apply]: /apply

[PUT]: /http-put

[PATCH]: /http-patch

[URI path]: /paths

[RFC 7396]: https://datatracker.ietf.org/doc/html/rfc7396

[location]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Location

[errors]: /errors

[HTTP status codes]: /status-codes

[200 OK]: /63#200-ok

[301 Moved Permanently]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/301

[400 Bad Request]: /63#400-bad-request

[404 Not Found]: /63#404-not-found

[409 Conflict]: /63#409-conflict
