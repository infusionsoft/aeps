# Fetch

In REST APIs, it is customary to make a [GET] request to a resource's URI (for
example, `/v1/publishers/{publisherId}/books/{bookId}`) in order to retrieve
that resource. Resource-oriented design AEP-121 honors this pattern through the
`Fetch` action.

## Guidance

- APIs **must** provide a `Fetch` action for resources. The purpose of the
  `Fetch` action is to return data from a single resource.
- Some resources take longer to be retrieved than is reasonable for a regular
  API request. In this situation, the API should use a
  [long-running operation](/long-running-operations).

### Operation

`Fetch` operations **must** be made by sending a [GET] request to the
resource's canonical [URI path]:

```http
GET /v1/publishers/{publisherId}/books/{bookId}
```

- The URI **should** contain a variable for each resource in the resource
  hierarchy.
  - The path parameter for all resource IDs **must** be in the form
    `{resourceName}Id` (such as `bookId`), and path parameters representing the
    ID of parent resources **must** end with `Id`.

### Requests

- The HTTP method **must** be [GET], and **must** follow the `GET` method
  guidelines in AEP-65.
  - The request **must** be [safe] and **must not** have side effects.
- There **must not** be a request body.
  - If a `GET` request contains a body, the body **must** be ignored, and
    **must not** cause an error.
- The request **must not** _require_ any query parameters.
  - Optional query parameters **may** be included (e.g., for
    [partial responses](/partial-responses))

{% tab proto %}

{% tab oas %}

{% sample '../example.oas.yaml', '$.paths./publishers/{publisherId}/books/{bookId}.get.parameters' %}

{% endtabs %}

### Responses

A Fetch action **must** return a [200 OK] status code with the resource
representation in the response body when the resource exists.

The response content **must** be the resource itself (there is no
`GetBookResponse`). The response **should** include the fully populated
resource unless there is a reason to return a partial response (see AEP-157).

{% tab proto %}

{% tab oas %}

{% sample '../example.oas.yaml', '$.paths./publishers/{publisherId}/books/{bookId}.get.responses.200.content' %}

{% endtabs %}

### Errors

A Fetch action **must** return appropriate error responses. For additional
guidance, see [Errors] and [HTTP status codes].

Most common error scenarios:

- Return [404 Not Found] if the resource does not exist.
  - If the resource previously existed and has since been deleted (e.g.,
    soft-deleted), the server **may** instead respond with [410 Gone], as
    described in AEP-164.
- See [authorization checks](/authorization) for details on responses based on
  permissions.

## Interface Definitions

{% tab proto -%}

{% tab oas %}

{% sample '../example.oas.yaml', '$.paths./publishers/{publisherId}/books/{bookId}.get' %}

{% endtabs %}

## Changelog

- **2026-02-09**: Initial AEP-131, adapted from [Google AIP-131][] and aep.dev
  [AEP-131][].

[Google AIP-131]: https://google.aip.dev/131
[AEP-131]: https://aep.dev/131
[GET]: /http-get
[URI path]: /paths
[safe]: /64#common-method-properties
[errors]: /errors
[HTTP status codes]: /status-codes
[200 OK]: /63#200-ok
[404 Not Found]: /63#404-not-found
[410 Gone]: /63#410-gone
