# Errors

Effective error communication is an important part of designing simple and
intuitive APIs. Services returning standardized error responses enable API
clients to construct centralized common error handling logic. This common logic
simplifies API client applications and eliminates the need for cumbersome
custom error handling code.

## Guidance

Services **must** clearly distinguish successful responses from error
responses.

The structure of the error response **must** be consistent across all APIs of
the service. You **must** use the error response structure below, which comes
from the Problem Details for HTTP APIs [RFC 9457].

The media-type for an error response **must** be `application/problem+json`.

### Structure

An error response **should** contain the following fields:

| Name                        | Type      | Required | Description                                                                                                                                                                                        |
| --------------------------- | --------- | :------: | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [type](#type)               | `string`  |    Y     | A URI reference that identifies the problem type. If the type URI is a locator (has `http`/`https` scheme), dereferencing it **should** provide human-readable documentation for the problem type. |
| [status](#status)           | `integer` |          | The HTTP status code that best describes the type of problem detected.                                                                                                                             |
| [title](#title-and-detail)  | `string`  |          | A human-readable general description of the problem. It **must not** include information about a specific occurrence; that should be part of `detail` or extension members.                        |
| [detail](#title-and-detail) | `string`  |          | A human-readable explanation specific to _this_ occurrence of the problem.                                                                                                                         |
| [instance](#instance)       | `string`  |          | A unique identifier for _this_ specific occurrence of the problem.                                                                                                                                 |

An error response **may** contain additional fields appropriate for a specific
error type. See [Extension Members](#extension-members) below for details.

All human-readable error details returned by the service **must** use the same
language.

A JSON representation of an error response might look like the following:

```json
{
  "type": "/problems/rate-limit-exceeded",
  "status": 429,
  "title": "Rate Limit Exceeded",
  "detail": "You have exceeded the rate limit of 100 requests per minute. Please retry after 42 seconds.",
  "instance": "/errors/unique-id-abc123"
}
```

#### Status

If present, the `status` field **must** contain the numeric HTTP status code
for this error (e.g., `404`, `400`, `500`), and it **must** use the same status
code as the actual HTTP response. This field is purely for the consumer's
convenience; it allows them to see the status code directly in the error
object.

#### Title and Detail

The `title` **should** be the same for all occurrences of the same problem
type. The `detail` **should** describe _this specific_ occurrence; meaning it
will most likely change between occurrences of the same problem.

The error `title` and `detail` fields **should** help a reasonably technical
user _understand_ and _resolve_ the issue, and **should not** assume that the
user is an expert in your particular API. Additionally, the error `title` and
`detail` **must not** assume that the user will know anything about its
underlying implementation.

The error `detail` **should** be brief but actionable. Any extra information
**should** be provided in additional properties. If even more information is
necessary, you **should** provide a link where a reader can get more
information or ask questions to help resolve the issue.

The error `detail` field

- **should** describe _this specific instance_ of the error.
- **should** be a developer-facing, human-readable "debug message".
- **should** both explain the error and offer an actionable resolution to it.
- value **may** significantly change over time for the same error and **should
  not** be string-matched by any clients to determine the error.

#### Type

The `type` field is a URI that serves as a _permanent_ identifier for that
category of problem. It may be one of:

- `about:blank` (default)
- An identifier in URI format that doesn't resolve
- A full URL that leads to documentation

See the [Common Error Types](#common-error-types) section for guidance on
common types.

##### `about:blank`

This indicates that the HTTP status code itself serves as the error category;
it literally means "see the HTTP code". This **should** be used for errors that
are self-explanatory and map directly to standard HTTP codes (e.g.,
`401 Unauthorized`, `403 Forbidden`, `404 Not Found`).

When using `about:blank`, you **must** rely on the `title` and `detail` fields
to convey necessary information. The `detail` field is _especially important_
here since it becomes the primary way to communicate what went wrong in _this
specific_ occurrence.

##### URI identifiers

Use this method for domain-specific errors. These are identifiers formatted as
URIs that don't resolve (e.g., `/problems/constraint-violation`). The
identifier **must** be formatted as a URI resource path in the format
`/problems/specific-problem`. These identifiers **must** be stable; meaning
they **must not** change over time. This approach is recommended because:

- All important parts of the API **must** be documented using OpenAPI anyway
- Full URLs tend to be fragile and not very stable over longer periods due to
  organizational and documentation changes
- Descriptions might easily get out of sync with actual behavior

Examples:

```
/problems/constraint-violation
/problems/out-of-stock
/problems/insufficient-funds
```

##### Full URLs

If there is a benefit to providing documentation beyond what OpenAPI provides,
then a full URL **may** be used. In this case, the URL **should** resolve to
human-readable documentation that explains what this error means, why it
occurs, how to fix it, and what the client should do in response.

Examples (you can actually visit these and read their docs):

- https://opensource.zalando.com/problem/constraint-violation
- https://problems-registry.smartbear.com/already-exists

#### Instance

The `instance` field is a URI field points to information about this specific
error occurrence. It's most useful when you have customer support scenarios
where users need to report errors, and you need a way to look up exactly what
happened. The instance field does _not_ point to the resource that was
requested. Instead, it identifies _this particular error event_.

The instance URI could be something like:

- `/errors/2024-02-03/req-abc123`: a reference to this request in your logs
- `urn:uuid:f81d4fae-7dec-11d0-a765-00a0c91e6bf6`: just a unique identifier
  (doesn't have to be dereferenceable)
- `https://errors.example.com/incidents/a3f5b2c1`: a link to this specific
  error in your error tracking system

**Note:** In practice, many APIs omit `instance` because they don't have error
tracking URLs to share.

### Extension Members

Problem type definitions **may** extend the problem details object with
additional members that are specific to that problem type.

For example, this defines two such extensions - `balance` and `accounts` to
convey additional, problem-specific information.

```json
{
  "type": "https://example.com/out-of-credit",
  "title": "You do not have enough credit.",
  "detail": "Your current balance is 30, but that costs 50.",
  "instance": "/account/12345/msgs/abc",
  "balance": 30,
  "accounts": ["/account/12345", "/account/67890"]
}
```

Clients consuming problem details **must** ignore any extension members that
they don't recognize. This allows problem types to evolve and include
additional information in the future. Clients **should** avoid relying on
extension members in their core error handling logic, as these members may
change over time.

#### Validation Errors

Validation errors **should** use the `violations` extension member. This
extension **must** be an array that describes the details of each validation
error. Each member **must** be an object containing:

- `field`: indicates which field violated a constraint
- `message`: describes the issue with that field

For example:

```json
{
  "type": "https://zalando.github.io/problem/constraint-violation",
  "title": "Constraint Violation",
  "status": 400,
  "violations": [
    {
      "field": "email",
      "message": "must be a valid email address"
    },
    {
      "field": "givenName",
      "message": "is required"
    },
    {
      "field": "age",
      "message": "must be a positive integer"
    },
    {
      "field": "profile.color",
      "message": "must be 'green', 'red' or 'blue'"
    }
  ]
}
```

#### Dynamic variables

The best, actionable error detail includes dynamic segments. These variable
parts of the message are specific to a particular request. Consider the
following example:

> The book "The Great Gatsby" is unavailable at the library "Garfield East". It
> is expected to be available again on 2199-05-13.

The preceding error detail is made actionable by the context, both that
originates from the request, the title of the Book and the name of the Library,
and by the information that is known only by the service, i.e. the expected
return date of the Book.

All dynamic variables found in error `detail` **must** also be present as
additional properties of the error response. These variables **should** be in a
field called `parameters`.

```json
{
  "type": "/problems/resource-unavailable",
  "status": 409,
  "title": "Resource Unavailable",
  "detail": "The book \"The Great Gatsby\" is unavailable at the library \"Garfield East\". It is expected to be available again on 2199-05-13.",
  "parameters": {
    "bookTitle": "The Great Gatsby",
    "library": "Garfield East",
    "expectedReturnDate": "2199-05-13"
  }
}
```

Once present for a particular error type, additional properties **must**
continue to be included in the error response to be backwards compatible, even
if the value for a particular property is empty.

**Note:** Using a `parameters` field is recommended for better organization.
However, different [RFC 9457] libraries implement support for extension members
differently. For example, Micronaut's library adds fields within a `parameters`
field, while Spring Boot's library adds them as top-level fields. Depending on
your library of choice, it may require customization to support `parameters`.
If this is undesirable, extension members **may** be added as top-level fields
instead.

#### Localization

The `title` and `detail` fields **should** be presented in English (or the
service's primary language).

**Server-side localization:** If the service supports multiple languages, a
localized `detail` **may** be included as an extension named `localizedDetail`.
The service **should** determine the language based on the [Accept-Language]
header.

**Client-side localization:** For services that expect clients to handle their
own localization, [dynamic variables](#dynamic-variables) **should** be
included in the `parameters` extension member. This allows clients to construct
localized messages using their own i18n frameworks while ensuring all necessary
data is available.

Services **may** support both approaches to accommodate different client
capabilities.

### Common Error Types

The IANA maintains a
[registry of standard problem types](https://www.iana.org/assignments/http-problem-types/http-problem-types.xhtml).
If a problem type exists in the IANA registry that fits your use case, you
**should** use it instead of defining your own.

For problem types not covered by the IANA registry, the following are
recommended values for common scenarios:

| Type URI                             | Title                    | Status |
| ------------------------------------ | ------------------------ | ------ |
| `/problems/constraint-violation`     | Constraint Violation     | `400`  |
| `/problems/business-rule-violation`  | Business Rule Violation  | `422`  |
| `/problems/already-exists`           | Already Exists           | `409`  |
| `/problems/invalid-state-transition` | Invalid State Transition | `409`  |
| `/problems/resource-unavailable`     | Resource Unavailable     | `409`  |
| `/problems/rate-limit-exceeded`      | Rate Limit Exceeded      | `429`  |
| `/problems/quota-exceeded`           | Quota Exceeded           | `429`  |
| `about:blank`                        | Not Found                | `404`  |
| `about:blank`                        | Unauthorized             | `401`  |
| `about:blank`                        | Forbidden                | `403`  |
| `about:blank`                        | Service Unavailable      | `503`  |
| `about:blank`                        | Server Error             | `500`  |

These are examples and **should** be adapted to fit your API's specific needs.
The important principle is that error types **must** be stable identifiers that
categorize errors consistently.

**Important:** As mentioned above, the `detail` field **should** always contain
information specific to _this_ occurrence of the error (e.g.,
`An account with ID 'abc123' already exists`). This is _especially important_
when using `about:blank`, since the `detail` field becomes the primary way to
communicate what went wrong (e.g.,
`Account with ID 'abc123' could not be found`).

### Multiple errors

When an API encounters multiple problems that do not share the same type, the
most relevant or urgent problem **should** be represented in the response.
While it is possible to create generic "batch" problem types that convey
multiple, disparate types, they do not map well into HTTP semantics.

### Partial errors

APIs **should not** support partial errors. Partial errors add significant
complexity for users, because they usually sidestep the use of error codes, or
move those error codes into the response message, where the user must write
specialized error handling logic to address the problem.

However, occasionally partial errors are necessary, particularly in bulk
operations where it would be hostile to users to fail an entire large request
because of a problem with a single entry.

Methods that require partial errors **should** use [long-running operations][],
and the method **should** put partial failure information in the metadata
message. The errors themselves **must** still be represented as an error object
as described in this AEP.

## Interface Definitions

{% tab proto %}

{% tab oas %}

{% sample 'errors.oas.yaml', '$.components.schemas' %}

{% endtabs %}

## Rationale

### Why RFC 9457?

[RFC 9457] provides a standardized, machine-readable format for error
responses. Before this standard, every API invented its own error format,
forcing clients to write custom error handling logic for each API they
consumed. By adopting RFC 9457, clients can use standard libraries to parse
errors across different APIs, error responses become more predictable and
consistent, and tooling can understand errors without custom configuration. The
alternative, inventing our own error format, would provide no benefits while
creating unnecessary friction for API consumers.

### Why the `violations` extension?

Validation errors are fundamentally different from other errors because they
typically involve multiple fields, each with its own specific issue. The
`violations` array provides a structured way to communicate which field(s)
failed validation, what the specific issue was with each field, and supports
nested fields like `profile.color`. This allows clients to display
field-specific error messages in forms, highlight invalid fields in the UI, and
programmatically retry with corrections. Additionally, this structure is the
default in Micronaut's RFC 9457 implementation.

### Why the `parameters` extension?

The `parameters` field serves two critical purposes: machine-readability and
maintainability. When error details contain dynamic values like IDs, counts, or
dates, clients need access to those values in a structured format for logging,
monitoring, programmatic error handling, client-side localization, etc. By
explicitly declaring which values are dynamic, we make it clear what data
changes between error occurrences and enable clients to extract specific values
without parsing natural language. Without `parameters`, clients would need to
parse the `detail` string to extract values, which is fragile and breaks when
message wording changes. While RFC 9457 allows extension members at the top
level, grouping them under `parameters` provides better organization and
clearly distinguishes them from standard problem details fields, though this
may require customization for some libraries like Spring Boot.

### Why discourage full URLs for `type`?

While RFC 9457 allows `type` to be a full URL pointing to documentation, we
recommend against this because URLs are fragile and change when organizations
reorganize, documentation moves, or domains change. Keeping documentation URLs
in sync with actual API behavior requires ongoing effort, and documentation can
drift out of sync or become outdated. OpenAPI specifications already document
error responses, including what errors mean and when they occur, so a separate
documentation page adds redundant information. If we maintain a stable,
versioned error registry (similar to IANA's or
[SmartBear's](https://problems-registry.smartbear.com)), full URLs can provide
value, but for most teams, URI identifiers like
`/problems/constraint-violation` provide the benefits of categorization without
the maintenance burden.

### Why support both `localizedDetail` and `parameters` for localization?

Different clients have different capabilities and requirements. Simple clients
like CLI tools, quick scripts, and log aggregators benefit from receiving a
human-readable, localized message directly without implementing i18n
frameworks. Sophisticated clients like web and mobile applications often have
their own i18n infrastructure and want full control over message formatting and
localization using structured data from `parameters`. Supporting both
approaches ensures the API works well for all consumers without forcing either
group to do unnecessary work.

## Further Reading

- [RFC 9457 Problem Details for HTTP APIs][RFC 9457]
- [IANA HTTP Problem Types Registry](https://www.iana.org/assignments/http-problem-types/http-problem-types.xhtml)
- [SmartBear Problems Registry](https://problems-registry.smartbear.com)
- [AEP-63: HTTP Status Codes](/status-codes)
- [Micronaut Problem JSON library](https://micronaut-projects.github.io/micronaut-problem-json/latest/guide/)
- [Spring Framework Error Responses](https://docs.spring.io/spring-framework/reference/web/webmvc/mvc-ann-rest-exceptions.html)
  - In Spring Boot, the `spring.mvc.problemdetails.enabled` property
    autoconfigures a `ResponseEntityExceptionHandler` that handles built-in
    exceptions with problem details.

## Changelog

- **2026-02-03**: Changed guidance from
  [Vnd model](https://github.com/blongden/vnd.error) to [RFC 9457]
- **2025-12-15**: Initial creation, adapted from [Google AIP-193][] and aep.dev
  [AEP-193][].

[Google AIP-193]: https://google.aip.dev/193
[AEP-193]: https://aep.dev/193
[RFC 9457]: https://datatracker.ietf.org/doc/html/rfc9457
[long-running operations]: ./0151
[Accept-Language]:
  https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Accept-Language
