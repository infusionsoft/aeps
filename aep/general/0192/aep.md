# Documentation

Documentation is one of the most critical aspects of API design. Users of your
API are unable to dig into the implementation to understand the API better;
often, the API contract and its corresponding documentation will be the only
things a user has. Therefore, it is important that documentation be as clear,
complete, and unambiguous as possible.

## Guidance

For HTTP REST APIs, documentation **must** be provided for every _user-facing_ component. Per AEP-101, this
documentation **must** be authored within an OpenAPI specification, including:

* API-level metadata (title, version, terms of service)
* Paths and Operations (HTTP methods)
* Parameters (path, query, header, etc.)
* Request bodies and Response schemas
* Enum values and error codes

This is important even in cases where the description is terse and seemingly uninteresting, as numerous tools consume
OpenAPI descriptions to generate reference documentation, client libraries, and SDKs.

API-level documentation **should** clearly explain the API's "Job to be Done." It **should** include:

* A high-level overview of the domain.
* Authentication requirements (referenced generally).
* Common error handling patterns.
* Rate limiting and pagination behavior.

**Note:** Not all readers will be native English speakers. Documentation
**should** avoid jargon, slang, complex metaphors, pop culture references, or
anything else that will not easily translate. Additionally, many readers will
have different backgrounds and viewpoints; if writing examples involving people,
documentation **should** use people who are non-controversial and no longer
alive.

### Visibility

APIs **must** hide specific operations or paths from public documentation that are not intended for general consumption,
specifically:

- Internal-only administrative endpoints.
- Infrastructure-related endpoints (e.g., health checks, metrics) that do not provide business value to API consumers
  and could expose system details.

APIs **may** hide experimental features or alpha/beta endpoints from public documentation if they are not yet ready for
broad adoption. If such a field is visible, then its description **must** explicitly say it is experimental or in
alpha/beta.

If an endpoint is hidden from the public OpenAPI specification, its behavior **should** still be documented for internal
maintainers. This documentation can live within the service's source code (e.g., code comments), a `README.md` in the
project repository, a team wiki; whatever the team's standard is.

### Style

Descriptions **should** be written in grammatically correct American English.
The first sentence of each description **should** omit the subject and
be in the third-person present tense:

```yaml
summary: Create a book under the given publisher.
description: Creates a new book resource under the specified publisher.
```

### Descriptions

Descriptions **should** be concise, factual, and written as statements of behavior rather than instructions to the
reader.

Descriptions of API components **should** be brief but complete. Sometimes
descriptions are necessarily perfunctory because there is little to be said;
however, before jumping to that conclusion, consider whether some of the
following questions are relevant:

- What is it?
- How do you use it?
- What does it do if it succeeds? What does it do if it fails?
- Is the operation idempotent?
- What are the units? (Examples: meters, degrees, pixels)
- What are the side effects?
- What are common errors that may break it?
    - What is the expected input format?
    - What range of values does it accept? (Examples: `[0.0, 1.0)`, `[1, 10]`)
        - Is the range inclusive or exclusive?
    - For strings, what is the minimum and maximum length, and what characters
      are allowed?
        - If a value is above the maximum length, do you truncate or send an error?
- Is it always present? (Example: "Container for voting information. Present
  only when voting information is recorded.")
- Does it have a default setting? (Example: "If `page_size` is omitted, the
  default is 50.")

For operations, descriptions **should** clearly describe the HTTP semantics, including expected status codes and error
behavior.

### Examples

Documentation **should** provide realistic examples for all complex request and response schemas.

* Examples **must** use valid data formats.
* Examples **should** represent a "happy path" as well as common error cases.

### External links

Descriptions **may** link to external pages to provide background information beyond what is described in the API
documentation itself. External links **must** use absolute URLs, including the protocol (usually `https`).

### Trademarked names

When referring to the proper, trademarked names of companies or products in
documentation, acronyms **should not** be used unless the acronym is in such
dominant colloquial use that avoiding it would obscure the reference
(examples: IBM, AWS).

Documentation **should** spell and capitalize trademarked names consistent with
the trademark owner’s current branding.

### Deprecations

To deprecate an API component (path, operation, parameter, request body, response, schema, or field), the OpenAPI
`deprecated` flag **must** be set to `true`.

The first sentence of the corresponding description **must** begin with `Deprecated:` and **must** provide guidance on
alternative solutions. If no alternative exists, a deprecation reason **must** be provided.

## Further Reading

* [OpenAPI AEP](/openapi)

## Changelog

**2025-12-18**: Initial creation, adapted from [Google AIP-192] and aep.dev [AEP-192].

[Google AIP-192]: https://google.aip.dev/192

[AEP-192]: https://aep.dev/192
