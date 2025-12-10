# Reading across collections

Sometimes, it is useful to retrieve resources from nested collections without knowing the specific parent identifier, or
to query across multiple parent collections simultaneously. This pattern is particularly useful in REST APIs with
hierarchical resource structures where resources are naturally organized under parent collections.

**Note:** An alternative REST approach is to provide a top-level collection endpoint (e.g., `/v1/books`) alongside
nested endpoints, as described in [Resource Paths]. The wildcard pattern described here is useful when maintaining
strict hierarchical access patterns while still allowing cross-collection queries.

## Guidance

APIs **may** support reading resources across multiple collections by allowing users to specify a `-` (the hyphen or
dash character) as a wildcard character in a standard [GET]:

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
- Cross-parent requests **should not** support `order_by` query parameters. If they do, the parameter **must** document
  that ordering is best effort. This is because cross-parent requests introduce ambiguity around ordering, especially if
  there is difficulty reaching a parent (see [unreachable resources]).

**Important:** If listing across multiple collections introduces the
possibility of partial failures due to unreachable parents (such as when
listing across locations), the method **must** indicate this following the
guidance in [unreachable resources].

### Unique resource lookup

Sometimes, a resource within a subcollection has an identifier that is unique across parent collections. In this case,
it may be useful to allow retrieval of that resource without knowing which parent collection contains it. In such cases,
APIs **may** allow users to specify the wildcard collection ID `-` (the hyphen or dash character) to represent any
parent collection:

```http
GET /v1/publishers/-/books/{book_id}
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

## Further reading

- For partial failures due to unreachable resources, see [unreachable resources].

[unreachable resources]: ./unreachable-resources

[Resource Paths]: /paths#resource-hierarchy-and-nesting

[GET]: /get

## Changelog

* **2025-12-10**: Initial creation, adapted from [Google AIP-159][] and aep.dev [AEP-159][].

[Google AIP-159]: https://google.aip.dev/159

[AEP-159]: https://aep.dev/159
