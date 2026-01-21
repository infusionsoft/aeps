# PATCH

In REST APIs, it is customary to make a PATCH request to a resource's URI (for example,
`/publishers/{publisher_id}/books/{book_id}`) to partially update that resource. Unlike [PUT], which replaces the entire
resource, `PATCH` applies a set of changes to modify only specific fields. As defined in [RFC 5789], `PATCH` requests
that a set of changes described in the request be applied to the resource identified by the request URI.

## Guidance

### When to use PATCH

Use `PATCH` for operations that modify specific fields of a resource without requiring the client to send the complete
resource representation.

**Use `PATCH` when:**

* Updating one or more specific fields of a resource (e.g., "Update the title of book 123").
* The client does not have or does not want to send the complete resource representation.
* You want to minimize bandwidth by only sending changed fields.
* The resource is large and sending the complete representation for small changes would be inefficient.

**Do NOT use `PATCH` when:**

* Replacing the entire resource; use [PUT] instead.

### General requirements

`PATCH` requests:

* **must** be made to the resource's canonical [URI path] (e.g., `/publishers/{publisher_id}/books/{book_id}`).
* **must** be used to partially update a resource at a known URI.
* **must** include a request body that describes the changes to be applied.
* **must** have the [Content-Type] header set appropriately to indicate the format of the request body.
* **must not** modify read-only or server-managed fields (e.g., `createdTime`, `id`). If such fields are included in the
  request, they should be ignored or return [400 Bad Request].
* **should** return the complete updated resource in the response, not just the fields that were modified. This allows
  clients to see the full result of their changes, including any server-side transformations or computed fields.
* **must not** be _assumed_ to be [idempotent].
    * `PATCH` operations **may** be designed to be idempotent.
    * APIs **must** document if a `PATCH` endpoint is idempotent.

When processing `PATCH` requests:

* Fields included in the patch must be validated according to the same rules as `PUT` or `POST` requests.
* Unknown or unrecognized fields **may** be ignored or **may** cause a [400 Bad Request], depending on the API's
  strictness policy.
    * This **must** be documented.
* Read-only fields included in the patch **must** be ignored.
* Fields omitted from the patch **must** remain unchanged in the resource (unlike `PUT`, which treats omitted fields as
  intentionally cleared).

Some resources take longer to be updated than is reasonable for a regular API request. In this situation, the API should
use a [long-running operation].

### Field Masking

APIs **must** use the field mask approach for `PATCH` operations.

Field masking uses a simple partial JSON object with an explicit field mask parameter to indicate which fields to
update.

* The field mask **must** be provided as a query parameter named `update_mask`.
* The field mask **must** be a comma-separated list of fields (e.g., `field1,field2,nested.field`)
* If no `update_mask` is provided, the request should return [400 Bad Request] to ensure explicit intent.
* Only fields listed in the `update_mask` **must** be updated on the resource.
* Fields present in the request body but not in the `update_mask` **must** be ignored.
* Fields listed in the `update_mask` but not present in the request body **should** return [400 Bad Request].
* To clear a field value, include the field in both the `update_mask` and the request body with a `null` value.
* Array fields **must** be replaced entirely when updated. A limitation of field masking is that it does not support
  individual array element updates. To modify an array, include the array field in the `update_mask` and provide the
  complete new array in the request body.
* Nested fields **should** be specified using dot notation (e.g., `address.city`, `contact.email`).
    * When updating nested fields, only the specified nested field is modified; sibling fields within the same parent
      object must remain unchanged.
    * To update multiple fields within a nested object, each field **must** be listed separately in the `update_mask` (
      e.g., `address.city`,`address.zip`).
    * To replace an entire nested object, specify only the parent field in the update_mask (e.g., `address`). In this
      case, the entire object is replaced with the provided value.

```http request
PATCH /users/456?update_mask=name,address.city
Content-Type: application/json

{
  "name": "Bruce Wayne",
  "address": {
    "city": "Gotham"
  }
}
```

In this example, only the `name` and `address.city` fields are updated. Other fields this resource may have, like
`address.street`, `address.state`, `email`, etc. remain unchanged.

### Idempotency

While it is not strictly required to be so by the HTTP specification, `PATCH` **may** be idempotent. The idempotency of
a `PATCH` operation depends on the patch format and the nature of the changes. The field mask approach is _typically_
idempotent (applying the same patch multiple times produces the same result); however, it shouldn't be assumed a `PATCH`
is idempotent unless it is clearly documented. APIs **must** clearly document if a `PATCH` endpoint is idempotent.
`PATCH` operations that require idempotency **should** support an [Idempotency-Key].

### Concurrency

`PATCH` operations **may** implement optimistic concurrency control using ETags in the same manner as `PUT` requests.
See the [PUT concurrency] section for detailed guidance and examples.

## Rationale

**Why field masking?**

We've standardized on field masking as our patch format because it provides the optimal balance of simplicity,
explicitness, and functionality. The `update_mask` parameter makes developer intent completely clear, preventing
accidental updates and eliminating ambiguity about which fields are being modified. Developers work with familiar JSON
objects that mirror the resource structure, without learning operation syntax like JSON Patch ([RFC 6902]) or dealing
with the null-value ambiguity of Merge Patch ([RFC 7396]). Dot notation (e.g., `address.city`) provides a
straightforward way to update specific fields within nested objects. While the RFC-standardized formats (Merge Patch and
JSON Patch) have their uses, field masking occupies the sweet spot for our APIs: explicit enough to prevent errors,
simple enough to be used easily, and powerful enough to handle complex resources.

[RFC 5789]: https://datatracker.ietf.org/doc/html/rfc5789

[GET]: /get

[PUT]: /put

[DELETE]: /delete

[URI path]: /paths

[long-running operation]: /long-running-operations

[idempotent]: /130#common-method-properties

[Idempotency-Key]: /idempotency-key

[Content-Type]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Type

[If-Match]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/If-Match

[PUT concurrency]: /133#concurrency

[RFC 6902]: https://datatracker.ietf.org/doc/html/rfc6902

[RFC 7396]: https://datatracker.ietf.org/doc/html/rfc7396

[400 Bad Request]: /63#400-bad-request

## Changelog

* **2026-01-21**: Standardize HTTP status code references.
* **2025-12-09**: Initial creation
