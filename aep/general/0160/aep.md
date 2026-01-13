# Filtering

Filtering is a common requirement for collection endpoints in JSON HTTP REST APIs. When listing resources (for example,
`GET /books`), clients often need to narrow results to only those that match specific criteria such as state, owner,
category, or timestamps.

Filtering requirements also tend to evolve over time as products add new features and clients need new ways to query
data. This AEP provides organization-wide guidance for designing predictable, REST-aligned filtering using [query
parameters]. The goal is to keep filtering consistent across APIs (so clients can reuse knowledge and tooling), while
still allowing each API to choose which fields are filterable.

Filtering is distinct from:

* Sorting (ordering results)
* [Pagination] (windowing results)
* Searching (full-text or relevance-ranked retrieval)

**Note:** Because filters are intended for a potentially non-technical audience, they sometimes borrow from patterns of
colloquial speech rather than common patterns found in code.

## Guidance

APIs **may** support filtering on collection endpoints (for example, `GET /books`). If supported:

* Filtering **should** be expressed using query parameters on a [GET] request (not request bodies).
* Filtering parameters **must not** change the meaning of the resource model; they only constrain which items appear in
  the collection response.
* Filtering **should** be modeled as explicit query parameters (e.g., `state=active`,
  `created_after=2025-01-01T00:00:00Z`) rather than a single `filter` string with a custom grammar.
* APIs **must** document:
    * Supported filter parameters
    * Accepted value formats (especially timestamps)
    * Case sensitivity rules for string matching

### Naming Conventions

Different APIs expose different resource models and have different user needs, so the set of filterable fields and the
specific operators that make sense will vary from API to API. These guidelines are not intended to force every API into
the same filter surface area or expressiveness. Instead, the goal is organizational consistency in _how_ filters are
named and composed (so clients can predict behavior across APIs), while preserving flexibility for each API to define
_which_ filters exist, _when_ they are offered, and _which_ operators are supported based on real use cases and
performance considerations.

Query parameters **must** follow the naming and encoding rules in AEP-129.

Filtering parameter names **must** be stable (do not rename lightly), specific, and self-explanatory.

APIs **should** use the direct field name for exact matches (e.g. `state=active`, `category=books`).

APIs **should** use suffix modifiers for common comparisons. Use consistent suffixes and only introduce them when there
is more than one plausible comparison. Recommended suffix set (use a subset as appropriate):

| Suffix / operator            | Meaning                                                            | Notes                                                                                                                             |
|------------------------------|--------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------|
| `_eq`                        | Equals                                                             | Prefer the bare parameter name for equality (e.g., `state=active`) Use `_eq` only if needed to disambiguate from other variants. |
| `_ne`                        | Not equals                                                         | Use when you need explicit inequality filtering.                                                                                  |
| `_lt`, `_lte`, `_gt`, `_gte` | Less than, less than or equal, greater than, greater than or equal | Typically for numbers. Define value formats.                                                                                      |
| `_before`, `_after`          | Timestamp-specific `<` / `>`                                       | Use for time-based fields instead of `_lt/_gt` (e.g., `created_after=...`).                                                       |
| `_contains`                  | String contains                                                    | Must document case-sensitivity, locale/normalization rules, and whether it’s substring vs token-based.                            |
| `_prefix`, `_suffix`         | String starts with / ends with                                     | If supported, document case-sensitivity and escaping rules (if any).                                                              |
| `_in`                        | Value is in a set                                                  | Use only if repeated parameters aren’t feasible. Document list encoding rules (e.g., comma-separated) and escaping.               |

Examples:

```http request
### Orders created after Jan 1, 2025 and total >= 100
GET /orders?created_after=2025-01-01T00:00:00Z&total_gte=100

### Users whose emails end with '@example.com'
GET /users?email_suffix=@example.com
```

### Free-text search (`q`)

Some list endpoints benefit from a simple "type-ahead" or keyword-style search where users enter free text and expect
the API to find relevant results without requiring structured field filters.

To support this, APIs **may** define a `q` query parameter on collection `GET` endpoints (for example,
`GET /books?q=les+mis`). The `q` parameter is intended to be:

* Unstructured: a user-entered string, not a mini-language.
* Best-effort: APIs may match across one or more fields (e.g., title, subtitle, author name), potentially using partial
  matches.
* Simple: clients should not need to know the resource schema to use it.

If an API supports `q`, it **must** clearly document:

