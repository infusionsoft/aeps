# Resource paths

This AEP defines how to construct resource paths in REST APIs. Consistent URI design improves discoverability,
usability, and maintainability across our APIs.

**Audience:** API designers, backend engineers, and anyone defining HTTP endpoints for REST APIs.

**Scope:** URI path structure, naming, and hierarchy (excluding query parameters).

## What is a resource path?

In HTTP REST APIs, a resource path is the **path component** of a URI that identifies a specific resource. For example,
in the URI:

```
https://api.example.com/v1/publishers/123/books/les-miserables
```

The resource path is: `/publishers/123/books/les-miserables`

The path serves as the resource's address within the API, following a hierarchical structure that reflects resource
relationships.

## Guidance

### Quick Reference

**Format and Case**
* **must** be all lowercase
* **must** use `kebab-case` formatting to separate words
* **must** begin and end with a lowercase letter or digit
* **should** match the regex `[a-z0-9][a-z0-9-]*[a-z0-9]`
  * start and end with an alphanumeric and only allow alphanumerics or hyphens in the middle

**Character Set**
* **should** contain only ASCII letters, digits, and hyphens
* **should not** use characters that require URL-escaping
    * If special characters are used, encoding requirements **must** be clearly documented

**Structure**
* **must** use `/` to separate segments
* **must** alternate between collections and resource IDs (e.g., `/publishers/123/books`)
* **must not** contain empty segments (e.g., `/publishers//books`)
* **should not** exceed 2–3 levels of nesting
* **should not** use `/api` as the base path

**Naming**
* **must** be concise English terms
* **must** use nouns, not verbs or actions (use HTTP methods for actions)
* **must** be plural form (`/publishers` not `/publisher`)
    * **must** use singular form if no plural exists (e.g., `metadata`, `sheep`)
    * **must not** invent plurals (e.g., `metadatas`, `sheeps`)

**Uniqueness**
* **must** be unique within an API

### Syntax Rules

Resource paths **must** follow [RFC 3986 Section 3.3].

Resource paths **should** only use characters available in DNS names as defined by [RFC 1123] (letters, digits, and
hyphens). While [RFC 1123] formally applies to hostnames rather than path segments, following this character subset
provides practical benefits:

* These characters never require URL encoding.
* Works seamlessly across logging systems, configuration files, command-line tools, and network intermediaries.
* Avoids common bugs related to special character handling.

Resource paths **should not** use characters that require URL-escaping or characters outside of [ASCII]. If special
characters are necessary for specific use cases, they **must** be properly URL-encoded when constructing HTTP requests
following [RFC 3986] percent-encoding rules, and the encoding requirements **must** be clearly documented.

Path segments are case-sensitive per [RFC 7230], meaning `/Users` and `/users` are considered different resources. While
no RFC mandates lowercase, our organization takes the opinionated stance that all resource paths **must** use lowercase
letters exclusively. This requirement ensures:

* Human readability and consistency
* Predictability across all APIs
* Prevention of client or routing errors on case-sensitive systems
* Elimination of naming convention confusion where some endpoints use uppercase and others use lowercase

By standardizing on lowercase, we remove ambiguity and make our APIs more predictable for developers.

To summarize this, all path segments:

* **must** be all lowercase
* **must** begin and end with a lowercase letter or digit
* **must** use `kebab-case` formatting to separate words
* **should** match the regex `[a-z0-9][a-z0-9-]*[a-z0-9]`
  * start and end with an alphanumeric and only allow alphanumerics or hyphens in the middle
* **should** contain only [ASCII] letters, digits, and hyphens
* **should not** use characters that require URL-escaping
    * any encoding requirements **must** be clearly documented

### Nouns, NOT Verbs

Resource paths **must** use nouns to describe resources, never verbs or actions. The HTTP method (`GET`, `POST`, `PUT`,
`DELETE`, `PATCH`) indicates the action being performed.

REST APIs model a domain through resources (things/nouns) rather than operations (actions/verbs). Think of resources as
entities or objects that can be manipulated, not as procedures to be invoked. For more information, read AEP-121.

When you're tempted to use a verb in your URL, reframe the action as a message being sent to a resource:

* Instead of "cancel an order" → send a cancellation message to the order's `cancellations` collection
* Instead of "approve a request" → create an `approvals` resource for the request
* Instead of "search users" → query the `users` collection

If an operation doesn't fit neatly into standard CRUD operations, model it as a resource:

* Processes: Create a resource representing the process (e.g., `/imports`, `/exports`, `/conversions`)
* Events: Create a resource for the event (e.g., `/shipments`, `/deployments`, `/publications`)
* States: Create a resource for state transitions (e.g., `/activations`, `/suspensions`, `/completions`)

