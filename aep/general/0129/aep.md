# Query Parameters

Query parameters are a part of the URI that allows you to pass additional information to the server. They are typically
used to filter, sort, or modify the data returned by the API.

## Guidance

Query parameters are appended to the end of the URI after a question mark (`?`), and multiple parameters are separated
by an ampersand (`&`). Query parameters are key-value pairs, where the key and value are separated by an equals sign (
`=`).

**Example:**

```http
GET /v1/books?sort_by=title&limit=10&published_after=2020-01-01
```

This request sorts the results by the `title` field, limits the result set to 10 items, and filters for books published
after January 1, 2020.

### Naming conventions

Query parameter names **must** use `snake_case` (never `camelCase` or `kebab-case`).

* Parameter names **must** match the regex `^[a-z_][a-z_0-9]*$`
* The first character **must** be a lowercase letter or an underscore
* Subsequent characters **may** be a lowercase letter, an underscore, or a number

Examples: `customer_number`, `sales_order_number`, `billing_address`, `sort_by`

### Boolean values

For boolean parameters, APIs **must** use the string literals `true` and `false` instead of numeric representations (`1`
and `0`). This improves clarity and is more human-readable.

**Examples:**

```http
GET /v1/books?include_archived=true
GET /v1/orders?is_paid=false
```

### Default values

APIs **should** define sensible default values for query parameters where appropriate. This improves the developer
experience by making simple use cases work without requiring extensive parameterization.

Default values **must** be documented in the API specification.

### Reserved query parameters

The following query parameter names are reserved for common pagination and filtering operations and **should** be used
consistently across all endpoints:

* `page_token` - For cursor-based pagination (see [Pagination])
* `page_size` - For cursor-based pagination (see [Pagination])
* `offset` - For offset-based pagination (see [Pagination])
* `limit` - For offset-based pagination (see [Pagination])
* `order_by` - For sorting results
* `update_mask` - For [PATCH updates](/134#field-masking)
* `read_mask` - For [partial responses](/partial-responses)

### Query parameters are non-actionable

Query parameters are declarative modifiers. They **must not** be used to define, trigger, or represent a mutating
operation or business action.

Query parameters are intended to:

* Filter, sort, or paginate results
* Control response shape
* Declaratively scope or constrain an operation whose mutating semantics are already defined by the HTTP method
  (e.g., [update_mask on PATCH](/134#field-masking))

Correct:

```http
GET /v1/books?status=published
DELETE /v1/books/123
```

Incorrect:

```http
GET /v1/books/123?action=delete
POST /v1/books?publish=true
```

## Rationale

### Why `snake_case`?

No established industry standard exists, but many popular Internet companies prefer `snake_case` for query parameters,
including GitHub, Stack Exchange, and Twitter. Others, like Google and Amazon, use a mix of styles but not exclusively
`camelCase`.

* Query parameters are case-sensitive. With `camelCase`, `sortBy`, `SortBy`, and `sortby` would all be treated as
  different parameters, leading to typos and mismatches. Using `snake_case` reduces ambiguity and is less prone to
  case-related errors.
* `snake_case` is generally more readable, especially for longer parameter names like `billing_address` versus
  `billingAddress`.
* Query parameters often map to variables in code. Most programming languages have problems serializing/deserializing
  variable names with hyphens (which rules out `kebab-case`), making `snake_case` a safer choice.
* Establishing a consistent look and feel across all API endpoints makes the API easier to learn and use.

[Pagination]: /pagination

## Changelog

* **2025-12-16**: Clarify query parameters are non-actionable, instead of read-only
* **2025-12-15**: Remove section on list values, since that is mostly a client side thing
* **2025-12-11**: Initial creation