* Which fields are searched (e.g., `title` and `author.name`), and whether those fields may change over time.
* Matching behavior (case sensitivity, tokenization/word splitting, diacritics, stemming/synonyms if any).
* Whether results are _ranked_ (best match first) or simply filtered.
* How `q` combines with other filters (by default, `q` is combined with other query parameters using logical `AND`).
* Any limits (maximum query length, minimum characters, rate limits, etc.).

APIs **should not**:

* Treat `q` as a structured filter language (e.g., `q=title:foo AND author:bar`), because that reintroduces custom query
  grammar.
* Require wildcard syntax in `q` (such as `*`). If wildcard-like behavior is needed, it should be provided through
  explicit filter parameters (e.g., `title_prefix`) or through a dedicated search capability.
  See [Pattern matching and wildcards](#pattern-matching-and-wildcards) below.
* Reuse `q` for non-search concepts (e.g., passing JSON, passing encoded filter objects, or toggling behaviors).

Examples:

```http request
### Keyword search on a collection
GET /books?q=les+mis

### Keyword search combined with structured filters
GET /books?q=hugo&language=fr&published_after=1860-01-01
```

If `q` needs clearly defined relevance ranking, fuzzy matching, cross-field boolean logic, facets, highlighting, or
other advanced search features, APIs **should** provide a dedicated search endpoint.

### Combining filters (`AND`)

When multiple different filter parameters are provided, the API **must** combine them using logical `AND`.

Example:

```http request
GET /products?category=books&state=active
```

Meaning: products that are in the `category` "books" AND have `state` "active".

### Repeated parameters (`OR`)

When the same filter parameter appears multiple times, or has a comma-separated list, the API **should** interpret it as
an `OR` for that field, and combine it with other filter parameters using `AND` (
see [Combining filters](#combining-filters-and)).

Example (both of these requests are equivalent):

```http request
GET /products?category=books&category=electronics
GET /products?category=books,electronics
```

In both cases, this means products with either the category "books" OR "electronics".

APIs **must not** require clients to rely on ambiguous separators without documentation (for example, silently treating
commas as special).

### `OR` across different fields

Modeling a general `OR` across different fields (e.g., `category=books OR state=active`) is difficult to represent
cleanly in query parameters and often leads to adhoc mini-languages.

Therefore, APIs **should not** support arbitrary boolean logic across different fields in query strings.
If a real use case requires it, APIs **should** consider:

* Defining a dedicated endpoint with well-defined semantics (still RESTful), or
* Defining a small number of explicit "union" parameters (e.g., `any_of_state=...`) where the meaning is unambiguous,
  or
* Providing a specialized search endpoint.

### Nullability and existence

REST query parameters do not naturally express "field is missing" vs. "field is present but empty". APIs **should**
avoid exposing "missing vs present" semantics unless necessary. If existence filtering is required, APIs **may** add
explicit parameters such as `has_<field>=true|false`

Example:

``` http request
GET /users?has_phone_number=true
```

APIs **must** document exactly what "has" means (non-null, non-empty string, non-empty array, etc.).

### Unknown parameters and validation

APIs **should** treat unknown filter parameters as a client mistake, returning a `400 Bad Request` with a clear message
indicating the unsupported parameter(s).

APIs **must** validate filter values and return `400 Bad Request` for invalid formats (e.g., invalid timestamp).

If the API intentionally ignores unknown parameters for backwards/forwards compatibility, that behavior **must** be
documented (but this is generally discouraged for filtering because silent failure is hard to detect).

### Pattern matching and wildcards

APIs **should** support only _deterministic_ pattern matching as filters (e.g., `<field>_prefix`, `<field>_contains`)
when needed. APIs **must not** introduce relevance ranking, fuzziness, or cross-field query logic under "filtering". If
requirements exceed deterministic filtering, APIs should use (a) dedicated search endpoint(s).

### Performance and safety limits

Filtering can create expensive queries. APIs **must**:

* Document which fields are filterable.
* Set limits (maximum number of filter values, maximum string length, etc.) as needed.
* Ensure that adding filters does not allow clients to bypass authorization rules (filters constrain after access
  control, not instead of it).

## Rationale

Query-parameter-based filtering is the most interoperable and REST-aligned approach: it is simple, cache-friendly, easy
to document in OpenAPI, and avoids embedding custom expression languages that often drift across APIs and create
inconsistent client experiences.

[query parameters]: /query-parameters

[Pagination]: /pagination

[GET]: /get

## Changelog

* **2025-12-11**: Initial creation, adapted from [Google AIP-160][] and aep.dev [AEP-160][].

[Google AIP-160]: https://google.aip.dev/160

[AEP-160]: https://aep.dev/160