# Searching

Searching is distinct from [filtering]. Filtering is for deterministic, field-aware constraints; structured predicates
on known fields that are index-friendly and produce consistent results. Searching is for more expressive or fuzzy
queries, including full-text matching, relevance ranking, faceted results, and complex boolean logic across fields,
where a simple filter model becomes awkward or insufficient.

APIs that need both capabilities **may** support them simultaneously. When doing so, they are defined and documented
independently.

## Guidance

APIs **may** support simple text search with a `q` query parameter. APIs **may** also support advanced search with
dedicated search endpoints.

`q` is meant to be a simple text search without a full-blown seach endpoint; use `q` for those cases. Any advanced text
searches, fuzzy matching, complex or cross-field boolean logic, facets, highlighting, or other advanced features, create
a dedicated search endpoint.

### Free-text search (`q`)

Some endpoints benefit from a simple "type-ahead" or keyword-style search where users enter free text and expect
the API to find relevant results without requiring structured field filters.

To support this, APIs **may** define a `q` query parameter on collection `GET` endpoints (for example,
`GET /books?q=les+mis`). The `q` parameter is intended to be:

* Unstructured: a user-entered string, not a mini-language.
* Best-effort: APIs may match across one or more fields (e.g., title, subtitle, author name), using partial matches.
* Simple: clients should not need to know the resource schema to use it.

`q` **must** be combined with other query parameters using logical `AND` (same behavior as any other query parameters).

If an API supports `q`, it **must** clearly document:

* Which fields are searched (e.g., `title` and `author.name`), and whether those fields may change over time.
* Matching behavior (case sensitivity, tokenization/word splitting, diacritics, stemming/synonyms if any).
* Whether results are _ranked_ (best match first) or simply filtered.
* Any limits (maximum query length, minimum characters, rate limits, etc.).

APIs **must not**:

* Treat `q` as a structured filter language (e.g., `q=title:foo AND author:bar`), because that reintroduces custom query
  grammar.
* Require wildcard syntax in `q` (such as `*`). If wildcard-like behavior is needed, it should be provided through
  a dedicated search endpoint.
* Reuse `q` for non-search concepts (e.g., passing JSON, passing encoded filter objects, or toggling behaviors).

Examples:

```http request
### Keyword search on a collection
GET /books?q=les+mis

### Keyword search combined with structured filters
GET /books?q=hugo&language=fr&published_after=1860-01-01
```

### Dedicated search endpoints

