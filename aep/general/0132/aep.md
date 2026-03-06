# List

In REST APIs, it is customary to make a [GET] request to a resource
collection's URI (for example, `/publishers/{publisherId}/books`) in order to
retrieve a list of the resources within that collection. Resource-oriented design AEP-121 honors this pattern through
the `List` action.

## Guidance

APIs **should** provide a `List` action for resource collections. The purpose of
the `List` action is to return data from a finite collection (generally
singular unless the operation supports [reading across collections][]).

When the [GET] HTTP method is used on a URI ending in a resource collection, the
result **must** be a list of resources.

### Operation

`List` operations **must** be made by sending a [GET] request to the resource
collection's [URI path]:

```http
GET /v1/publishers/{publisherId}/books
```

- The URI **should** contain a variable for each individual ID in the resource
  hierarchy.
    - The path parameter for all resource IDs **must** be in the form
      `{resourceName}Id` (such as `bookId`), and path parameters representing
      the ID of parent resources **must** end with `Id`.
- `List` actions **should** implement sorting and [filtering] mechanisms to allow clients to sort and narrow results.

### Requests

- The HTTP method **must** be [GET], and **must** follow the `GET` method guidelines in AEP-65.
    - The request **must** be [safe] and **must not** have side effects.
- There **must not** be a request body.
    - If a `GET` request contains a body, the body **must** be ignored, and
      **must not** cause an error.
- The request **must not** _require_ any query parameters.
    - Optional query parameters **may** be included (e.g., for [pagination] or [filtering])

{% tab proto %}

{% tab oas %}

{% sample '../example.oas.yaml', '$.paths./publishers/{publisherId}/books.get.parameters' %}

{% endtabs %}

### Responses

A `List` action **must** return [200 OK] when resources are successfully retrieved.

The response **must** be [paginated][pagination] and follow these requirements:

* The field `results` **must** be an array of resources, with the schema as a reference to the resource (e.g.,
  `#/components/schemas/Book`).
* Fields providing metadata about the `List` request (such as page tokens) **must** be included in the response wrapper
  object, not as part of the resource itself.
* The response **must** ensure a deterministic default sort order to guarantee stable pagination.

If the collection exists but contains no resources, the response **must** return a [200 OK] with an empty `results`
array.

{% tab proto %}

{% tab oas %}

{% sample '../example.oas.yaml', '$.paths./publishers/{publisherId}/books.get.responses.200.content' %}

{% endtabs %}

### Errors

A List action **must** return appropriate error responses. For additional guidance, see [Errors]
and [HTTP status codes].

Most common error scenarios:

* Return [404 Not Found] if the parent resource does not exist (e.g., requesting `/publishers/{invalidId}/books` when
  the publisher doesn't exist).
* See [authorization checks](/authorization) for details on responses based on permissions.

**Note:** `List` actions **may** return the complete collection to any user with
permission to make a successful `List` request on the collection, _or_ **may**
return a collection only containing resources for which the user has read
permission. This behavior **should** be clearly documented either for each `List`
action or as a standard convention in service-level documentation. Permission
checks on individual resources may have a negative performance impact so should
be used only where necessary.

### Advanced operations

`List` actions **may** allow an extended set of functionality to allow a user
to specify the resources that are returned in a response.

The following table summarizes the applicable AEPs, ordered by the precedence
of the operation on the results.

| Operation  | AEP                  |
|------------|----------------------|
| filtering  | [AEP-160](/160)      |
| ordering   | [AEP-132](#ordering) |
| pagination | [AEP-158](/158)      |

For example, if both a filter and pagination fields are specified, then the
filter would be applied first, then the resulting set would be paginated.

### Ordering

`List` actions **may** allow clients to specify sorting order; if they do, the
order **must** be specified in a query parameter which **must** be a `string` named `orderBy`.

- Values **must** be the fields to sort by. For example: `foo,bar`.
- The default sorting order is ascending. To specify descending order for a
  field, users append a `-` prefix; for example: `foo,-bar`, `-foo,bar`.
- Subfields are specified with a `.` character, such as `foo.bar` or
  `address.street`.

**Note:** Only include ordering if there is an established need to do so. It is
always possible to add ordering later, but removing it is a breaking change.

### Soft-deleted resources

Some APIs need to "[soft-delete][]" resources, marking them as deleted or
pending deletion (and optionally purging them later).

APIs that do this **should not** include deleted resources by default in list
requests. APIs with soft deletion of a resource **may** include a `boolean` field named
`showDeleted` in the list request that, if set, will cause soft-deleted resources to be included.
For more information, see AEP-164.

## Interface Definitions

{% tab proto -%}

{% tab oas %}

{% sample '../example.oas.yaml', '$.paths./publishers/{publisherId}/books.get' %}

{% endtabs %}

## Changelog

* **2026-02-09**: Initial creation, adapted from [Google AIP-132][] and aep.dev [AEP-132][].

[Google AIP-132]: https://google.aip.dev/132

[AEP-132]: https://aep.dev/132

[reading across collections]: ./0159

[soft-delete]: ./0164

[GET]: /http-get

[URI path]: /paths

[safe]: /64#common-method-properties

[pagination]: /pagination

[filtering]: /filtering

[errors]: /errors

[HTTP status codes]: /status-codes

[200 OK]: /63#200-ok

[404 Not Found]: /63#404-not-found
