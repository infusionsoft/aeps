# GET

In REST APIs, it is customary to make a `GET` request to fetch data. `GET`
requests are used to read either a single resource or a collection of
resources. As defined in [RFC 9110 Section 9.3.1], `GET` is the primary
mechanism for information retrieval in HTTP and should be [safe] and
[idempotent].

## Guidance

### When to use GET

Use `GET` for any operation that reads data without changing it. It is the
default method for retrieving resources and collections.

**Use `GET` when:**

- Retrieving a specific resource by its ID (e.g., "Fetch user 123").
- Listing resources in a collection (e.g., "List all books").
- Searching or filtering data where the query parameters fit within the URL
  length limit.
- The operation is read-only and safe to cache.

**Do NOT use `GET` when:**

- The operation modifies data (create, update, delete).
- The operation triggers a process or action (e.g., "Send email", "Reboot
  server").
- Sensitive data (like passwords or tokens) would be exposed in the URL query
  parameters.
- The request parameters are too large for a URL (see
  [GET with body](#get-with-body)).

### General requirements

- `GET` **must** be used to retrieve a representation of a resource or
  collection.
- `GET` requests **must not** have a request body payload.
  - If a `GET` request contains a body, the body **must** be ignored, and
    **must not** cause an error.
  - Be aware that some HTTP clients, proxies, and intermediaries may drop the
    request body or reject the request entirely.
  - If a request that meets the requirements to be a `GET` cannot be
    represented as a `GET`, see [GET with body](#get-with-body).
- `GET` requests **must** be [safe], meaning they **must not** modify server
  state or have side effects.
- `GET` requests **must** be [idempotent], meaning multiple identical requests
  **must** produce the same result.

### Caching

- `GET` requests **should** support HTTP caching mechanisms to improve
  performance and reduce server load.
- APIs **may** include appropriate cache control headers such as
  [Cache-Control], [ETag], and [Last-Modified].
- APIs **may** support conditional requests using [If-None-Match] or
  [If-Modified-Since] headers, returning [304 Not Modified] when appropriate.
  See AEP-154 for more details.

### GET with body

`GET` requests with request bodies violate HTTP semantics and **should** be
avoided. If you encounter URI length restrictions or similar constraints,
follow this decision tree:

1. **Reconsider your design**: Can the request be redesigned to reduce URI
   length? Consider whether the query complexity indicates a design issue.
2. **Use URL-encoded query parameters**: Provide request information via
   multiple query parameters, or encode it as a single structured query string
   parameter.
3. **Use `POST` as a fallback**: When URL encoding is not possible, use a
   `POST` request with a body payload.
   - This **must** be explicitly documented as a query operation, not a
     mutation.

**Note:** When using `POST` for queries with extensive parameters, keep
pagination parameters (e.g., `cursor`, `limit`) in the query string rather than
the request body. This allows pagination links to contain only the `cursor`,
which encodes page position and direction. The `cursor` may optionally include
a hash of the applied filters to validate consistency across paginated
requests.

## Further Reading

- [Standard Action: Fetch](/fetch)
- [Standard Action: List](/list)
- [AEP-154: Preconditions](/154) - Guidance on using ETags and conditional
  headers for concurrency control.

[RFC 9110 Section 9.3.1]:
  https://datatracker.ietf.org/doc/html/rfc9110#section-9.3.1
[safe]: /64#common-method-properties
[idempotent]: /64#common-method-properties
[Cache-Control]:
  https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Cache-Control
[ETag]:
  https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/ETag
[Last-Modified]:
  https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Last-Modified
[If-None-Match]:
  https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/If-None-Match
[If-Modified-Since]:
  https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/If-Modified-Since
[304 Not Modified]:
  https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/304

## Changelog

- **2026-02-09**: Move this from AEP-131 to AEP-65. Extract
  `Individual Resources` section to `Fetch` action (new AEP-131).Extract
  `Collection Resources` section to `List` action (new AEP-132).
- **2026-01-21**: Standardize HTTP status code references.
- **2025-11-12**: Initial AEP-131 for Thryv, adapted from [Google AIP-131][]
  and aep.dev [AEP-131][].

[Google AIP-131]: https://google.aip.dev/131
[AEP-131]: https://aep.dev/131