**must** be a custom action endpoint named `:search`.
**must** use `POST` since `GET` must not have a body.
**must** define all the search criteria in the request body, and **should not** try to combine [filter] query parameters with it; that will make things more complicated than they need to be. [Pagination] query parameters **should** still be in the query parameters.
**must** use a structured query language to express search criteria. A great place to get some inspiration is looking at [GraphQL Queries](https://graphql.org/learn/queries).

For example:
```json
{
  "filter": {
    "status": { "eq": "SENT" },
    "createdTime": { "gte": "2025-01-01" },
    "or": [
      { "country": { "eq": "US" } },
      { "country": { "eq": "CA" } }
    ]
  }
}
```

### Performance and safety limits

Searching can create expensive queries.

### Dedicated search endpoints

When search requirements grow beyond what `q` can reasonably express: complex boolean logic, cross-field expressions,
fuzzy matching tolerances, facets, relevance tuning, or highlighting, APIs **should** expose a dedicated search
endpoint rather than stretching `q` or filter parameters to cover the use case.

Dedicated search endpoints **must** be defined as a [custom action] named `:search` on the collection being searched
(e.g., `POST /books:search`). They **must** use `POST`, since `GET` **must not** carry a request body.

All search criteria **must** be defined in the request body. APIs **should not** mix [filter] query parameters with
request body search criteria; doing so splits the query contract across two mechanisms and makes the endpoint harder
to reason about and document. [Pagination] query parameters (e.g., `pageToken`, `pageSize`) **should** still
be expressed as query parameters, consistent with how pagination works across all collection endpoints.

The response shape **should** follow the same structure as the corresponding [list] collection response, including
pagination fields, so that clients can handle both interchangeably.

#### Request body structure

The request body **must** contain a top-level `query` field that holds the search expression. APIs **must** use a
structured query language, expressed as a JSON object, to represent the search criteria.

The choice of query language is left to the API, but all search endpoints within a single API **must** use the same
query language and operator conventions. Clients need to be able to learn the query model once and apply it across
every `:search` endpoint in the API.

When designing or selecting a query
language, [Elasticsearch Query DSL](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html)
and [GraphQL Queries](https://graphql.org/learn/queries/) are reasonable points of reference.

For example, using an operator-object style:
```json
{
  "query": {
    "status": { "eq": "SENT" },
    "createdTime": { "gte": "2025-01-01" },
    "or": [
      { "country": { "eq": "US" } },
      { "country": { "eq": "CA" } }
    ]
  }
}
```

#### Wildcard search

APIs **may** support wildcard pattern matching via a `wildcard` operator in the query body. If supported, the
`wildcard` operator **must** be a top-level key within the `query` object, sibling to any other field predicates or
logical combinators.

The `wildcard` operator **must** target a single field, expressed as a nested object with the field name as the key.
The inner object **must** include a `value` field containing the pattern string, and **may** include a
`case_insensitive` boolean (defaulting to `false` if omitted).

The following wildcard character **must** be supported if the operator is implemented:

* `*` — matches zero or more characters (e.g., `H*` matches `Hello`, `Hi`, and `H`).
```json
{
  "query": {
    "wildcard": {
      "username": {
        "value": "H*Y",
        "case_insensitive": false
      }
    }
  }
}
```

The `wildcard` operator **may** be combined with other field predicates and logical combinators within the same query:
```json
{
  "query": {
    "status": { "eq": "ACTIVE" },
    "wildcard": {
      "username": {
        "value": "H*",
        "case_insensitive": true
      }
    }
  }
}
```

Wildcard queries can be significantly more expensive than exact or full-text match queries. APIs that support
wildcards **should** enforce additional limits, such as requiring a minimum number of leading literal characters
before a wildcard (e.g., disallowing patterns like `*foo` or `*`), and **must** document those constraints.

APIs **must not** silently interpret `q` parameter values as wildcard expressions. Wildcard behavior belongs
exclusively in the dedicated search endpoint.

#### Pagination

Pagination **must** behave identically to the corresponding `GET` collection endpoint. [Pagination] query parameters
**should** be passed on the query string (e.g., `POST /books:search?pageSize=25&pageToken=...`) rather than in the
body, so that individual pages of a search result can be fetched independently without re-posting the full body.

The response **must** include a `nextPageToken` (or equivalent) when additional results are available, and **must
not** require clients to re-send the body to advance through pages — the token itself **must** encode or reference
the original query.

#### Sorting

If an API supports result sorting, a `orderBy` field **may** be included in the request body. Its format **should**
be consistent with any `orderBy` support on the corresponding `GET` endpoint.
```json
{
  "query": {
    "status": { "eq": "ACTIVE" }
  },
  "orderBy": "createdTime desc"
}
```

When the search uses a `match` operator or other relevance-producing operators, APIs **may** support a special
`_score` sort field to order by relevance. APIs **should** document whether relevance scoring is available and what
it reflects.

#### Projections and highlights

APIs **may** support a `fields` array in the request body to limit which fields are returned in each result,
consistent with how field projection works elsewhere in the API.

APIs **may** support a `highlight` field to request that matching text fragments be annotated in the response.
If supported, highlight configuration and response format **must** be documented.

### Performance and safety limits

Search endpoints can produce expensive queries, particularly those involving `match`, unbounded `or` trees, or
queries over high-cardinality fields. APIs **should** enforce and document limits, including:

* Maximum nesting depth for query trees.
* Maximum number of values in `in` / `nin` arrays.
* Maximum length of `match` strings.
* Query timeout behavior and the error shape returned when a timeout is hit.
* Rate limits, if distinct from other endpoints.

Requests that exceed documented limits **must** return `400 Bad Request` with a descriptive error.

## Rationale

### POST for dedicated search endpoints

Using `POST` for search is a pragmatic deviation from the convention that `POST` implies mutation. The alternatives
are not workable: `GET` with a body is technically allowed by HTTP but widely unsupported by proxies, CDNs, and HTTP
client libraries, and `GET` query strings cannot reliably encode deeply nested boolean structures. `POST` to a
`:search` custom action clearly signals intent and sidesteps those constraints. The tradeoff is that `POST` requests
are not natively cacheable; APIs that need caching of search results should implement it at the application layer.

### Operator object model

Expressing predicates as `{ "field": { "operator": value } }` keeps the structure JSON-native and avoids inventing a
string-based mini-language. It is inspectable, easy to serialize, and straightforward to validate with a JSON Schema.
This pattern is used by a number of widely adopted APIs and query systems, and strikes a balance between power and
simplicity.

### Pagination in query parameters for POST search

Although the search criteria live in the request body, pagination parameters belong in the query string. This allows
a pagination token to serve as a stable, self-contained reference to a specific page of a specific result set — one
that can be bookmarked, logged, or shared — without requiring the receiver to possess the original request body.

## Further Reading

* [AEP: Filtering] — field-based filtering as an alternative or complement to search
* [AEP: Pagination] — pagination patterns referenced throughout this AEP
* [AEP: Custom Methods] — the `:search` naming convention follows the custom action pattern
* [GraphQL Queries](https://graphql.org/learn/queries/) — inspiration for structured query expression in request bodies

## Changelog

* **2025-02-24**: Initial creation

[query parameters]: /query-parameters
