# Glossary

This AEP defines common terminology.

## Guidance

The following terminology **must** be used consistently throughout AEPs.

### API

Application Programming Interface. This can be a local interface (such as an
SDK) or a Network API (defined below).

APIs define one or more operations upon resource types.

### API Backend

A set of servers and related infrastructure that implements the business logic
for an API Service.

### API Client

An API Client is a program or library that performs a specific task, or set of tasks, by calling an API. It can also
include generic tools, such as CLIs, that expose the API in a user-accessible fashion or operate on resource data at
rest.

Examples of clients include the following:

- Command line interfaces
- Libraries, such as an SDK for a particular programming language
- Scripts that operate on a JSON representation of a resource after reading it
  from an API
- Tools, such as a [Declarative client][]
- Visual UIs, such as a web application

[declarative clients]: #declarative-clients

### AEP Version

A specific version of the AEP specification. This is a specific collection of
AEP guidance that will not change, versioned using only the major version of semver (e.g., `v3`). See
[editions](/editions) for more information.

### API Definition

A well-structured representation of an API. We standardize on [OpenAPI](/openapi).

### API Endpoint

An individual operation within an API, represented by an HTTP method (`GET`, `POST`, `PUT`, `PATCH`, `DELETE`) combined
with a resource path. For example, `GET /users/123` and `POST /users` are two different endpoints. The complete URL
includes the base URL, such as `https://api.example.com/users/123`.

### API Gateway

One or more services that together provide common functionality across API
services, such as load balancing and authentication.

### API Name (API Title)

Refers to the user-facing product title of an API service, such as "Secure Token Service".

### API Request

A single invocation of an API Method. It is often used as the unit for billing,
logging, monitoring, and rate limiting.

### API Resource

An entity upon which one or more operations can be performed. In HTTP APIs, resources are addressable concepts
identified by URIs (e.g., `/users/123` represents a specific user resource). See [URI](#uri-uniform-resource-identifier)
for more information.

### Cacheable

A property of operations indicating that responses can be stored and reused for subsequent requests. Caching improves
performance by reducing server load and network latency.

### Consumer

Either a programmatic client or a user that consumes an API. This term should
be used when a statement refers broadly to both programs and users.

### Collection

A collection represents a discrete set of resources of a specific type. A
resource may have one or more collections, with each collection having its own
parent.

### Declarative Clients

Declarative Clients, also known as Infrastructure as Code (IaC), describes a
category of clients that consumes a markup language or code that represents
resources exposed by an API and executes the appropriate imperative actions to
drive the resource to that desired state. To determine what changes to make and
if a set of updates was successful, a declarative client compares server side
resource attributes with client-defined values. The comparison feature ensures
accuracy of a creation or an update, but it requires services to treat the
client set fields as read-only and diligently preserve those values.

Examples of complexities that declarative clients abstract away include:

- Determine the appropriate imperative action (create / update / delete) to
  achieve desired state.
- Ordering of these imperative actions.

[Terraform][] is an example of such a client.

[terraform]: https://www.terraform.io/

### Deprecation

The process of phasing out an API feature, endpoint, or version. Deprecated elements remain functional but are marked
for future removal.

### Hypermedia

The practice of including links and action descriptions within API responses that guide clients on what operations are
available next. Hypermedia-driven APIs allow clients to discover capabilities dynamically rather than requiring
hardcoded knowledge of all endpoints. Also known as HATEOAS (Hypermedia as the Engine of Application State).

### Idempotent

A property of an operation where making the same request multiple times has the same effect as making it once.
Idempotency is critical for reliable APIs, as it allows clients to safely retry requests without unintended side
effects.

### Network API

An API that operates across a network of computers. Network APIs communicate using network protocols, including HTTP,
and are frequently produced by organizations separate from those that consume them.

### Resource ID

The unique identifier for a resource, within its parent collection. For
example, in the following resource path:

```
/publishers/consistent-house/books/pride-and-prejudice
```

There are two resource IDs:

- `consistent-house`, which is the id of the publisher.
- `pride-and-prejudice`, which is the id of the book.

See [resource paths](/122#resource-id) for more information.

### Root collection

A [collection](#collection) that does not have any parent collections.

### Root resource

A root resource is a resource for which a collection exists that has no
parents. In other words, it is a resource that has a collection that appears at
the root of a resource hierarchy.

A root resource may also appear as a child of another resource: for example, a
music streaming service may have global shared playlists (e.g. "top
trending"), but may also have playlists nested under a user. In this case, a
playlist is still considered a root resource, since the collection with the
glocal shared playlists has no parents.

### Safe

A property of an HTTP method indicating that it does not modify server state. Safe methods can be called without concern
for causing side effects, making them suitable for caching, prefetching, and automated tools.

### Schema

A schema describes the structure of the request or response of an
[API endpoint](#api-endpoint), or a [resource](#api-resource). In this context, it refers to an OpenAPI schema.

### User

A human being which is using an API directly. This term is
defined to differentiate usage in the AIPs between a human _user_ and a
programmatic _client_. A user does not always solely refer to a customer of Thryv (public APIs); users can also be
internal, like employees and fellow developers.

### URI (Uniform Resource Identifier)

A string that identifies a resource. URIs can be URLs (which specify location and access method) or URNs (which provide
a name in a particular namespace). In REST API contexts, when people say "resource URI" they usually mean just the path
portion (`/users/123`).

See AEP-62 for more information on URIs, URLs, and URNs.

### URL (Uniform Resource Locator)

A type of URI that specifies both the location of a resource and the mechanism to retrieve it. A URL includes the
scheme (protocol), host (domain), and path. For example, `https://api.example.com/users/123` is a complete URL, where
`https` is the scheme, `api.example.com` is the host, and `/users/123` is the path. In REST API contexts, when people
say "URL" they usually mean the complete address (`https://api.example.com/users/123`)

URI is a broader term than URL; all URLs are URIs, but not all URIs are URLs. See AEP-62 for more information on URIs,
URLs, and URNs.

## URN (Uniform Resource Name)

A type of URI that identifies a resource by a persistent, location-independent name rather than by its location or how
to access it. URNs follow the format `urn:<namespace>:<specific-string>`, such as `urn:isbn:0-486-27557-4` for
identifying a book by its ISBN.

While URNs are not used as resource addresses in REST API URLs, they appear in API contexts as standardized identifier
values, particularly in protocol specifications and configuration settings. For example, OAuth 2.0 uses URNs for token
types (e.g., `urn:ietf:params:oauth:token-type:access_token`) and grant types (e.g.,
`urn:ietf:params:oauth:grant-type:token-exchange`).

URN is a broader term than URL; all URNs are URIs, but not all URIs are URNs. See AEP-62 for more information on URIs,
URLs, and URNs.

## Changelog

- **2026-01-21**: Add URN
- **2025-10-30**: Initial AEP-9 for Thryv, adapted from [Google AIP-9][] and aep.dev [AEP-3][].

[Google AIP-9]: https://google.aip.dev/9

[AEP-3]: https://aep.dev/3
