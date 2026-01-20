# Pagination

APIs often need to provide collections of data. However, collections can often be arbitrarily sized and also
often grow over time, increasing lookup time as well as the size of the
responses being sent over the wire. Therefore, it is important that collections
be paginated.

## Guidance

* Endpoints returning collections of data **must** be paginated.
* APIs **should** prefer [cursor-based pagination](#cursor-based-pagination)
  to [offset-based pagination](#token-based-offset-pagination).
    * If using offset-based pagination, _new_ APIs **must**
      implement [token-based offset pagination](#token-based-offset-pagination).
* Query parameters for pagination **must** follow the guidelines in AEP-106.

### Cursor-based pagination

Cursor-based pagination uses a `page_token` which is an opaque pointer to a page that must never be inspected or
constructed by clients. It encodes the page position (i.e., the unique identifier of the first or last page element),
the pagination direction, and the applied query filters to safely recreate the collection.

When implementing cursor-based pagination:

* Request messages for collections **should** define an integer `page_size` query parameter, allowing users to specify
  the maximum number of results to return.
    * The `page_size` field **must not** be required.
    * If the request does not specify `page_size`, the API **must** choose an appropriate default.
    * The API **may** return fewer results than the number requested (including zero results), even if not at the end of
      the collection.
* Request schemas for collections **must** define a `string` `page_token` query parameter, allowing users to advance to
  the next page in the collection.
    * The `page_token` field **must not** be required.
    * If the user changes the `page_size` in a request for subsequent pages, the service **must** honor the new page
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
GET /v1/publishers/123/books?page_size=50&page_token=abc123xyz
```

responds with:

```json
{
  "books": [
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

### Token-based offset pagination

APIs that have a legitimate need for offset-based pagination **should** use token-based offset pagination. This approach
encodes the offset, limit, and any filters into an opaque token.

When implementing token-based offset pagination:

* The API **must** use the same request/response structure as [cursor-based pagination](#cursor-based-pagination) (
  `page_size`, `page_token` and `nextPageToken`)
* The page token **must** internally encode the offset, limit, and query parameters
* The implementation details **must** be hidden from the client

From the client's perspective, this is identical to cursor-based pagination. The difference is only in the server-side
implementation.

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

### Small collections

All collections **must** return a paginated response structure, regardless of size.

For collections that are known to be small (subject to interpretation, but typically fewer than 1000 items), endpoints *
*should** implement true pagination. That way, if the collection grows beyond the expected size in the future,
pagination is already in place.

However, if the collection is small enough that it doesn't benefit from true pagination, endpoints **may** return all
results in a single page with an empty `nextPageToken`, without implementing actual pagination logic.

### Traditional offset-based pagination

**Important:** _New_ APIs **must not** use traditional offset-based pagination. If offset-based pagination is required,
_new_ APIs **must** use [token-based offset pagination](#token-based-offset-pagination) instead.

This section documents traditional offset-based pagination for backwards compatibility with existing APIs. Migration to
a different pagination strategy is highly encouraged, although not required (_yet_).

When implementing traditional offset-based pagination (existing APIs only):

* Request schemas for collections **must** define an integer `offset` query parameter, allowing users to specify the
  number of results to skip before returning results.
    * The `offset` field **must not** be required and **must** default to `0`.
* Request schemas for collections **must** define an integer `limit` query parameter, allowing users to specify the
  maximum number of results to return.
    * The `limit` field **must not** be required.
    * If the request does not specify `limit`, the API **must** choose an appropriate default.
* Response messages **may** include a `total` field indicating the total number of results available, though this
  **should** be avoided if the calculation is expensive.
* The API **may** return fewer results than the number requested (including zero results), even if not at the end of the
  collection.

## Rationale

### Cursor-based pagination

Cursor-based pagination is generally better and more efficient than offset-based pagination. Cursor-based pagination
maintains consistent performance regardless of dataset size, while offset-based pagination degrades as offsets increase.
Many NoSQL databases are optimized for cursor-based access patterns. Cursor-based pagination provides consistent results
even when data changes between requests, preventing items from being skipped or duplicated. It is also better suited for
collections that are frequently updated. These advantages make cursor-based pagination the preferred approach for _most_
use cases.

### Token offset vs offset pagination

Using tokens makes the API flexible for the future. It allows switching to cursor-based pagination internally without
breaking the API contract. All paginated endpoints (cursor and offset) work the same way from the client's perspective.
Tokenizing offset pagination prevents users from manipulating offsets arbitrarily to access data in unintended ways. And
it also prevents users from changing filters/sorts mid-pagination, which can cause inconsistent results. These benefits
make token-based offset pagination better than traditional offset-based pagination.

### Avoid traditional offset-based pagination

Traditional offset-based pagination has several significant limitations. Performance degrades with large offsets, as the
database must skip many rows before returning results. Results can be inconsistent if data changes between requests;
items may be skipped or duplicated as users page through results. It is not suitable for real-time data or frequently
updated collections. Also, users can manipulate offsets arbitrarily to access data in potentially unintended ways. These
limitations are why new APIs must use either cursor-based pagination or token-based offset pagination instead.

## Changelog

* **2025-12-15**: Added guidance on token-based offset pagination for new APIs, small collection handling, and clarified that new APIs must use cursor-based or token-based offset pagination only.
* **2025-12-10**: Initial creation, adapted from [Google AIP-158][] and aep.dev [AEP-158][].

[Google AIP-158]: https://google.aip.dev/158

[AEP-158]: https://aep.dev/158