For example, instead of `POST /run-report` to run a report, model the report execution as a resource:

```
POST /reports/quarterly-sales/executions
GET /reports/quarterly-sales/executions/exec-123
```

This approach provides a resource you can check, cancel, or retrieve results from, which is more RESTful and flexible.

In rare cases where an operation truly cannot be modeled as a resource or standard CRUD operation, custom methods may be
necessary. However, custom methods should be used as a last resort only after exhausting all other options. If you
determine that a custom method is necessary, refer to AEP-136 for guidance on implementing custom methods correctly.
Custom methods should be the exception, not the rule, in a well-designed REST API.

Pluralization:

* Resource paths **must** use the plural form (`/publishers` not `/publisher`).
    * In situations where there is no plural word (e.g., information, metadata), or where the singular and plural terms
      are the same (e.g., moose, sheep), the singular form is correct.
    * APIs **must not** coin words by adding "s" in such cases. For example, `metadata` (not `metadatas`), and
      `sheep` (not `sheeps`).

### Resource Hierarchy and Nesting

Resource paths **must** represent resources in a hierarchical manner, moving from general to specific:

1. `/publishers` - Collection of publishers
2. `/publishers/123` - A specific publisher
3. `/publishers/123/books` - Books belonging to that publisher
4. `/publishers/123/books/les-miserables` - A specific book

These **must** alternate between collections (example: `publishers`, `books`, `users`) and resource IDs (example: `123`,
`les-miserables`, `vhugo1802`), _except_ when singleton resources are present.

Nesting **should** be limited to 2-3 levels for several important reasons:

* Readability: Deeply nested paths become difficult to read and understand.
* URL length constraints: Some clients and intermediaries do not support URLs longer than 2000 characters.
* Flexibility: Shorter paths are easier to work with and share.

When a resource has a _globally_ unique identifier, the API **may** expose it as a top-level resource in addition to (or
instead of) its nested form. This is particularly useful when clients need direct access without knowing the full
hierarchy. For example, instead of requiring the full hierarchical path:

```
/publishers/123/authors/victor-hugo/books/les-miserables
```

Expose `books` as a top-level resource using its _globally_ unique ID:

```
/books/les-miserables
```

**Important:** APIs wishing to do this **must** follow this format _consistently_ throughout the API, or else _not at
all_.

### Internationalization

When designing APIs that handle international content, resource paths require careful consideration to avoid encoding
issues and ensure global accessibility.

For international content specifically:

* Resource paths **should** use stable identifiers rather than human-readable names. For example, use `/books/12345`
  instead of `/books/les-misérables`, as the identifier avoids character encoding ambiguity (the `é`).
* If resource paths do need to include human-readable names (e.g., for readability or SEO purposes), they **should**
  transliterate non-ASCII characters to [ASCII] equivalents. For example, use `/books/les-miserables` instead of
  `/books/les-misérables` (the `é` becomes `e`).
* If your API accepts or requires non-ASCII characters in paths, the API **must** clearly document:
    * Which character encodings are supported.
    * How clients should encode special characters.
    * Any restrictions on specific Unicode ranges or characters.
    * Examples showing proper encoding.

### Common Anti-Patterns

Avoid these common mistakes:

| Don't do this               | Instead do this                  | Why                             |
|-----------------------------|----------------------------------|---------------------------------|
| `GET /get-user-profile/123` | `GET /users/123`                 | Use HTTP methods for actions    |
| `POST /users/create`        | `POST /users`                    | Model resources, not operations |
| `POST /cancel-order`        | `POST /orders/123/cancellations` | Model resources, not operations |
| `POST /orders/123:cancel`   | `POST /orders/123/cancellations` | Model resources, not operations |
| `GET /userProfiles/123`     | `GET /user-profiles/123`         | Always use lower kebab-case     |
| `/users-` or `/-users`      | `/users`                         | Cannot begin or end with hyphen |

[RFC 1123]: https://www.rfc-editor.org/rfc/rfc1123

[RFC 3986]: https://www.rfc-editor.org/rfc/rfc3986

[RFC 3986 Section 3.3]: https://www.rfc-editor.org/rfc/rfc3986#section-3.3

[RFC 7230]: https://www.rfc-editor.org/rfc/rfc7230

[ASCII]: https://www.ascii-code.com

## Changelog

* **2025-11-07**: Initial AEP-122 for Thryv, adapted from [Google AIP-122][] and aep.dev [AEP-122][].

[Google AIP-122]: https://google.aip.dev/122

[AEP-122]: https://aep.dev/122
