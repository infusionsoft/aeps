# Status Codes

HTTP status codes indicate the outcome of an API request. This AEP provides guidance on which status codes to use and
how to document them.

## Guidance

* APIs **must** use official status codes only. They **must not** coin their own codes.
* APIs **must** use the most specific HTTP status code.
* APIs **must** use status codes appropriately. Meaning the status codes **must not** be misused.

APIs **must** document status codes in their OpenAPI specification. Documentation **should** include descriptions when
there are operation-specific details, such as:

* Specific conditions that trigger the code
* Additional context about what the error means for this operation
* Guidance on how to resolve the error

### Common status codes

The following list contains the most frequently used HTTP status codes in REST APIs. Each status code is marked with ✅
or ❌:

**✅ Document**: If the status code can be returned by the API, it **should** be documented in the API specification.

**❌ Do Not Document**: The status code has a well-understood standard meaning, so only document it if there are
operation-specific details you want to add.

#### Success codes (2xx)

##### **[200 OK](https://datatracker.ietf.org/doc/html/rfc9110#name-200-ok)** ✅

Request succeeded. This is the most general success response and should be used if the more specific codes below are
not applicable.

##### **[201 Created](https://datatracker.ietf.org/doc/html/rfc9110#name-201-created)** ✅

Resource successfully created.

##### **[202 Accepted](https://datatracker.ietf.org/doc/html/rfc9110#name-202-accepted)** ✅

Request accepted for processing but not yet complete. Used for asynchronous operations.

##### **[204 No Content](https://datatracker.ietf.org/doc/html/rfc9110#name-204-no-content)** ✅

Request succeeded with no response body.

#### Client error codes (4xx)

##### **[400 Bad Request](https://datatracker.ietf.org/doc/html/rfc9110#name-400-bad-request)** ✅

Request is malformed, structurally invalid, or fails validation (e.g., invalid JSON syntax, wrong data types, constraint
violations).

##### **[401 Unauthorized](https://datatracker.ietf.org/doc/html/rfc9110#name-401-unauthorized)** ❌

Authentication is required or has failed. The credentials are missing or invalid. As this can occur on almost any
endpoint, APIs **should not** document this code.

##### **[403 Forbidden](https://datatracker.ietf.org/doc/html/rfc9110#name-403-forbidden)** ❌

Client is authenticated but lacks permission to access the resource. As this can occur on almost any endpoint, APIs
**should not** document this code.

##### **[404 Not Found](https://datatracker.ietf.org/doc/html/rfc9110#name-404-not-found)** ❌

Requested resource does not exist. As this has a well-understood meaning, APIs **should not** document this code.

##### **[405 Method Not Allowed](https://datatracker.ietf.org/doc/html/rfc9110#name-405-method-not-allowed)** ✅

The HTTP method is not supported for the requested resource. This indicates a deliberate design decision: the resource
exists, and the method is valid, but they are incompatible by design (e.g., attempting to `DELETE` a read-only
resource).

##### **[409 Conflict](https://datatracker.ietf.org/doc/html/rfc9110#name-409-conflict)** ✅

Request conflicts with current server state (e.g., duplicate resource creation, concurrent modification).

##### **[410 Gone](https://datatracker.ietf.org/doc/html/rfc9110#name-410-gone)** ❌

The requested resource is permanently `DELETE`d and will not be available again. APIs **should not** document this code
unless there is a specific need to distinguish permanent deletion from standard `404 Not Found` responses.

##### **[415 Unsupported Media Type](https://datatracker.ietf.org/doc/html/rfc9110#name-415-unsupported-media-type)** ❌

The request payload format is not supported by the server (e.g., client sent XML when only JSON is accepted). As this
has a well-understood meaning, APIs **should not** document this code.

##### **[422 Unprocessable Entity](https://datatracker.ietf.org/doc/html/rfc9110#name-422-unprocessable-content)** ✅

Request is well-formed but cannot be processed due to semantic errors (e.g., invalid state transition, attempting to
purchase an out-of-stock item).

##### **[429 Too Many Requests](https://datatracker.ietf.org/doc/html/rfc6585#name-429-too-many-requests)** ❌

Client has exceeded rate limits. As this can occur on almost any endpoint, APIs **should not** document this code.

#### Server error codes (5xx)

##### **[500 Internal Server Error](https://datatracker.ietf.org/doc/html/rfc9110#name-500-internal-server-error)** ❌

Unexpected server error occurred. As this can occur on almost any endpoint, APIs **should not** document this code.

##### **[501 Not Implemented](https://datatracker.ietf.org/doc/html/rfc9110#name-501-not-implemented)** ✅

Server does not support the functionality required to fulfill the request. This applies when the server does not
recognize the HTTP method, or recognizes it but has not implemented support. This code **may** be documented on planned
endpoints to indicate they are not yet available.

##### **[503 Service Unavailable](https://datatracker.ietf.org/doc/html/rfc9110#name-503-service-unavailable)** ❌

Server is temporarily unable to handle the request (e.g., maintenance, overload). As this can occur on almost any
endpoint, APIs **should not** document this code.

### Other status codes

The common status codes listed above are not exhaustive. APIs **may** use any _standard_ HTTP status code as long as it
is appropriate for the situation. Apply the same documentation principles based on whether the status code has
operation-specific meaning or a well-understood standard meaning.

APIs **must not** invent custom status codes. Only use status codes defined in the HTTP specifications.

For a complete list of standard HTTP status codes and in-depth explanations,
see [MDN's HTTP Status Code Reference](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status).

## Further Reading

- [RFC 9110: HTTP Semantics](https://datatracker.ietf.org/doc/html/rfc9110#name-status-codes)
- [MDN HTTP Status Codes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)

## Changelog

**2026-01-12**: Initial creation.
