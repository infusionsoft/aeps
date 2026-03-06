# Reading across collections

Sometimes, it is useful to retrieve resources from nested collections without knowing the specific parent identifier, or
to query across multiple parent collections simultaneously. This pattern is particularly useful in REST APIs with
hierarchical resource structures where resources are naturally organized under parent collections.

**Note:** An alternative REST approach is to provide a top-level collection endpoint (e.g., `/v1/books`) alongside
nested endpoints, as described in [Resource Paths]. The wildcard pattern described here is useful when maintaining
strict hierarchical access patterns while still allowing cross-collection queries.

## Guidance

APIs **may** support reading resources across multiple collections by allowing users to specify a `-` (the hyphen or
dash character) as a wildcard character in a standard [List](./list) action:

```http
GET /v1/publishers/-/books?filter=...
```

- The method **must** explicitly document that this behavior is supported.
- The resources provided in the response **must** use the canonical name of the
  resource, with the actual parent collection identifiers (instead of `-`).
- Services **may** support reading across collections when listing resources regardless of whether the identifiers of
  the child resources are guaranteed to be unique. However, services **must not** support reading across collections
  when retrieving individual resources if the child resource identifiers might collide across different parent
  collections.
- Cross-parent requests **should not** support `orderBy` query parameters. If they do, the parameter **must** document
  that ordering is best effort. This is because cross-parent requests introduce ambiguity around ordering, especially if
  there is difficulty reaching a parent (see [unreachable resources]).

**Important:** If listing across multiple collections introduces the
possibility of partial failures due to unreachable parents (such as when
listing across locations), the method **must** indicate this following the
guidance in [unreachable resources].

- The OpenAPI path pattern **must** include a parameter for the collection
  identifier, rather than hard-coding the `-` character. This allows clients to
  use either a specific collection ID or the wildcard `-`.
- The path parameter **should** allow the `-` character as a valid value.

**Note:** When using wildcard collection lookup, the response **must** return
resources with their canonical paths containing actual parent collection
identifiers, not the wildcard character.

**Example:** List books across all publishers:

{% tab proto %}

{% tab oas %}

```yaml
paths:
  /v1/publishers/{publisherId}/books:
    get:
      operationId: listBooks
      description: >-
        Lists books for a specific publisher. Supports wildcard collection
        lookup: use `-` as the publisherId to list books across all
        publishers. When using the wildcard, books from all publishers are
        returned with their canonical resource paths (e.g.,
        publishers/123/books/456, not publishers/-/books/456).
      parameters:
        - in: path
          name: publisherId
          required: true
          schema:
            type: string
          description: >-
            The publisher ID. Use `-` to list books across all publishers.
```

{% endtabs %}

### Unique resource lookup

Sometimes, a resource within a sub-collection has an identifier that is unique
across parent collections. In this case, it may be useful to allow a
[Get](./get) action to retrieve that resource without knowing which parent
collection contains it. In such cases, APIs **may** allow users to specify the
wildcard collection ID `-` (the hyphen or dash character) to represent any
parent collection:

```http
GET /v1/publishers/-/books/{bookId}
```

- The URI pattern **should** still be specified with a variable and permit the
  collection to be specified; a URI pattern **should not** hard-code the `-`
  character. Having a separate route for the wildcard case can lead to
  ambiguous or undefined routing behavior (unless the variable pattern excludes
  the string `"-"`)
- The method **must** explicitly document that this behavior is supported.
- The resource name in the response **must** use the canonical name of the
  resource, with actual parent collection identifiers (instead of `-`). For
  example, the request above returns a resource with a name like
  `publishers/123/books/456`, _not_ `publishers/-/books/456`.
- The resource ID **must** be unique within parent collections.

### Reading across collections with different path patterns

Sometimes, a resource may have multiple possible path patterns. This typically
happens when a resource, or one of its ancestors, may have more than one
possible parent resource (including having no parent).

For example, `Book` might have the following path patterns:

- `/publishers/{publisherId}/books/{bookId}` for books with a publisher
- `/books/{bookId}` for self-published books

In this case, APIs **may** allow users to read across _all_ collections of
books by using the `--` global wildcard sequence:

```http
GET /v1/--/books
```

Here, `--` is not a wildcard for a resource ID within a specific collection.
Rather, it is a wildcard for the entire path pattern. This allows users to
retrieve a book regardless of its resource ancestry.

This pattern may also be used to search all subcollections of a specific
collection. For example, a `Playlist` resource might have the following path
patterns:

- `games/{game}/users/{user}/playlists/{playlist}` for playlists created by a
  user within a game
- `games/{game}/zones/{zone}/playlists/{playlist}` for playlists specific to a
  game zone

A client could read across all collections of both zone and user playlists
_within_ game `123` with:

`GET /v1/games/123/--/playlists`

## Further reading

- For partial failures due to unreachable resources, see [unreachable resources].

[unreachable resources]: ./unreachable-resources

[Resource Paths]: /paths#resource-hierarchy-and-nesting

[GET]: /http-get

## Changelog

* **2026-02-11**: Add details for OpenAPI and reading across collections with different path patterns
* **2026-01-30**: Change `order_by` to `orderBy` to match query param spec
* **2025-12-10**: Initial creation, adapted from [Google AIP-159][] and aep.dev [AEP-159][].

[Google AIP-159]: https://google.aip.dev/159

[AEP-159]: https://aep.dev/159
