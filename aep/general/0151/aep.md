# Long-running operations

Occasionally, a service may need to expose an operation that takes a
significant amount of time to complete. In these situations, it is often a poor
user experience to simply block while the task runs; rather, it is better to
return some kind of promise to the user, and allow the user to check back in
later.

The long-running request pattern is roughly analogous to a `Future` in [Python]
or [Java], or a [Node.js Promise][]. Essentially, the user is given a token that
can be used to track progress and retrieve the result.

## Guidance

Operations that might take a significant amount of time to complete:

* **must** return `202 Accepted` on successful submission to indicate the request has been accepted for processing.
* **must** return an `Operation` object (see [Interface Definitions](#interface-definitions)) in the response body.
* **must** match other AEP guidance that would apply to the method otherwise.
* **may** include a [Location] header pointing to the operation status endpoint.

**Note:** User expectations can vary on what is considered "a significant
amount of time" depending on what work is being done. A good rule of thumb is
10 seconds.

Example:

```http request
POST /documents/123/publications

202 Accepted
Location: /operations/op_abc123xyz
Content-Type: application/json

{
  "id": "op_abc123xyz",
  "status": "pending",
  "metadata": {
    "created_at": "2025-12-02T10:30:00Z"
  }
}
```

### Querying an operation

The service **must** provide a `GET /operations/{operation_id}` endpoint to query the status of the operation. This
endpoint:

* **must** return `200 OK` with an `Operation` object (see [Interface Definitions](#interface-definitions)) when the
  operation exists.
* **must** return `404 Not Found` when the operation does not exist (e.g., expired or invalid ID).

The service **should** provide a `GET /operations` endpoint to list operations. This endpoint:

* **may** support filtering.
* **must** follow standard [pagination] guidelines if implemented.

The `Operation` object returned:

* **must** include the current `status` of the operation.
* **should** include progress information in the `metadata` field when available (e.g., percentage complete, items
  processed).
* **must** include the operation result in the `result` field when status is succeeded.
* **must** include error details in the `errors` array when status is failed.

APIs **may** include additional status values if needed, but **must** document them clearly.

### Cancellation

APIs **may** support cancelling long-running operations when feasible. Cancellation:

* **must** be implemented via `POST /operations/{operation_id}:cancel`.
* **must** return `200 OK` with the updated `Operation` object if the operation was successfully canceled.
* **must** return `404 Not Found` if the operation does not exist.
* may not take effect immediately; the operation `status` **should** transition to canceled once cancellation is
  complete.

Not all operations can be safely canceled. APIs must document which operations
support cancellation.

### Parallel requests

A resource **may** accept multiple requests that will work on it in parallel
but is not obligated to do so:

* Resources that accept multiple parallel requests **may** place them in a
  queue rather than work on the requests simultaneously.
* A resource that does not permit multiple requests in parallel (denying any
  new request until the one that is in progress finishes) **must** return
  `409 Conflict` if a user attempts a parallel request, and include an
  error message explaining the situation.

### Expiration

APIs **may** allow their operation resources to expire after sufficient time
has elapsed after the request completed.

* Expired operations **should** return `404 Not Found` or `410 Gone` when queried.
* The expiration policy **must** be documented.
* APIs **should** retain operation records long enough for clients to retrieve results, even with retry delays.

**Note:** A good rule of thumb for operation expiry is 30 days.

### Errors

Errors that prevent a long-running request from _starting_ **must** return an
[error response][aep-193], similar to any other method.

Errors that occur _during_ the operation's execution **must** be reflected in the `Operation` object with
`status: "failed"` and detailed error information in the `errors` array.

## Interface Definitions

{% tab proto %}

{% tab oas %}

```yaml
Operation:
  type: object
  description: Represents a long-running operation.
  required:
    - id
    - status
    - created_at
  properties:
    id:
      type: string
      description: The unique identifier for this operation.
    status:
      type: string
      enum:
        - pending
        - running
        - succeeded
        - failed
        - cancelled
      description: The current status of the operation.
    metadata:
      type: object
      description: Service-specific metadata about the operation, such as progress information.
      additionalProperties: true
    result:
      type: object
      description: The result of the operation when status is 'succeeded'.
      additionalProperties: true
    errors:
      type: array
      description: Error details when status is 'failed'.
      items:
        type: object
        properties:
          code:
            type: string
          message:
            type: string
```

* The response body schema **must** be an `Operation` object as described above.
* The response body schema **may** contain an object property named `metadata` to hold service-specific metadata
  associated with the operation, for example, progress information and common metadata such as create time. The service
  **should** define the contents of the metadata object in a separate schema, which **should** specify
  `additionalProperties: true` to allow for future extensibility.
* The `result` property must be a schema that defines the success response for the operation. For operations that
  typically return `204 No Content` (such as delete), `result` **should** be defined as an empty object schema. For
  operations that typically return a response body, `result` **should** contain a representation of the created or
  modified resource, or a summary of the operation's outcome.

{% endtabs %}

[location]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Location

[node.js promise]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_promises

[Python]: https://docs.python.org/3/library/concurrent.futures.html#concurrent.futures.Future

[Java]: https://www.baeldung.com/java-future

[pagination]: /pagination

## Changelog

* **2025-12-10**: Initial creation, adapted from [Google AIP-151][] and aep.dev [AEP-151][].

[Google AIP-151]: https://google.aip.dev/151

[AEP-151]: https://aep.dev/151
