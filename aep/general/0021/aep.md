# Responses

HTTP responses are the server's reply to a client's request, completing the request-response cycle that forms the
foundation of web API communication. Every HTTP request results in a response, which contains the outcome of the
requested operation along with any data or metadata the server needs to communicate back to the client. This AEP offers
an educational overview of the HTTP response structure and how its components work together to communicate results
effectively.

Understanding HTTP responses is essential for both consuming and building APIs. Whether you're handling API responses in
your application or designing the responses your API returns, familiarity with response structure will help you
implement proper error handling, process data correctly, and build more robust integrations.

## Anatomy of a Response

An HTTP response looks like this:

```http
201 Created
Content-Type: application/json
Location: https://mycompany.com/api/v1/users/12345
Date: Fri, 16 Jan 2026 10:30:00 GMT

{
  "id": "12345",
  "name": "Victor Hugo",
  "email": "victor@example.com",
  "createdTime": "2026-01-16T10:30:00Z"
}
```

It has three primary parts:

* **[Status Line](#status-line)**: Indicates the outcome of the request (success, fail, etc.).
* **[HTTP Headers](#http-headers)**: Metadata providing context for the response.
* **[Response Body](#response-body)**: The data payload (optional).

{% image 'response.png', 'Anatomy of HTTP Response' %}

### Status Line

The status line is the first line of an HTTP response and communicates the outcome of the request. It consists of two
parts: a **status code** and a **status message** (also called the reason phrase).

For example, in `201 Created`:

* `201` is the status code
* `Created` is the status message

The **status code** is a three-digit number that indicates the outcome of the request. Status codes are grouped into
five categories, each representing a different class of response:

* `1xx` (Informational): The request was received and is being processed
* `2xx` (Success): The request was successfully received, understood, and accepted
* `3xx` (Redirection): Further action is needed to complete the request
* `4xx` (Client Error): The request contains an error or cannot be fulfilled
* `5xx` (Server Error): The server failed to fulfill a valid request

The **status message** is a human-readable text description that accompanies the status code. It provides a brief
explanation of what the status code means, such as "OK", "Created", "Not Found", or "Internal Server Error". While
status messages are part of the [HTTP specification], they are primarily informational. Clients **must** always use the
numeric status code for programmatic decision-making, as status messages can vary between servers and are not
standardized beyond common conventions.

See AEP-23 for guidance on common HTTP status codes and when to use them. For an exhaustive reference of all possible
status codes, see the [MDN HTTP Response Codes] documentation. For detailed guidance on how to structure error
information when a `4xx` or `5xx` occurs, see AEP-193.

### HTTP Headers

HTTP headers in responses serve the same purpose as request headers: they provide metadata about the response. Response
headers communicate information such as the content type being returned, caching instructions, server information, and
any additional context the client needs to properly interpret the response.

Headers are organized as key-value pairs, with standardized header names defined in the [HTTP specification] alongside
custom headers that APIs may define. Common response headers include:

* `Content-Type`: Specifies the media type of the response body (e.g., `application/json`)
* `Content-Length`: Indicates the size of the response body in bytes
* `Date`: The date and time at which the message originated
* `Location`: Provides the URI of a newly created resource (typically with `201 Created` responses)
* `Cache-Control`: Specifies caching directives for the response
* `ETag`: Provides a version identifier for the resource, useful for caching and conditional requests

Headers are case-insensitive, according to the [HTTP specification], though conventional formatting uses `Title-Case` (
e.g., `Content-Type` rather than `content-type` or `CONTENT-TYPE`).

For a comprehensive reference and overview of HTTP headers, see the [MDN HTTP Headers] documentation. See AEP-148 for
custom headers specific to our company's APIs.

### Response Body

The response body contains the data payload being returned by the server. This is where the server sends the requested
resource, the representation of a newly created resource, error details, or any other structured data the client needs.

Not all responses include a body. For example, `204 No Content` responses explicitly indicate there is no response body.
Some operations may return an empty response body after successfully completing the operation. The presence and content
of a response body depends on the status code, HTTP method, and the nature of the operation.

For detailed guidance on content negotiation, media types, and how clients should interpret the response body, see
AEP-105. For specific guidance on structuring JSON payloads, see AEP-107. For guidance on error response formats, see
AEP-193.

[HTTP specification]: https://datatracker.ietf.org/doc/html/rfc9110

[MDN HTTP Headers]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers

[MDN HTTP Response Codes]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status

## Changelog

* **2026-01-16**: Initial creation.
