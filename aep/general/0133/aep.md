# Create

In REST APIs, it is customary to make a `POST` request to a collection's URI
(for example, `/v1/publishers/{publisherId}/books`) in order to create a new
resource within that collection.

Resource-oriented design AEP-121 honors this pattern through the `Create`
action.

Also see the [apply](/apply) action, with guidance on how to implement creation with client assigned IDs.

## Guidance

APIs **should** provide a create action for resources unless it is not valuable
for users to do so. The purpose of the create action is to create a new
resource in an already-existing collection.

### Operation

`Create` operations are specified using the following pattern:

- The HTTP method **must** be `POST`, unless the resource being created has a client specified id,
  see [User-specified IDs](#user-specified-ids).
    - `POST` **must** follow the guidelines in AEP-66.
- Some resources take longer to be created than is reasonable for a regular API
  request. In this situation, the API **should** use a
  [long-running operation](/long-running-operations).

`Create` operations are made by sending a [POST] request to the _collection_ URI:

```http
POST /v1/publishers/{publisherId}/books
```

### Requests

- The request body **must** be the resource being created.
- The request **must** be sent to the _collection_ URI.
- When a request fails during creation, the server **must not** create the resource. The operation **must** be
  atomic from the client's perspective.
- If read-only fields (e.g., `createdTime`) are included in the request, they **should** be ignored or
  return [400 Bad Request], depending on your API's semantics.
- Unrecognized fields **may** be ignored or **may** cause a [400 Bad Request], depending on the API's semantics.
    - This **must** be documented.

```http request
POST /v1/publishers/123/books
Content-Type: application/json

{
    "title": "Les Misérables",
    "author": "Victor Hugo",
    "isbn": "9780451419439"
}
```

{% tab proto %}

{% tab oas %}

{% sample '../example.oas.yaml', '$.paths./publishers/{publisherId}/books.post.requestBody' %}

{% endtabs %}

### Responses

On successful creation, the response **must** return [201 Created]. The response **may** include a [Location] header
containing the URI of the newly created resource.

The response body:

* **must** be the resource itself. There is no separate response schema.
* **should** include the complete representation of the created resource.
* **must** include any fields that were provided unless they are input only.
* **must** include any server-generated fields (e.g., `id`, `createdTime`, `updatedTime`).
* For bulk creation operations, APIs **may** return a summary or list of IDs/Status objects instead of full
  resources to improve performance.

```http
201 Created
Location: /v1/publishers/123/books/456
Content-Type: application/json

{
    "id": "456",
    "title": "Les Misérables",
    "author": "Victor Hugo",
    "isbn": "9780451419439",
    "createdTime": "2025-11-12T10:30:00Z",
    "updatedTime": "2025-11-12T10:30:00Z"
}
```

{% tab proto %}

{% tab oas %}

{% sample '../example.oas.yaml', '$.paths./publishers/{publisherId}/books.post.responses.201' %}

{% endtabs %}

### Errors

A `Create` action **must** return appropriate error responses. For additional guidance, see [Errors]
and [HTTP status codes].

Most common error scenarios:

* [400 Bad Request] **should** be returned if the request body is malformed or missing required fields.
* [404 Not Found] **should** be returned if the parent resource does not exist (e.g., creating a book under a
  non-existent publisher).
* [409 Conflict] **should** be returned if a resource with the same identifier already exists.
* See [authorization checks](/authorization) for details on responses based on permissions.

### User-specified IDs

An API **may** allow the client to specify resource IDs. In general, this should only be supported when client-assigned
identifiers are semantically appropriate (e.g., ISBNs, email addresses, usernames). For resource creation with a client
specified ID, see [Apply].

**Note:** APIs **should** prefer `POST` for resource creation. It is good practice to keep resource ID management
under the control of the server rather than the client. However, when the client must control the resource identifier
(e.g., natural keys, external system integration, idempotent creation requirements), use [Apply] instead of `Create`.

## Interface Definitions

{% tab proto %}

{% tab oas %}

{% sample '../example.oas.yaml', '$.paths./publishers/{publisherId}/books.post' %}

{% endtabs %}

## Further reading

- For ensuring idempotency in `Create` actions, see AEP-155.
- For naming resources involving Unicode, see AEP-210.

## Changelog

* **2026-02-19**: Initial creation, adapted from [Google AIP-133][] and aep.dev [AEP-133][].

[Google AIP-133]: https://google.aip.dev/133

[AEP-133]: https://aep.dev/133

[errors]: /errors

[POST]: /http-post

[Apply]: /apply

[location]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Location

[HTTP status codes]: /status-codes

[201 Created]: /63#201-created

[400 Bad Request]: /63#400-bad-request

[404 Not Found]: /63#404-not-found

[409 Conflict]: /63#409-conflict
