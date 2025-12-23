# Resource paths

Most APIs expose _resources_ (their primary nouns) which users are able to
create, retrieve, and manipulate. Additionally, resources have _paths_: each
resource has a unique (within the API service) identifying path that users use
to reference that resource, and these paths are what users should _store_ as
the canonical identifier for the resources.

## Guidance

A resource path refers to the identifier for a specific resource, unique
within an API.

* A resource path **must** be unique with an API, referring to a single
  resource.

See the section on [full resource paths](#full-resource-paths) below for more
information on referring to resources across APIs.)

Resource paths are formatted according to the [URI path schema]:

```
/publishers/123/books/les-miserables
/users/vhugo1802
```

* Resource path components **must** alternate between collection identifiers
  (example: `publishers`, `books`, `users`) and resource IDs (example: `123`,
  `les-miserables`, `vhugo1802`), _except_ when [singleton resources] are
  present.
* Resource paths **must** use the `/` character to separate individual segments
  of the resource path.
* Each segment of a resource path **must not** contain a `/` character.
* Resource paths **must not** contain empty segments (e.g., `/publishers//books`).
* Resource paths **must not** end with a trailing `/` (e.g., `/publishers/books/`)
* Resource paths **should** only use characters available in DNS names, as
  defined by [RFC 1123].
    * Additionally, resource IDs **should not** use upper-case letters.
    * If additional characters are necessary, resource paths **should not** use
      characters that require URL-escaping, or characters outside of [ASCII].
    * If Unicode characters cannot be avoided, see [Unicode characters](#unicode-characters) below.

**Note:** Resource paths as described here are used within the scope of a
single API (or else in situations where the owning API is clear from the
context), and are only required to be unique within that scope. For this
reason, they are sometimes called _relative resource paths_ to distinguish them
from _full resource paths_ (discussed below). Any official documentation
**should not** use the term _relative resource path_, and **should** use the
term _resource path_ instead.

### Collection identifiers

The collection identifier segments in a resource path **must** be the plural
form of the noun used for the resource. (For example, a collection of
`Publisher` resources is called `publishers` in the resource path.)

* Collection identifiers **must** be concise English terms.
* Collection identifiers **must** be in `kebab-case`.
* Collection identifiers **must** begin with a lowercased letter and contain
  only lowercase [ASCII] letters, numbers. and hyphens (`/[a-z][a-z0-9-]*/`).
    * The only exception to this is [reading across collections], where a single hyphen `-` **may** be
      used as a wildcard character to represent any parent collection identifier.
* Collection identifiers **must** be plural.
    * In situations where there is no plural word ("info"), or where the singular
      and plural terms are the same ("moose", "sheep"), the non-pluralized (singular) form
      is correct. Collection segments **must not** "coin" words by adding "s" in
      such cases (e.g. avoid "infos", "sheeps").
* Within any given single resource name, collection identifiers **must** be unique. (e.g., `people/xyz/people/abc` is
  invalid)

### Resource ID

A resource ID segment identifies the resource within its parent collection. In
the resource path `publishers/123/books/les-miserables`, `123` is the resource
ID for the publisher, and `les-miserables` is the resource ID for the book.

* All ID fields **must** be strings.
* Resource IDs **may** be either always set by users (required on resource
  creation), optionally set by users (optional on resource creation,
  server-generated if unset), or never set by users (not accepted at resource
  creation). They **must** be immutable once created.
* If resource IDs are user-settable, the API **must** document and/or annotate
  the field with the allowed formats. User-settable resource IDs **should**
  conform to [RFC 1034]; which restricts to letters, numbers, and hyphen,
  with the first character a letter, the last a letter or a number, and a 63-character maximum.
    * Additionally, user-settable resource IDs **should** restrict letters to
      lowercase (`^[a-z]([a-z0-9-]{0,61}[a-z0-9])?$`).
    * Characters outside of ASCII **should not** be permitted; however, if
      Unicode characters are necessary, APIs **must** follow guidance in [Unicode characters](#unicode-characters).
    * APIs **should** use the [OpenAPI `pattern` keyword] to enforce identifier formats in their schemas.
* If resource IDs are not user-settable, the API **should** document the basic
  format and any upper boundaries (for example, "at most 63 characters").

### Resource ID aliases

It is sometimes valuable to provide an alias for common lookup patterns for
resource IDs. For example, an API with `users` at the top of its resource
hierarchy may wish to provide `users/me` as a shortcut for retrieving
information for the authenticated user.

APIs **may** provide programmatic aliases for common lookup patterns. However,
all data returned from the API **must** use the canonical resource path if implementing HATEOAS.

For example:

```http request
GET /v1/users/me
```

Returns (with HATEOAS links):

```json
{
  "id": "vhugo1802",
  "name": "Victor Hugo",
  "_links": {
    "self": {
      "href": "https://api.example.com/v1/users/vhugo1802"
    }
  }
}
```

### Hierarchy and Nesting

Paths **must** represent resources in a hierarchical manner, moving from general to specific:

1. `/publishers` - Collection of publishers
2. `/publishers/123` - A specific publisher
3. `/publishers/123/books` - Books belonging to that publisher
4. `/publishers/123/books/les-miserables` - A specific book

These **must** alternate between collections (example: `publishers`, `books`, `users`) and resource IDs (example: `123`,
`les-miserables`, `vhugo1802`), _except_ when [singleton resources] are present.

Resource nesting **should** be kept shallow, where possible. While there is no hard limit on nesting depth, deep
hierarchies can become difficult to navigate and may conflict with URL length constraints. If a resource has a
_globally_ unique identifier, the API **may** expose it as a top-level resource instead of (or in addition to) its
nested form, to allow direct access without the full hierarchy (such as `/books/{bookId}`). This is particularly useful
when clients need direct access without knowing the full hierarchy. For example, instead of requiring the full
hierarchical path:

```
/publishers/123/authors/victor-hugo/books/les-miserables
```

Expose `books` as a top-level resource using its _globally_ unique ID:

```
/books/les-miserables
```

**Important:** APIs wishing to do this **must** follow this format _consistently_ throughout the API, or else _not at
all_.

### Full resource paths

In most cases, resource paths are used within a single API only. However,
sometimes it is necessary for services to refer to resources in a different API (for
example, in a cross-service reference or an event payload). In this situation, the service **must** use the _full
resource path_, a schemeless URI with the owning API's service endpoint, followed by the relative resource path:

```text
//apis.example.com/library/publishers/123/books/les-miserables
//apis.example.com/calendar/users/vhugo1802
```

### Resource URIs

The [full resource path](#full-resource-paths) is a schemeless URI, but slightly distinct from the full
URIs we use to access a resource. The latter adds two components: the protocol
(HTTPS) and the API version:

```
https://apis.example.com/library/v1/publishers/123/books/les-miserables
https://apis.example.com/calendar/v3/users/vhugo1802
```

The version is not included in the full resource path because the full resource
path is expected to persist from version to version. Even though the API
surface may change between major versions, multiple major versions of the same
API are expected to use the same underlying data.

**Note:** The correlation between the full resource path and the service's
hostname is by convention. In particular, one service is able to have multiple
hostnames (example use cases include regionalization or staging environments),
and the full resource path does not change between these.

### Unicode characters

Resource paths **should** use stable [ASCII] identifiers rather than
human-readable names containing special characters. For example, use
`/books/12345` instead of `/books/les-misérables` (notice the `é`).

If human-readable names are required (such as for SEO or discovery), the API
**should** transliterate non-ASCII characters to their closest ASCII
equivalents. For example, use `/books/les-miserables` instead of
`/books/les-misérables` (where the `é` is replaced by `e`). Transliteration
ensures maximum compatibility across all clients and eliminates the risks
associated with character normalization and encoding.

If non-ASCII characters cannot be avoided and transliteration is not
appropriate, the following rules apply:

* **Normalization:** All resource paths containing Unicode characters **must**
  be stored and processed using Unicode [Normalization Form C]. This
  prevents `404 Not Found` errors caused by characters that look identical but
  have different underlying byte sequences (such as a precomposed `é` versus
  an `e` followed by a combining accent).
* **Encoding:** When transmitted in a URI, non-ASCII characters **must** be
  percent-encoded according to [RFC 3986 Section 2.1]. APIs **should** normalize the path
  to [Normalization Form C] immediately after percent-decoding the incoming request to ensure it
  matches the stored identifier.

If an API explicitly allows non-ASCII characters, it **must** document the
supported character encodings and **must** provide examples of proper percent-encoding.

## Rationale

Why lowercase `kebab-case`?

Per [RFC 3986 Section 6.2.2.1], while the scheme and host components of a URI are case-insensitive, the path component
_is_ case-sensitive. This means that `/userProfiles` and `/userprofiles` are technically different URIs. If a client,
proxy, or developer accidentally lowercases a URL, a `camelCase` path like `/userProfiles` becomes `/userprofiles` and
results in a `404 Not Found`error. Standardizing on lowercase letters exclusively eliminates this ambiguity and ensures
that paths remain "lowercase-safe."

Hyphens also provide a clear physical break between words, whereas `camelCase` often may look like one long,
difficult-to-read string. Furthermore, in user interfaces or technical documentation where links are underlined, an
underscore (`_`) is often obscured by the underline, whereas a hyphen remains clearly visible.

Using `kebab-case` for paths also creates a clear visual distinction from query parameters and JSON keys, which use
`snake_case` (AEP-129) and `camelCase` (AEP-140) respectively. This distinction helps developers quickly identify
whether they are looking at a resource location or a data attribute.

[rfc 1034]: https://tools.ietf.org/html/rfc1034

[rfc 1123]: https://datatracker.ietf.org/doc/html/rfc1123

[uri path schema]: https://datatracker.ietf.org/doc/html/rfc3986#appendix-A

[RFC 3986 Section 2.1]: https://datatracker.ietf.org/doc/html/rfc3986#section-2.1

[RFC 3986 Section 6.2.2.1]: https://datatracker.ietf.org/doc/html/rfc3986#section-6.2.2.1

[ASCII]: https://www.ascii-code.com

[OpenAPI `pattern` keyword]: https://swagger.io/docs/specification/v3_0/data-models/data-types/#pattern

[reading across collections]: /reading-across-collections

[singleton resources]: /singletons

[Normalization Form C]: https://unicode.org/reports/tr15

## Changelog

* **2025-12-22**: Refactored for clarity and improved the technical rationale for lowercase `kebab-case`; introduced
  flexible regex requirements for resource IDs and Unicode normalization rules.
* **2025-12-09**: Moved pieces about resource oriented design to AEP-121
* **2025-12-03**: Change Nouns, NOT Verbs section to better clarify when custom methods are appropriate.
* **2025-11-07**: Initial AEP-122 for Thryv, adapted from [Google AIP-122][] and aep.dev [AEP-122][].

[Google AIP-122]: https://google.aip.dev/122

[AEP-122]: https://aep.dev/122
