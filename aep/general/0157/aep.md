# Partial responses

Sometimes, a resource can be either large or expensive to compute, and the API
needs to give the user control over which fields it sends back. Requesting fewer fields may also grant a performance
boost.

## Guidance

APIs **may** support partial responses using field masks to grant users fine-grained control over which fields are
returned.

If an API supports partial responses, it **must** use a query parameter named `read_mask`.

- The `read_mask` parameter **must** be optional.
    - If `read_mask` is omitted, it **must** default to return all fields, unless otherwise documented.
- An API **may** support read masks on nested fields within arrays, but is not obligated to do so.
    - For example, given a book resource with an `authors` array, a read mask of `title,authors.name` would return only
      the book's title and each author's name (filtering out other author fields). If an API does not support this, it
      **must** treat array fields as all-or-nothing:
        - either the entire array with all nested fields is returned, or
        - the array is omitted entirely.
- `read_mask` **must** follow the guidelines in AEP-106 on query parameters.

**Note:** Changing the default value of `read_mask` is a breaking change.

{% tab proto %}

{% tab oas %}

```yaml
parameters:
  - in: query
    name: read_mask
    schema:
      type: string
    description: >-
      A comma-separated list of fields to include in the response. If not
      provided, all fields are returned. Nested fields can be specified using
      dot notation. For example: `title,author.name`.
```

{% endtabs %}

### Error handling

If a client specifies an invalid field name in the `read_mask` parameter, the API **must** return a `400 Bad Request`
error response.

- The error response **should** include a clear message indicating which field(s) are invalid. It **should** specify the
  exact field path that caused the error when possible (e.g., `"Invalid field: 'author.middleName'"` rather than just
  `"Invalid field"`).
- An API **should not** choose to ignore unrecognized fields and return the recognized subset instead of returning an
  error.
- If the `read_mask` syntax itself is malformed (e.g., invalid characters, improper nesting), the API **must** return a
  `400 Bad Request` error with a message describing the syntax issue.

## Changelog

* **2025-12-23**: Initial creation, adapted from [Google AIP-157][] and aep.dev [AEP-157][].

[Google AIP-157]: https://google.aip.dev/157

[AEP-157]: https://aep.dev/157
