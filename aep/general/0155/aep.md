# Idempotency-Key

It is sometimes useful for an API to have a unique, customer-provided
identifier for particular requests. This can be useful for several purposes,
such as:

- De-duplicating requests from parallel processes
- Ensuring the safety of retries
- Auditing

The purpose of idempotency keys is to provide idempotency guarantees: allowing
the same request to be issued more than once without subsequent calls having
any effect. In the event of a network failure, the client can retry the
request, and the server can detect duplication and ensure that the request is
only processed once.

## Guidance

APIs **may** support the experimental [Idempotency-Key] header to uniquely
identify particular requests. API servers **must not** execute requests with
the same `Idempotency-Key` more than once.

Idempotency keys are for state-changing operations. [POST] and [PATCH] requests are the primary use case for idempotency
keys, since they are non-idempotent by their HTTP specs. [GET] requests are safe methods and **must not** accept
idempotency keys. [PUT] and [DELETE] are idempotent by the HTTP specification, but **may** accept idempotency keys if
additional guarantees against duplicate processing are needed (e.g., preventing double charges in payment systems).

- Idempotency keys **must** be UUIDs (either v4 or v7).
    - The format restrictions for idempotency keys **must** be documented.
- Keys **must** be scoped to the combination of endpoint + HTTP method + resource. A key used for `POST /orders`
  **must** be different from a key for `POST /payments`.
- The idempotency key **must** be provided in a header called `Idempotency-Key` (and it **must not** be a field in the
  resource).
- Providing an idempotency key **must** guarantee idempotency.
    - If a duplicate request is detected, the server **must** return one of:
        - A response equivalent to the response for the previously successful
          request, because the client most likely did not receive the previous
          response. The response **must** contain the same status code and response body as the original response.
        - An error, see [Errors](#errors) below.
    - APIs **should** honor idempotency keys for _at least_ an hour.
- Idempotency keys **should** be optional.
- Idempotency keys **must not** be used for read-only operations.

### Errors

A server **should** provide error responses in the following cases:

* `400 Bad Request`: The key is not a valid UUID; or the header is omitted for an endpoint that is documented as
  requiring it.
* `409 Conflict`: A request with the same key is currently/still being processed, or returning an equivalent response is
  not possible (see example below).
* `422 Unprocessable Content`: The key is already being used for a different request payload.

In the case of a `409 Conflict` response, clients will need to wait before retrying. For all the other errors, clients
will need to amend the requests before resending.

APIs **should** also respond with an error if returning an equivalent response is not possible. For example, if a
resource was created, then deleted, and then a duplicate request to create the resource is received, the server **should
** return `409 Conflict` if returning the previously created resource is not possible. The error response **should**
explain that the idempotency key was previously used, but the resource state has changed in a way that makes replay
impossible.

## Further reading

- Active draft RFC to standardize the Idempotency-Key
  header: [The Idempotency-Key HTTP Header Field](https://datatracker.ietf.org/doc/draft-ietf-httpapi-idempotency-key-header/)

## Rationale

### Using an experimental header

Although the `Idempotency-Key` header is defined in a draft RFC, however the specification is mature and has achieved
broad industry adoption. The core semantics have remained stable across multiple revisions, and major API providers
already implement this header. Using the draft standard provides better interoperability with existing tooling and
positions our APIs to adopt the finalized standard with minimal changes once ratified. The benefits of standardization
outweigh the low risk of minor adjustments during finalization.

### Using UUIDs for request identification

While the [Idempotency-Key] header definition says the server defines the key format, our org chooses to use UUIDs. When
a value is required to be unique, leaving the format open-ended can lead to API consumers incorrectly providing a
duplicate identifier. As such, standardizing on a universally unique identifier drastically reduces the chance for
collisions when done correctly. It also removes the burden from developers to design their own identifier
generation strategy and ensures consistent behavior across all APIs within the organization.

## Changelog

* **2025-12-23**: Initial creation, adapted from [Google AIP-155][] and aep.dev [AEP-155][].

[Google AIP-155]: https://google.aip.dev/155

[AEP-155]: https://aep.dev/155

[Idempotency-Key]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Idempotency-Key

[GET]: /get

[POST]: /post

[PUT]: /put

[PATCH]: /patch

[DELETE]: /delete
