# Actions

An API is composed of one or more actions, which represent a specific operation
that a service can perform on a resource on behalf of the consumer.

In HTTP REST APIs, actions map to HTTP methods applied to resource endpoints.

## Guidance

### Standard Actions

REST APIs **should** use standard actions on resources and collections where applicable. Not every resource requires
every action; API authors **should** implement only the actions that make sense for their specific resource. The
following table defines the standard actions and their corresponding HTTP methods:

| Action | HTTP Method  | Applied To          | Purpose                                       |
|--------|--------------|---------------------|-----------------------------------------------|
| Fetch  | [GET]        | Resource            | Retrieve a single resource by its identifier  |
| List   | [GET]        | Collection          | Retrieve multiple resources from a collection |
| Create | [POST]/[PUT] | Collection/Resource | Create a new resource                         |
| Update | [PATCH]      | Resource            | Modify an existing resource                   |
| Apply  | [PUT]        | Resource            | Completely replace (or create) a resource     |
| Delete | [DELETE]     | Resource            | Remove a resource                             |

### Custom Actions

Custom actions perform operations that don't fit the standard action patterns. They **may** be read-only (information
retrieval) or mutative (state changes).

Custom actions **should** only be used when an action cannot be represented as a resource
(see [reification](/121#reification)). When custom actions are necessary, they **should** be mounted to a specific
resource or collection.

Examples of custom actions include: archiving a resource, publishing a draft, or canceling an operation.

### Choosing Actions

When designing API operations, API authors **should** prefer actions in the following order:

1. Standard actions (Fetch, List, Create, Update, Apply, Delete)
2. Reifying actions as resources (e.g., `/orders/123/cancellations` instead of `/orders/123:cancel`)
3. Custom actions mounted to a resource or collection

Standard actions provide the most consistency across APIs and are the most familiar to developers with REST experience.

**Note:** Reifying actions as resources is preferred over custom action endpoints. For example, instead of creating a
custom action endpoint like `/orders/123:cancel`, create a cancellations resource at `/orders/123/cancellations`. This
maintains the [resource-oriented] model and allows the full power of standard actions to be applied to these reified
resources. See AEP-121 for more information.

### Bulk Actions

Bulk operations that _modify_ multiple resources **may** be implemented as custom actions, as they cannot use the same
endpoint as single-resource operations without causing conflicts.

For example, bulk create operations might use:

```
POST /books:batch
```

However, API authors **should** first consider whether reifying the bulk operation as a resource would be more
appropriate:

```
POST /books/imports
```

### OperationIDs

The OpenAPI specification includes an
[operationId](https://spec.openapis.org/oas/latest.html#fixed-fields-7) field
to uniquely identify an operation (action), as well as provide a name for the operation
in tools and libraries.

The `operationId` **must** clearly convey the action being performed. It **must** be `camelCase` and follow the
following format:

- `{actionName}{ResourceSingular}` for standard and custom resource actions
- `list{ResourcePlural}` for list actions
- `batch{actionName}{ResourcePlural}` for batch actions

**Note:** Many Java OpenAPI libraries use the method name as the operationId by default.

Examples:

- `getBook`
- `listBooks`
- `createBook`
- `updateBook`
- `applyBook`
- `deleteBook`
- `batchCreateBooks`
- `archiveBook` (custom action)
- `publishBook` (custom action)

{% tab proto %}

{% tab oas %}

{% sample '../example.oas.yaml', '$.paths./publishers/{publisher_id}/books.get.operationId' %}

{% endtabs %}

## Rationale

Resource-oriented design with standard actions provides consistency across APIs, allowing developers to apply knowledge
from one API to another. Standard actions can be easily understood by anyone familiar with REST principles and HTTP
semantics.

The distinction between Update (PATCH) and Apply (PUT) is important because PUT semantics require complete replacement
of a resource. Conflating these operations can lead to accidental data loss when developers expect partial updates, but
the API performs complete replacement.

Reifying actions as resources rather than using custom action endpoints maintains the resource-oriented model and
provides greater flexibility. A cancellation resource can be listed, fetched, and potentially modified or deleted,
whereas a cancel action endpoint is a one-way operation.

## Further Reading

- [OpenAPI operationId specification](https://swagger.io/docs/specification/v3_0/paths-and-operations/#operationid)
- [Resource Oriented Design][resource-oriented]

[GET]: /http-get

[POST]: /http-post

[PUT]: /http-put

[PATCH]: /http-patch

[DELETE]: /http-delete

[resource-oriented]: /resource-oriented-design

## Changelog

- **2026-02-09**: Initial creation, adapted from [Google AIP-130][] and aep.dev [AEP-130][].

[Google AIP-130]: https://google.aip.dev/130

[AEP-130]: https://aep.dev/130
