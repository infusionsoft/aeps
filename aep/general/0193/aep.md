# Errors

**Important:** There is an RFC for a standardized error response for HTTP APIs ([RFC 9457](https://datatracker.ietf.org/doc/html/rfc9457)). Micronaut has a library for it, to easily use it https://micronaut-projects.github.io/micronaut-problem-json/latest/guide/. I am wondering if we should use the RFC standardized one instead? Vnd is pretty common, but community defined and maintained.

Effective error handling is critical to API usability. When something goes wrong, clients need clear, structured
information about what happened and how to resolve it. Inconsistent or unclear error responses lead to frustration,
debugging difficulties, and poor developer experience.

This document defines the standard error format for HTTP REST APIs, ensuring that all endpoints communicate errors in a
consistent, machine-readable manner.

## Guidance

APIs **must** return errors in a consistent, machine-readable format that provides enough information for clients to
understand and handle the error appropriately.

APIs **should** return all errors the `vnd.error` format.

The error response **must** use the content type `application/vnd.error+json`.

**Note:** For Micronaut developers, see
the [VndError class documentation](https://micronaut-projects.github.io/micronaut-docs-mn2/2.5.1/api/io/micronaut/http/hateoas/VndError.html).

The following fields are part of the vnd error:

* `message` (required): A human-readable message related to the current error which may be displayed to the user of the
  API.
* `logref` (optional): A numeric, alphabetic, or alphanumeric identifier to refer to the specific error on the server
  side for logging purposes (e.g., a request ID or trace ID).
* `path` (optional): A JSON Pointer ([RFC 6901](https://tools.ietf.org/html/rfc6901)) to a field in the related
  resource (contained in the `about` link relation) that this error is relevant for.

The following link relations **may** be included:

* `help`: Links to documentation describing the error. This has the same definition as the help link relation in
  the [HTML5 specification](https://www.w3.org/TR/html5/links.html#link-type-help).
* `describes`: Links to another representation of the error on the server side.
  See [RFC 6892](https://tools.ietf.org/html/rfc6892) for further details.
* `about`: Links to the resource that this error is related to.
  See [RFC 6903](https://tools.ietf.org/html/rfc6903#section-2) for further details.

All links **must** include an `href` property containing either a URI ([RFC 3986](https://tools.ietf.org/html/rfc3986))
or a URI Template ([RFC 6570](https://tools.ietf.org/html/rfc6570)). If the value is a URI Template, the link object *
*should** have a `templated` attribute with the value `true`.

Example:

```json
{
  "message": "Validation failed",
  "path": "/username",
  "logref": 42,
  "_links": {
    "about": {
      "href": "http://path.to/user/resource/1"
    },
    "describes": {
      "href": "http://path.to/describes"
    },
    "help": {
      "href": "http://path.to/help"
    }
  }
}
```

### Multiple Errors

When multiple validation errors or similar issues occur, they **should** be represented in a collection of embedded
`vnd.error` objects:

```json
{
  "total": 2,
  "_embedded": {
    "errors": [
      {
        "message": "\"username\" field validation failed",
        "logref": 50,
        "_links": {
          "help": {
            "href": "http://.../"
          }
        }
      },
      {
        "message": "\"postcode\" field validation failed",
        "logref": 55,
        "_links": {
          "help": {
            "href": "http://.../"
          }
        }
      }
    ]
  }
}
```

### Nested Errors

When an error has contextual sub-errors, they **may** be represented by embedding multiple errors inside a parent
`vnd.error` resource:

```json
{
  "message": "Validation failed",
  "logref": 42,
  "_links": {
    "describes": {
      "href": "http://path.to/describes"
    },
    "help": {
      "href": "http://path.to/help"
    },
    "about": {
      "href": "http://path.to/user/resource/1"
    }
  },
  "_embedded": {
    "errors": [
      {
        "message": "Username must contain at least three characters",
        "path": "/username",
        "_links": {
          "about": {
            "href": "http://path.to/user/resource/1"
          }
        }
      }
    ]
  }
}
```

### Partial errors

APIs **should not** support partial errors. Partial errors add significant complexity for users because they usually
sidestep the use of error codes or move those error codes into the response message, where the user must write
specialized error handling logic to address the problem.

However, occasionally partial errors are necessary, particularly in bulk operations where it would be hostile to users
to fail an entire large request because of a problem with a single entry.

Methods that require partial errors **should** use [long-running operations], and the method **should** put partial
failure information in the `metadata` message.

### Permission Denied

If the user does not have permission to access the resource or parent, regardless of whether or not it exists, the
service must error with `403 Forbidden`. Permission must be checked prior to checking if the resource or parent exists.
See [Authorization checks] for more information.

## Interface Definitions

{% tab proto %}

{% tab oas %}

{% sample 'errors.oas.yaml', '$.components.schemas' %}

{% endtabs %}

## Rationale

The `vnd.error` format provides several benefits:

* It's a well-defined media type with clear semantics
* Structured format allows clients to programmatically handle errors
* The `message` field provides clear error descriptions
* Link relations allow providing additional context and documentation
* Micronaut and other frameworks provide built-in support

## Further reading

* [vnd.error specification](https://github.com/blongden/vnd.error)

[long-running operations]: /long-running-operations

[Authorization checks]: /authorization-checks

## Changelog

* **2025-12-15**: Initial creation, adapted from [Google AIP-193][] and aep.dev [AEP-193][].

[Google AIP-193]: https://google.aip.dev/193

[AEP-193]: https://aep.dev/193
