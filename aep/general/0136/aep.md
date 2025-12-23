# Custom Methods

Resource-oriented design AEP-121 uses custom methods to provide a means to
express actions that are difficult to model using only the standard methods.
Custom methods are important because they provide a means for an API's
vocabulary to adhere to user intent.

## Guidance

Custom methods **should** only be used for functionality that cannot be expressed via standard methods; prefer
standard [HTTP methods] and reified resources if possible, due to their consistent semantics.

**Use custom methods when:**

* The operation represents a simple action or state transition with no additional data or history requirements (e.g.,
  "cancel order" when you don't need to track who canceled it or why).
    * Meaning, the operation is instantaneous, has no state, and leaves no trace worth tracking.
* Using standard methods would require awkward or unintuitive resource modeling that obscures the operation's intent.
* The action is better expressed as a verb acting on a resource rather than a state change on the resource itself.

**Do NOT use custom methods when:**

* Standard HTTP methods can naturally express the operation.
* The operation is searching or filtering; use [GET] with query parameters instead.
* The operation is a bulk list (`bulk-get`); use a regular [GET] on a collection instead.
* The operation has state that should be tracked, monitored, or queried; use [reification] to model it as a resource
  instead (e.g., `/imports`, `/deployments`, `/calculations`).
* You're simply trying to avoid thinking about resource modeling; take time to consider if a resource-oriented approach
  would be clearer.

### General requirements

* Custom methods **must** use [POST] or [GET].
    * Custom methods **must not** use `PUT`, `PATCH` or `DELETE`.
    * If the operation results in _any_ change in server state, it **must** use [POST].
    * Only actions which are [idempotent, safe, and cacheable] may use [GET].
* The HTTP URI **must** use a `:` character followed by the custom verb (e.g. `:cancel`).
    * If word separation is required, `kebab-case` **must** be used.
    * The custom verb must be placed after the resource identifier (e.g., `/orders/123:cancel`).
* The custom verb **must** be an action verb describing what the method does.
    * It **must not** contain nouns or noun phrases.
    * It **must not** contain prepositions ("for", "with", etc.).
    * It **should** be concise and clearly convey the operation's intent.
* Custom methods **must** operate on a specific resource or collection.
    * They **must not** be standalone endpoints unrelated to resources.
* Avoid redundancy with the resource name (e.g., `:cancel` not `:cancel-order` when the resource is already an order)

APIs **must** clearly document each custom method, including:

* The purpose and semantics of the operation.
* Whether the operation is idempotent.
* Expected request body structure (for `POST` methods).
* Expected response structure and status codes.
* Any preconditions or state requirements for the operation to succeed.
* Side effects of the operation.

### Idempotency

Custom methods using [GET] **must** be idempotent by definition of the HTTP specification.

Custom methods using [POST] are not inherently idempotent. If a custom method is idempotent, this **must** be clearly
documented. Custom methods that require idempotency (such as payment operations or order submissions) **should**
support an [Idempotency-Key].

### Searching and filtering

A common misuse of custom methods is using them for searches (`:search`). Searching and filtering **should** be
implemented as [GET] requests with query parameters on the collection resource instead.

Incorrect:

```http request
GET /books:search?author=Jane+Doe&published_after=2020-01-01
```

Correct:

```http request
GET /books?author=Jane+Doe&published_after=2020-01-01
```

The `:search` verb is unnecessary; the query parameters already make it clear that you're filtering the collection. This
applies even when supporting wildcard searches or complex filters.

### Bulk operations

Custom methods **may** be used for bulk create and update operations (not read) when it would otherwise be ambiguous or
conflict with single-resource operations.

Since `POST /books` is used for creating a single book, to avoid conflicting URIs, bulk creation **may** use a custom
method:

```http request
POST /books:batch-create
Content-Type: application/json

{
  "books": [
    {"title": "Book 1", "author": "Author A"},
    {"title": "Book 2", "author": "Author B"}
  ]
}
```

Similarly, bulk updates can use a custom method when updating multiple resources at once.

However, bulk read operations **must not** use custom methods. Instead, use standard [GET] requests on the collection.

[HTTP methods]: /http-methods

[idempotent, safe, and cacheable]: /130#common-method-properties

[GET]: /get

[POST]: /post

[reification]: /121#reification

[Idempotency-Key]: /idempotency-key

## Changelog

**2024-12-10:** Initial version, adapted from [Google AIP-136][] and aep.dev [AEP-136][].

[Google AIP-136]: https://google.aip.dev/136

[AEP-136]: https://aep.dev/136
