# Query Parameters

Query parameters are a part of the URI that allows you to pass additional
information to the server. They are typically used to filter, sort, or modify
the data returned by the API.

## Guidance

Query parameters are appended to the end of the URI after a question mark
(`?`), and multiple parameters are separated by an ampersand (`&`). Query
parameters are key-value pairs, where the key and value are separated by an
equals sign ( `=`).

**Example:**

```http
GET /v1/books?sortBy=title&limit=10&publishedAfter=2020-01-01
```

This request sorts the results by the `title` field, limits the result set to
10 items, and filters for books published after January 1, 2020.

### Naming conventions

Query parameter names **must** use `camelCase` (never `snake_case` or
`kebab-case`).

- Parameter names **must** match the regex `^[a-z][a-zA-Z0-9]*$`
- The first character **must** be a lowercase letter
- Subsequent characters **may** be lowercase or uppercase letters, or digits

Examples: `customerNumber`, `salesOrderNumber`, `billingAddress`, `sortBy`

### Boolean values

For boolean parameters, APIs **must** use the string literals `true` and
`false` instead of numeric representations (`1` and `0`). This improves clarity
and is more human-readable.

**Examples:**

```http
GET /v1/books?includeArchived=true
GET /v1/orders?isPaid=false
```

### Default values

APIs **should** define sensible default values for query parameters where
appropriate. This improves the developer experience by making simple use cases
work without requiring extensive parameterization.

Default values **must** be documented in the API specification.

### Repeated and list query parameters

There are two common ways for clients to pass multiple values for a single
query parameter:

- Repeated parameters: `GET /products?category=books&category=electronics`
- Comma-separated values: `GET /products?category=books,electronics`

Both forms are equivalent and APIs **should** support both to maximize client
flexibility. If there is a strong technical reason to support only one format,
the API **must** document this explicitly.

APIs **must not** treat separator characters (such as commas, pipes, or spaces)
as special without documenting this behavior. Silent parsing of delimiters
leads to subtle client bugs.

### Standard query parameters

To ensure consistency across the API ecosystem, APIs **should** use the query
parameters defined in [Standard Fields] for common terms.

### Query parameters are non-actionable

Query parameters are declarative modifiers. They **must not** be used to
define, trigger, or represent a mutating operation or business action.

Query parameters are intended to:

- Filter, sort, or paginate results
- Control response shape
- Declaratively scope or constrain an operation whose mutating semantics are
  already defined by the HTTP method (e.g.,
  [updateMask on PATCH](/134#field-masking))

Correct:

```http
GET /v1/books?state=published
DELETE /v1/books/123
```

Incorrect:

```http
GET /v1/books/123?action=delete
POST /v1/books?publish=true
```

## Rationale

### Why `camelCase`?

No established industry standard exists, but many popular Internet companies
prefer `camelCase` for query parameters, including Google, Microsoft, and
Stripe.

- The vast majority of our existing APIs already use `camelCase` for query
  parameters. Adopting a different convention would create friction for
  existing APIs.
- `camelCase` aligns with our JSON response bodies, which uses `camelCase` for
  field names. This consistency between request parameters and response fields
  is more cohesive.
- Establishing a consistent look and feel across all API endpoints makes the
  API easier to learn and use.

[Pagination]: /pagination
[Standard Fields]: /standard-fields

## Changelog

- **2026-03-06**: Add section on repeated and list query parameters.
- **2026-01-30**: Enforce `camelCase`, not `snake_case` for query parameters
- **2025-12-16**: Clarify query parameters are non-actionable, instead of
  read-only
- **2025-12-15**: Remove section on list values, since that is mostly a client
  side thing
- **2025-12-11**: Initial creation
