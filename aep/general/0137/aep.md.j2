# Apply

In REST APIs, it is customary to make a `PUT` request to a resource's URI (for
example, `/v1/publishers/{publisher_id}/books/{book_id}`) in order to create or
replace a resource.

[Resource-oriented design](/resources) honors this pattern through the `Apply`
action. These operations accept the resource and its path, which it uses to
create or replace the resource. The operation returns the final resource.

Also see the [update](/update) action, with guidance on how to implement
`PATCH` requests.

## Guidance

APIs **may** provide an apply action for a resource if it is valuable for users.

APIs **should** use `Apply` when creating resources with client-generated IDs (e.g., ISBNs, email addresses, usernames,
natural keys). See [Create] for creating resources with server-generated IDs.

`Apply` **should** also be used for completely replacing an existing resource's entire representation. Meaning the old
resource is deleted, and this new representation is created in its place. `Apply` is particularly useful for declarative
clients that need to ensure the complete state of a resource matches the provided representation.

**Important:** `Apply` is NOT, and **must not** be used as, an [Update]. Apply means _replace_: "put _this_ exact
representation at _this_ location, replacing whatever was there before (if anything)". For _modifying_ existing
resources, APIs **must** use [Update] to ensure forward-compatible requests (see [PATCH and PUT](#patch-and-put)).

### Behavior

The resource **must** be created with the ID specified in the URI, or _not at all_.

The `Apply` action **must** be [idempotent]. Sending the same `Apply` request multiple times **must** result in the same
single resource instance without data duplication.

If an optional field in the request is missing, it **should** be treated
as absent on purpose. The service **should** remove the field from the resource, set it to `null`, or set it to a
default value. You **must** document clearly how your API handles missing fields.

**Warning:** This effectively deletes data. If a client fetches a resource, modifies one field, and applies it back
without
including the other fields, those other fields _will be erased_. If you need _updates_ where omitted fields remain
unchanged, see [Update].

### Operation

`Apply` operations are specified using the following pattern:

- The HTTP method **must** be [PUT], and **must** follow the `PUT` guidelines in AEP-67.
    - The request **must** be [idempotent].
- Some resources take longer to be applied than is reasonable for a regular API
  request. In this situation, the API **should** use a
  [long-running operation](/long-running-operations).
- The operation **must** have
  [strong consistency](/resource-oriented-design#strong-consistency).
- They **must not** modify read-only or server-managed fields (e.g., `createdTime`).

`Apply` operations **must** be made by sending a [PUT] request to the resource's canonical [URI path]:

```http
PUT /v1/publishers/{publisher_id}/books/{book_id}
```

### Requests

- The request body **must** be the resource being applied.
- The request **must** be made to the resource's canonical [URI path] with the client-specified identifier.
    - The resource **must** be created with this ID, or not at all.
- If read-only fields are included in the request, they **should** be ignored or return [400 Bad Request], depending on
  your API's semantics.
- Unrecognized fields **may** be ignored or **may** cause a [400 Bad Request], depending on the API's semantics.
    - This **must** be documented.

```http request
PUT /v1/publishers/123/books/client-specified-id
Content-Type: application/json

{
    "title": "Les Misérables",
    "author": "Victor Hugo",
    "isbn": "9780451419439"
}
```

{% tab proto %}

{% tab oas %}

{% sample '../example.oas.yaml', '$.paths./publishers/{publisher_id}/books/{book_id}.put.requestBody' %}

{% endtabs %}

### Responses

- If the resource is created, the response **must** return [201 Created].
- If the resource is replaced, the response **must** return [200 OK].
- The response **may** include a [Location] header containing the URI of the newly created resource.

The response body:

- **must** be the resource itself. There is no separate response schema.
- **should** include the complete representation of the applied resource.
- **must** include any fields that were provided unless they are input only.
- **must** include any server-generated fields (e.g., `createdTime`, `updatedTime`).

{% tab proto %}

{% tab oas %}

{% sample '../example.oas.yaml', '$.paths./publishers/{publisher_id}/books/{book_id}.put.responses' %}

{% endtabs %}

### Errors

An `Apply` action **must** return appropriate error responses. For additional guidance, see [Errors]
and [HTTP status codes].

Most common error scenarios:

* [400 Bad Request] **should** be returned if the request body is malformed or missing required fields.
* [404 Not Found] **should** be returned if the parent resource does not exist (e.g., creating a book under a
  non-existent publisher).
* See [authorization checks](/authorization) for details on responses based on permissions.

### PATCH and PUT

Updates **must** be done with a [PATCH]. Applies **must** be done with a [PUT]. See
the [PATCH and PUT](/67#patch-and-put) section of AEP-67 for more information.

## Interface Definitions

{% tab proto %}

{% tab oas %}

{% sample '../example.oas.yaml', '$.paths./publishers/{publisher_id}/books/{book_id}.put' %}

{% endtabs %}

## Further reading

- For ensuring idempotency in `Apply` actions, see [idempotency](/idempotency).
- For naming resources involving Unicode, see [unicode](/unicode).

## Changelog

* **2026-02-20**: Initial creation, adapted from aep.dev [AEP-137][].

[AEP-137]: https://aep.dev/137

[strong consistency]: ./0121.md#strong-consistency

[create]: /create

[update]: /update

[PUT]: /http-put

[PATCH]: /http-patch

[URI path]: /paths

[idempotent]: /64#common-method-properties

[location]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Location

[errors]: /errors

[HTTP status codes]: /status-codes

[200 OK]: /63#200-ok

[201 Created]: /63#201-created

[400 Bad Request]: /63#400-bad-request

[404 Not Found]: /63#404-not-found
