# States

Many API resources carry a concept of "state": ordinarily, the resource's place
in its lifecycle. For example, a virtual machine may be being provisioned,
available for use, being spun down, or potentially be in one of several other
situations. A job or query may be preparing to run, be actively running, have
completed, and so on.

## Guidance

Resources needing to communicate their state **should** use an enum, which
**should** be called `State` (or, if more specificity is required, end in the
word `State`). This enum **should** be nested within the message it describes
when only used as a field within that message.

**Important:** We use the term `State`, and _not_ `Status` (to not be confused with the HTTP status).

### Enum values

Ideally, APIs use the same terminology throughout when expressing the same
semantic concepts. There are usually many words available to express a given
state, but our customers often use multiple APIs together, and it is easier for
them when our terms are consistent.

At a high level:

- Resources that are available for use are `ACTIVE` (preferred over terms such
  as "ready" or "available").
- Resources that have completed a (usually terminal) requested action use past
  participles (usually ending in `-ED`), such as `SUCCEEDED` (not
  "successful"), `FAILED` (not "failure"), `DELETED`, `SUSPENDED`, and so on.
- Resources that are currently undergoing a state change use present
  participles (usually ending in `-ING`), such as `RUNNING`, `CREATING`,
  `DELETING`, `PENDING`, and so on. In this case, it is expected that the state is
  temporary and will resolve to another state on its own, with no further user
  action.

**Note:** Only add states that are useful to consumers. Exposing a large number
of states simply because they exist in your internal system is unnecessary and
adds confusion for consumers. Each state **must** come with a use case for why
it is necessary.

### Output only

The `state` field **must** behave and be documented as output only.

APIs **must not** allow a `state` to be directly created or updated on the resource itself through standard
create/update methods (`POST`/`PUT`/`PATCH`). For example, to publish a book, do _not_ send a `PATCH` request to the
`book` resource with body `{"state": "PUBLISHED"}`.

Instead, state transitions **should** be triggered by:

* Creating separate [transition resources](#state-transition-resources).
* Defining a [custom method](#state-transition-custom-methods).
* Using the [DELETE](/delete) method (for transitioning to a `DELETED` state).

This constraint exists because standard update methods are generally not expected to have side effects, and because
updating state directly implies that any state value can be set arbitrarily, whereas states actually reflect a
resource's progression through a defined lifecycle with specific valid transitions.

### State transition resources

State transitions **should** be modeled as separate resources when the transition has meaningful metadata, requires
tracking, or involves a multistep process.

For example, to publish a book, create a publication resource: `POST /books/{id}/publications`. This allows the capture
of an audit trail (_who_ published, _why_, _when_, etc.).

For more detailed information, see the [Reification](/121#reification) section in Resource-oriented design.

### State transition custom methods

APIs **may** use custom methods (e.g., `POST /books/{id}:publish`) for simple, instantaneous state transitions that have
no additional data requirements and leave no audit trail beyond the state change itself.

In addition to the general guidance for [custom methods](/custom-methods), the following guidance applies for state
transition custom methods:

- The HTTP method **must** be `POST`.
- The custom method **must** use an action verb (e.g., `:publish`), without any nouns (e.g., `:publish-book`).
- The resource path parameters (e.g., `publisher_id`, `book_id`) **should** be the only path variables in the URI. All
  other parameters **should** be in the request body.
- The request body **may** contain operational parameters that affect how the transition executes, but **should not**
  contain metadata worth tracking or auditing.
    - Examples of appropriate parameters: `force: true`, `skipValidation: true`, `dryRun: true`
    - Examples of inappropriate parameters: `reason`, `published_by`, `notes` (these indicate the transition should be
      modeled as a [transition resource](#state-transition-resources))
    - If no parameters are needed, an empty object `{}` **should** be sent.
- The response **should** be the resource itself (e.g., the `Book` object).
    - If the operation is long-running, the response **should** be an `Operation` object,
      per [long-running operations](/long-running-operations).

### State transition errors

When a state transition is not allowed due to the resource's current state, the API **must** return a `409 Conflict`.
For example, if attempting to publish a book that is in the `ARCHIVED` state, and only `DRAFT` books can be transitioned
to `PUBLISHED`. The error response **should** include details on the error (e.g.,
`"Cannot publish book: invalid transition from ARCHIVED to PUBLISHED"`). This applies to both transition resources and
custom methods.

APIs **must not** use `400 Bad Request` for invalid state transitions, as the request itself is well-formed; it's the
resource's state that makes the operation invalid.

## Additional Guidance

### Prefixes

Using a `STATE_` prefix on every enum value is unnecessary. State enum values
**should not** be prefixed with the enum name.

### Breaking changes

**TL;DR:** Clearly communicate to users that state enums may receive new values
in the future, and be conscientious about adding states to an existing enum.

Even though adding states to an existing states enum _can_ break existing user
code, adding states is not considered a breaking change. Consider a state with
only two values: `ACTIVE` and `DELETED`. A user may add code that checks
`if state == ACTIVE`, and in the else cases simply assumes the resource is
deleted. If the API later adds a new state for another purpose, that code will
break.

API documentation **should** actively encourage users to code against state
enums with the expectation that they may receive new values in the future.

APIs **may** add new states to an existing State enum when appropriate, and
adding a new state is _not_ considered a breaking change.

### When to avoid states

Sometimes, a `State` enum may not be what is best for your API, particularly in
situations where a state has a very small number of potential values, or when
states are not mutually exclusive.

Consider the example of a state with only `ACTIVE` and `DELETED`, as discussed
above. In this situation, the API may be better off exposing a `deletedTime` timestamp field, and instructing users to
rely on whether it is set to determine deletion.

### Common states

The following is a list of states in common use. APIs **should** consider prior
art when determining state names, and **should** value local consistency above
global consistency in the case of conflicting precedent.

#### Resting states

"Resting states" are lifecycle states that, absent user action, are expected to
remain indefinitely. However, the user can initiate an action to move a
resource in a resting state into certain other states (resting or active).

- `ACCEPTED`
- `ACTIVE`
- `CANCELLED`
- `DELETED`
- `FAILED`
- `SUCCEEDED`
- `SUSPENDED`
- `VERIFIED`
- `REJECTED`

#### Active states

"Active states" are lifecycle states that typically resolve on their own into a
single expected resting state.

**Note:** Remember only to expose states that are useful to customers. Active
states are valuable only if the resource is in that state for a sufficient
period of time. If state changes are immediate, active states are not
necessary.

- `CREATING`
- `DELETING`
- `PENDING`
- `REPAIRING`
- `RUNNING`
- `SUSPENDING`

## Further reading

- For information on enums generally, see [enumerations](./enumerations).

## Changelog

* **2026-01-21**: Add clarification on using `DELETE` method for transitioning to `DELETED` state.
* **2025-12-23**: Initial creation, adapted from [Google AIP-216][] and aep.dev [AEP-216][].

[Google AIP-216]: https://google.aip.dev/216

[AEP-216]: https://aep.dev/216
