# Custom Actions

Resource-oriented design AEP-121 uses custom actions to provide a means to
express actions that are difficult to model using only the standard actions.
Custom actions are important because they provide a means for an API's
vocabulary to adhere to user intent.

## Guidance

* Custom actions **must** use [POST] or [GET].
    * Custom actions **must not** use `PUT`, `PATCH` or `DELETE`.
    * If the operation results in _any_ change in server state, it **must** use [POST].
    * Only actions which are [idempotent, safe, and cacheable] may use [GET].
* The HTTP URI **must** use a `:` character followed by the custom verb (e.g. `:cancel`).
    * If word separation is required, `kebab-case` **must** be used.
    * The custom verb must be placed after the resource identifier (e.g., `/orders/123:cancel`).
* The custom verb **must** be an action verb describing what it does.
    * It **must not** contain nouns or noun phrases.
    * It **must not** contain prepositions ("for", "with", etc.).
    * It **should** be concise and clearly convey the operation's intent.
* Custom actions **must** operate on a specific resource or collection.
    * They **must not** be standalone endpoints unrelated to resources.
* Avoid redundancy with the resource name (e.g., `:cancel` not `:cancel-order` when the resource is already an order)

APIs **must** clearly document each custom action, including:

* The purpose and semantics of the operation.
* Whether the operation is idempotent.
* Expected request body structure (for `POST` methods).
* Expected response structure and status codes.
* Any preconditions or state requirements for the operation to succeed.
* Side effects of the operation.

### When to use custom actions

Custom actions **should** only be used for functionality that cannot be expressed via standard actions
and [reified][reification] resources; prefer those over custom actions due to their consistent semantics.

**Use custom actions when:**

* The operation represents a simple action or state transition with no additional data or history requirements (e.g.,
  "cancel order" when you don't need to track who canceled it or why).
    * Meaning, the operation is instantaneous, has no state, and leaves no trace worth tracking.
* Using standard actions would require awkward or unintuitive resource modeling that obscures the operation's intent.
* The action is better expressed as a verb acting on a resource rather than a state change on the resource itself.

**Do NOT use custom actions when:**

* Standard actions can naturally express the operation.
* The operation is filtering; use [fetch] with query parameters instead.
* The operation is a bulk list (`batch-fetch`); use a regular [list] action.
* The operation has state that should be tracked, monitored, or queried; use [reification] to model it as a resource
  instead (e.g., `/imports`, `/deployments`, `/calculations`).
* You're simply trying to avoid thinking about resource modeling; take time to consider if a resource-oriented approach
  would be clearer.

### Idempotency

Custom actions using [GET] **must** be idempotent by definition of the HTTP specification.

Custom actions using [POST] are not inherently idempotent. If a custom action is idempotent, this **must** be clearly
documented. Custom actions that require idempotency (such as payment operations or order submissions) **should**
support an [Idempotency-Key].

### Bulk operations

Custom actions **may** be used for bulk [create] and [update] operations (not [fetch]) when it would otherwise be
ambiguous or conflict with single-resource operations.

Since `POST /books` is used for creating a single book, to avoid conflicting URIs, bulk creation **may** use a custom
action:

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

Similarly, bulk updates **may** use a custom action when updating multiple resources at once.

However, bulk read operations **must not** use custom methods. Instead, use standard [list] requests.

### Stateless methods

Some custom actions are not attached to resources at all. These actions are
generally _stateless_: they accept a request and return a response and have no
permanent effect on data within the API.

{% tab proto %}

{% tab oas %}

{% sample 'translate.oas.yaml', '$.paths./projects/{projectId}:translate' %}

{% endtabs %}

### Usage in declarative clients

APIs **muat not** employ custom actions for functionality that is intended to
be used in a [declarative client](/9#declarative-clients). Declarative clients
use only standard actions to apply desired state, and
integration of custom actions is manual and results in client-side complexity
around state management to determine when the custom method should be invoked.

[HTTP methods]: /http-methods

[idempotent, safe, and cacheable]: /64#common-method-properties

[GET]: /http-get

[POST]: /http-post

[reification]: /121#reification

[Idempotency-Key]: /idempotency-key

[filtering]: /filtering

[fetch]: /fetch

[list]: /list

[create]: /create

[update]: /update

## Changelog

* **2026-02-20:** Change verbiage from `method` to `action`. Remove filtering. Add Declarative clients and stateless
  methods.
* **2024-12-10:** Initial creation, adapted from [Google AIP-136][] and aep.dev [AEP-136][].

[Google AIP-136]: https://google.aip.dev/136

[AEP-136]: https://aep.dev/136
