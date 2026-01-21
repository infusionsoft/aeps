# GET

In REST APIs, it is customary to make a `GET` request to a resource's URI (for example,
`/publishers/{publisher_id}/books/{book_id}`) in order to retrieve that resource. `GET` requests are used to read either
a single resource or a collection of resources. As defined in [RFC 9110 Section 9.3.1], `GET` is the primary mechanism
for information retrieval in HTTP and should be [safe] and [idempotent].

## Guidance

### When to use GET

Use `GET` for any operation that reads data without changing it. It is the default method for retrieving resources and
collections.

**Use `GET` when:**

* Retrieving a specific resource by its ID (e.g., "Get user 123").
* Listing resources in a collection (e.g., "List all books").
* Searching or filtering data where the query parameters fit within the URL length limit.
* The operation is read-only and safe to cache.

**Do NOT use `GET` when:**

* The operation modifies data (create, update, delete).
* The operation triggers a process or action (e.g., "Send email", "Reboot server").
* Sensitive data (like passwords or tokens) would be exposed in the URL query parameters.
* The request parameters are too large for a URL (see [GET with body](#get-with-body)).

### General requirements

* `GET` **must** be used to retrieve a representation of a resource.
* APIs **must** provide a `GET` method for resources unless there is a compelling reason not to do so. The purpose of
  the `GET` method is to retrieve and return data about the resource.
* `GET` requests **must not** have a request body payload.
    * If a `GET` request contains a body, the body **must** be ignored, and **must not** cause an error.
    * Be aware that some HTTP clients, proxies, and intermediaries may drop the request body or reject the request
      entirely.
    * If a request that meets the requirements to be a `GET` cannot be represented as a `GET`,
      see [GET with body](#get-with-body).
* `GET` requests **must** be [safe], meaning they **must not** modify server state or have side effects.
* `GET` requests **must** be [idempotent], meaning multiple identical requests **must** produce the same result.
* Some resources take longer to be retrieved than is reasonable for a regular API request. In this situation, the
  API **should** use a [long-running operation].

### Individual Resources

`GET` requests for individual resources:

* **must** use the resource's canonical [URI path] (e.g., `/publishers/{publisher_id}/books/{book_id}`).
* **must** return a [200 OK] with the resource representation in the response body when the resource exists.
* **must** return a [404 Not Found] if the resource does not exist.
    * If the resource previously existed and has since been deleted (e.g., soft-deleted), the server **may** instead
      respond with [410 Gone].
* **may** support field masks or sparse fieldsets to allow clients to specify which fields they want returned, reducing
  payload size and improving performance. See AEP-157 on partial responses for more details.

### Collection Resources

`GET` requests for collection resources:

* **must** use the collection's [URI path] (e.g., `/publishers/{publisher_id}/books`).
* **must** return a `[200 OK] when resources are successfully retrieved.
    * The response body **must** be a wrapper object containing the list of resources, not a raw JSON array.
    * These results **must** be [paginated].
* **must** return a [200 OK] with an empty array (inside the wrapper object) if the collection exists but contains no
  resources.
* **should** return a [404 Not Found] if the parent resource does not exist (e.g., requesting
  `/publishers/{invalid_id}/books` when the publisher doesn't exist).
* **should** implement sorting and [filtering] mechanisms to allow clients to sort and narrow results.
    * The filters **must** follow the guidelines on [query parameters].
* **must** ensure a deterministic default sort order to guarantee stable [pagination].

### Caching

* `GET` requests **should** support HTTP caching mechanisms to improve performance and reduce server load.
* APIs **may** include appropriate cache control headers such as [Cache-Control], [ETag], and [Last-Modified].
* APIs **may** support conditional requests using [If-None-Match] or [If-Modified-Since] headers,
  returning [304 Not Modified] when appropriate.

### GET with body

`GET` requests with request bodies violate HTTP semantics and **should** be avoided. If you encounter URI length
restrictions or similar constraints, follow this decision tree:

1. **Reconsider your design**: Can the request be redesigned to reduce URI length? Consider whether the query complexity
   indicates a design issue.
2. **Use URL-encoded query parameters**: Provide request information via multiple query parameters, or encode it as a
   single structured query string parameter.
3. **Use `POST` as a fallback**: When URL encoding is not possible, use a `POST` request with a body payload.
    * This **must** be explicitly documented as a query operation, not a mutation.

**Note:** When using `POST` for queries with extensive parameters, keep pagination parameters (e.g., `cursor`, `limit`)
in the query string rather than the request body. This allows pagination links to contain only the `cursor`, which
encodes page position and direction. The `cursor` may optionally include a hash of the applied filters to validate
consistency across paginated requests.

[RFC 9110 Section 9.3.1]: https://datatracker.ietf.org/doc/html/rfc9110#section-9.3.1

[safe]: /130#common-method-properties

[idempotent]: /130#common-method-properties

[long-running operation]: /long-running-operations

[URI path]: /paths

[paginated]: /pagination

[pagination]: /pagination

[query parameters]: /query-parameters

[Cache-Control]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Cache-Control

[ETag]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/ETag

[Last-Modified]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Last-Modified

[If-None-Match]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/If-None-Match

[If-Modified-Since]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/If-Modified-Since

[304 Not Modified]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/304

[filtering]: /filtering

[200 OK]: /63#200-ok

[404 Not Found]: /63#404-not-found

[410 Gone]: /63#410-gone

## Changelog

* **2026-01-21**: Standardize HTTP status code references.
* **2025-11-12**: Initial AEP-131 for Thryv, adapted from [Google AIP-131][] and aep.dev [AEP-131][].

[Google AIP-131]: https://google.aip.dev/131

[AEP-131]: https://aep.dev/131
