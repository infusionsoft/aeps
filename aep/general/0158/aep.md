# Pagination

APIs often need to provide collections of data. However, collections can often be arbitrarily sized and also
often grow over time, increasing lookup time as well as the size of the
responses being sent over the wire. Therefore, it is important that collections
be paginated.

## Guidance

Endpoints returning collections of data **must** be paginated.

APIs **should** prefer [cursor-based pagination](#cursor-based-pagination) and
avoid [offset-based pagination](#offset-based-pagination).

### Cursor-based Pagination

Cursor-based pagination is usually better and more efficient when compared to offset-based pagination, especially when
it comes to high-data volumes and/or storage in NoSQL databases. It uses a `page_token` which is an opaque pointer to a
page that must never be inspected or constructed by clients. It usually encodes the page position (i.e., the unique
identifier of the first or last page element), the pagination direction, and the applied query filters to safely
recreate the collection.

When implementing cursor-based pagination:

* Request messages for collections **should** define an integer `page_size` field, allowing users to specify the maximum
  number of results to return.
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
      **should** send an `400 Bad Request` error.
* Response messages for collections **must** define a `string` `next_page_token` field, providing the user with a page
  token that may be used to retrieve the next page.
    * The field containing pagination results **must** be an array containing a list of resources constituting a single
      page of results.
    * If the end of the collection has been reached, the `next_page_token` field **must** be empty. This is the _only_
      way to communicate "end-of-collection" to users.
    * If the end of the collection has _not_ been reached, the API **must** provide a `next_page_token`.
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
  "next_page_token": "def456uvw"
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

Many APIs store page tokens in a database internally. In this situation, APIs
**may** expire page tokens a reasonable time after they have been sent, in
order not to needlessly store large amounts of data that is unlikely to be
used. It is not necessary to document this behavior.

**Note:** While a reasonable time may vary between APIs, a good rule of thumb
is three days.

### Offset-based pagination

Cursor-based pagination should be preferred over offset-based pagination. However, we understand that most of our APIs
were built before cursor-based pagination became the standard practice. Migrating these APIs to cursor-based pagination
is not a small effort. We encourage the migration to cursor-based pagination, but understand teams have other
priorities, and this will take time. Therefore, these are the guidelines for offset-based pagination.

When implementing offset-based pagination:

* Request schemas for collections **must** define an integer `offset` query parameter, allowing users to specify the
  number of results to skip before returning results.
    * The `offset` field **must not** be required and **must** default to `0`.
* Request schemas for collections **must** define an integer `limit` query parameter (equivalent to `page_size` in
  cursor-based pagination), allowing users to specify the maximum number of results to return.
    * The `limit` field **must not** be required.
    * If the request does not specify `limit`, the API **must** choose an appropriate default.
* Response messages **may** include a `total` field indicating the total number of results available, though this *
  *should** be avoided if the calculation is expensive.
* The API **may** return fewer results than the number requested (including zero results), even if not at the end of the
  collection.

Example:

```http request
GET /v1/publishers/123/books?limit=50&offset=100
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
  ]
}
```

**Limitations of offset-based pagination:**

* Performance degrades with large offsets, as the database must skip many rows
* Results can be inconsistent if data changes between requests (items may be skipped or duplicated)
* Not suitable for real-time data or frequently updated collections

## Changelog

* **2025-12-10**: Initial creation, adapted from [Google AIP-158][] and aep.dev [AEP-158][].

[Google AIP-158]: https://google.aip.dev/158

[AEP-158]: https://aep.dev/158
