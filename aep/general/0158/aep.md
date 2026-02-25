# Pagination

APIs often need to provide collections of data. However, collections can often be arbitrarily sized and also
often grow over time, increasing lookup time as well as the size of the
responses being sent over the wire. Therefore, it is important that collections
be paginated.

## Guidance

* Endpoints returning collections of data **must** be paginated.
* APIs **should** prefer [cursor-based pagination](#cursor-based-pagination)
  to [offset-based pagination](#token-based-offset-pagination).
  See [Choosing a pagination strategy](#choosing-a-pagination-strategy).
* Query parameters for pagination **must** follow the guidelines in AEP-106.
* The array of resources **must** be named `results` and contain resources with
  no additional wrapping.

### Choosing a pagination strategy

**Note:** Many technical constraints trace back to database design decisions made long before an API is built. A schema
that lacks stable sort keys, proper indexing, or a well-chosen primary key will make cursor pagination difficult and
offset pagination unreliable. How you design your database is important. A well-designed schema keeps both pagination
strategies on the table, while a poor one may take options off the table permanently.

This decision is not purely a UX decision, nor is it purely a technical one. UX requirements are a valid and important
input, but **must** be weighed against dataset characteristics and performance rather than treated as the deciding
factor in isolation. A great UX with offset pagination is of no use if the underlying dataset cannot support it
reliably. Before choosing offset, teams **must** evaluate both user experience _and_ technical limitations.

Use cursor-based pagination when:

- The dataset is large, unbounded, or expected to grow significantly over time.
- The underlying database is NoSQL or sharded, where offset scanning is expensive or unreliable.
- The data changes frequently, as offset pagination may produce duplicates or skip items between page requests.
- Sequential traversal (next/previous) is enough for the use case.

Use offset-based pagination when:

- The dataset is small, bounded, and unlikely to grow significantly.
- The underlying database is relational and the paginated query can be efficiently indexed.
- The data is stable and unlikely to change between page requests.
- Users must be able to jump to an arbitrary page, this is a validated user need and not just an assumed one.
- UX requirements genuinely call for it, and the above technical factors do not contradict it.

**Note:** Cursor is also the safer default: switching from cursor to offset later is straightforward, but the reverse
will ruin your week.

### Cursor-based pagination

Cursor-based pagination uses a `pageToken` which is an opaque pointer to a page that must never be inspected or
constructed by clients. It encodes the page position (i.e., the unique identifier of the first or last page element),
the pagination direction, and the applied query filters to safely recreate the collection.

When implementing cursor-based pagination:

* Request messages for collections **should** define an integer `pageSize` query parameter, allowing users to specify
  the maximum number of results to return.
    * The `pageSize` field **must not** be required.
    * If the request does not specify `pageSize`, the API **must** choose an appropriate default.
    * The API **may** return fewer results than the number requested (including zero results), even if not at the end of
      the collection.
* Request schemas for collections **must** define a `string` `pageToken` query parameter, allowing users to advance to
  the next page in the collection.
    * The `pageToken` field **must not** be required.
    * If the user changes the `pageSize` in a request for subsequent pages, the service **must** honor the new page
      size.
    * The user is expected to keep all other arguments to the method the same; if any arguments are different, the API
      **should** return a `400 Bad Request` error.
* Response messages for collections **must** define a `string` `nextPageToken` field, providing the user with a page
  token that may be used to retrieve the next page.
    * The field containing pagination results **must** be an array containing a list of resources constituting a single
      page of results.
    * If the end of the collection has been reached, the `nextPageToken` field **must** be empty. This is the _only_
      way to communicate "end-of-collection" to users.
    * If the end of the collection has _not_ been reached, the API **must** provide a `nextPageToken`.
* Responses **should** avoid including a total result count, since calculating it is a costly operation usually not
  required by clients.

Example:

```http request
GET /v1/publishers/123/books?pageSize=50&pageToken=abc123xyz
```

responds with:

```json
{
  "results": [
    {
      "id": "456",
      "title": "Les Misérables",
      "author": "Victor Hugo"
    }
    // ... 49 more books
  ],
  "nextPageToken": "def456uvw"
}
```

### Page Token Opacity

Page tokens provided by APIs **must** be opaque (but URL-safe) strings, and **must not** be user-parseable. This is
because if users are able to deconstruct these, _they will do so_. Tokens must never be inspected or constructed by
clients. Therefore, tokens **must** be encoded (encrypted) in a non-human-readable form.

**Warning:** Base-64 encoding an otherwise-transparent page token is **not** a
sufficient obfuscation mechanism.

Page tokens **must** be limited to providing an indication of where to continue
the pagination process only. They **must not** provide any form of
authorization to the underlying resources, and authorization **must** be
performed on the request as with any other regardless of the presence of a page
token.

### Page Token Expiration

Some APIs store page tokens in a database internally. In this situation, APIs
**should** expire page tokens a reasonable time after they have been sent, in
order not to needlessly store large amounts of data that is unlikely to be
used. It is not necessary to document this behavior.

**Note:** While a reasonable time may vary between APIs, a good rule of thumb
is three days.

### Offset-based pagination

When implementing offset-based pagination:

* Request schemas for collections **must** define an integer `pageNumber` query parameter, allowing users to specify
  which page of results to return.
    * The `pageNumber` field **must not** be required and **must** default to `1`.
* Request schemas for collections **must** define an integer `pageSize` query parameter, allowing users to specify the
  maximum number of results to return.
    * The `pageSize` field **must not** be required.
    * If the request does not specify `pageSize`, the API **must** choose an appropriate default.
* Response messages **may** include a `total` field indicating the total number of results available, though this
  **should** be avoided if the calculation is expensive.
* The API **may** return fewer results than the number requested (including zero results), even if not at the end of the
  collection.

Example:

```http request
GET /v1/publishers/123/books?pageSize=50&pageNumber=2
```

responds with:

```json
{
  "results": [
    {
      "id": "456",
      "title": "Les Misérables",
      "author": "Victor Hugo"
    }
    // ... 49 more books
  ],
  "total": 342
}
```

### Small Collections

All collections **must** return a paginated response structure, regardless of
size. For collections that will never meaningfully benefit from pagination,
endpoints **may** satisfy this requirement by returning all results in a single
response with an empty or absent `nextPageToken`, without implementing actual
pagination logic. In other words, just wrap the results in the pagination envelope
without actually implementing pagination.

However, if there is any reasonable chance the collection grows beyond a small
size (typically a few hundred to low thousands of items), endpoints **should**
implement true pagination from the start. Retrofitting pagination onto a
collection that clients already consume as a single page is a breaking change.

## Interface Definitions

### Cursor Pagination

{% tab proto %}

{% tab oas %}

{% sample 'cursor.oas.yaml', '$.paths./publishers/{publisher_id}/books.get' %}

{% endtabs %}

### Offset Pagination

{% tab proto %}

{% tab oas %}

{% sample 'offset.oas.yaml', '$.paths./publishers/{publisher_id}/books.get' %}

{% endtabs %}

## Rationale

### Preferring cursor over offset

Cursor-based pagination is generally better and more efficient than offset-based pagination. Cursor-based pagination
maintains consistent performance regardless of dataset size, while offset-based pagination degrades as offsets increase.
Many NoSQL databases are optimized for cursor-based access patterns. Cursor-based pagination provides consistent results
even when data changes between requests, preventing items from being skipped or duplicated. It is also better suited for
collections that are frequently updated. These advantages make cursor-based pagination the preferred approach for _most_
use cases.

## Changelog

* **2026-02-23**: Change guidance to allow both offset and cursor. Remove the token offset option. Add guidance on when
  to choose each method.
* **2026-01-30**: Enforce `camelCase`, not `snake_case` for query parameters
* **2025-12-15**: Added guidance on token-based offset pagination for new APIs, small collection handling, and clarified
  that new APIs must use cursor-based or token-based offset pagination only.
* **2025-12-10**: Initial creation, adapted from [Google AIP-158][] and aep.dev [AEP-158][].

[Google AIP-158]: https://google.aip.dev/158

[AEP-158]: https://aep.dev/158
