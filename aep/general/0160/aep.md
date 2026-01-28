# Filtering

Filtering is a common requirement for collection endpoints in APIs. When listing resources (for example,
`GET /books`), clients often need to narrow results to only those that match specific criteria such as state, owner,
category, or timestamps.

Filtering applies deterministic, field-aware constraints that are index-friendly and predictable. Filtering is distinct
from:

* Sorting (ordering results)
* [Pagination] (windowing results)
* [Searching] (partial text matching, fuzzy queries, complex boolean logic)

**Note:** Because filters are intended for a potentially non-technical audience, they sometimes borrow from patterns of
colloquial speech rather than common patterns found in code.

## Guidance

APIs **may** support filtering on collection endpoints. If supported:

* Filtering **must** be modeled as explicit query parameters on a [GET] request (not request body). It **must not** be
  modeled as a single `filter` string with a custom language/grammar. Query parameters **must** follow the naming and
  encoding rules in AEP-106.
* Filtering parameters **must not** change the meaning of the resource model; they only constrain which items appear in
  the collection response.
* APIs **must** document:
    * Supported filter parameters
    * Accepted value formats (especially timestamps)
    * Case sensitivity rules for string matching

Examples:

```http request
### Get all books created after 2025-01-01
GET /books?created_after=2025-01-01T00:00:00Z

### Get all published books
GET /books?state=published
```

### Naming Conventions

Different APIs have different resource models and user needs, so the set of filterable fields and supported operators
will vary. These guidelines ensure consistency in _how_ filters are named and composed, while allowing each API to
decide _which_ filters to offer based on real use cases.

Filtering parameter names **must** be stable (do not rename lightly), specific, and self-explanatory.

APIs **must** use the direct field name for exact matches (e.g. `state=active`, `category=books`).

APIs **should** use the following prefix/suffix modifiers for common comparisons. Use consistent prefixes/suffixes and
only introduce them when there is more than one plausible comparison. APIs **should** use a subset as appropriate.

| Operator  | Meaning                                                 | Example                     |
|-----------|---------------------------------------------------------|-----------------------------|
|           | Equals (direct field name)                              | `status=active`             |
| `_ne`     | Not equals                                              | `status_ne=cancelled`       |
| `_lt`,    | Less than                                               | `price_lt=100`              |
| `_lte`    | Less than or equal                                      | `price_lte=100`             |
| `_gt`,    | Greater than                                            | `price_gt=0`                |
| `_gte`    | Greater than or equal                                   | `price_gte=50`              |
| `_before` | Timestamp-specific `<`                                  | `created_before=2025-01-01` |
| `_after`  | Timestamp-specific `>`                                  | `created_after=2025-01-01`  |
| `is_`     | Boolean checks                                          | `is_active=true`            |
| `has_`    | [Nullability and existence](#nullability-and-existence) | `has_phone_number=true`     |

### Combining filters (`AND`)

When multiple different filter parameters are provided, the API **must** combine them using logical `AND`.

Example:

```http request
### products that are in the "books" category AND active
GET /products?category=books&state=active
```

### Repeated parameters (`OR`)

When the same filter parameter appears multiple times, or has a comma-separated list, the API **should** interpret it as
an `OR` for that field, and combine it with other filter parameters using `AND` (
see [Combining filters](#combining-filters-and)).

Example (both of these requests are equivalent):

```http
GET /products?category=books&category=electronics
GET /products?category=books,electronics
```

In both cases, this means products with either the category "books" OR "electronics".

APIs **must not** require clients to rely on ambiguous separators without documentation (for example, silently treating
commas as special). APIs **should** support both formats (repeated parameters and comma-separated values) to maximize
client flexibility. If supporting only one format, APIs **must** clearly document which format is accepted.

### `OR` across different fields

Modeling a general `OR` across different fields (e.g., `category=books OR state=active`) is difficult to represent
cleanly in query parameters and often leads to ad-hoc mini-languages.

Therefore, APIs **should not** support arbitrary boolean logic across different fields in query strings.
If a real use case requires it, APIs **should** implement a specialized [search] endpoint.

### Nullability and existence

Query parameters do not naturally express "field is missing" vs. "field is present but empty". APIs **should**
avoid exposing "missing vs present" semantics unless necessary. If existence filtering is required, APIs **may** add
explicit parameters such as `has_{field}=true|false`

Example:

``` http request
GET /users?has_phone_number=true
```

APIs **must** document exactly what "has" means for each field (non-null, non-empty string, non-empty array, etc.). The
semantics **must** be consistent within a single API.

### Unknown parameters and validation

APIs **should** treat unknown filter parameters as a client mistake, returning a `400 Bad Request` with a clear message
indicating the unsupported parameter(s).

APIs **must** validate filter values and return `400 Bad Request` for invalid formats (e.g., invalid timestamp).

If the API intentionally ignores unknown parameters for backwards/forwards compatibility, that behavior **must** be
documented (but this is discouraged for filtering because silent failure is hard to detect).

### Pattern matching and wildcards

APIs **should** support filtering only for _deterministic_, field-aware constraints that are index-friendly and
predictable. APIs **must not** introduce relevance ranking, fuzziness, or cross-field query logic under "filtering". If
requirements exceed deterministic filtering, APIs **should** use (a) dedicated [search] endpoint(s).

### Pattern matching and wildcards

Filtering is designed for precise, deterministic matching (e.g., "state is ACTIVE" or "price greater than 100"). APIs *
*must** support filtering only for _deterministic_, field-aware constraints that are index-friendly and predictable.
APIs **must not** introduce partial text matching, wildcards, relevance ranking, fuzziness, or cross-field query logic
under "filtering". These operations belong in dedicated [search] endpoints.

For example, these are NOT filtering: `name=Victor*` (wildcard), `description=~fuzzy match~` (fuzzy search).

If requirements exceed deterministic filtering, APIs **must** use dedicated [search] endpoint(s).

### Performance and safety limits

Filtering can create expensive queries. APIs **must**:

* Document which fields are filterable.
* Set limits (maximum number of filter values, maximum string length, etc.) as needed.
* Ensure that adding filters does not allow clients to bypass authorization rules (filters constrain after access
  control, not instead of it).

## Rationale

Multi-parameter filtering using explicit query parameters is the most interoperable and REST-aligned approach. It is
simple, cache-friendly, naturally integrates with OpenAPI documentation and SDK generation, and leverages standard query
parameter parsing built into every web framework. This approach avoids single-parameter filter DSLs, which historically
struggle with cross-language consistency, require custom parsers, and often result in partial implementations that
defeat standardization benefits. For an in-depth analysis of filtering strategies and the decision process behind these
guidelines, see
[ADR-001: REST API Filtering and Searching Strategy](https://github.com/infusionsoft/aeps/blob/main/docs/arch/adr-001.md).

[query parameters]: /query-parameters

[Pagination]: /pagination

[Searching]: /searching

[search]: /searching

[GET]: /get

## Changelog

* **2026-01-27**: Removed search guidance, it will be a separate AEP. Align guidance with [ADR-001].
* **2025-12-11**: Initial creation, adapted from [Google AIP-160][] and aep.dev [AEP-160][].

[Google AIP-160]: https://google.aip.dev/160

[AEP-160]: https://aep.dev/160

[ADR-001]: https://github.com/infusionsoft/aeps/blob/main/docs/arch/adr-001.md