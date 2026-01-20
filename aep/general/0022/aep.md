# URLs

URLs (Uniform Resource Locators) are the addressing system of the web, providing a standardized way to identify and
locate resources. In the context of web APIs, URLs serve as the primary mechanism for clients to specify which resources
they want to interact with. This AEP offers an educational overview of URL structure and how its components work
together to form complete resource addresses.

Understanding URLs is fundamental to working with APIs effectively. Whether you're making API requests, designing
resource hierarchies, or debugging integration issues, familiarity with URL structure will help you navigate APIs
confidently and communicate clearly with other developers.

## URL vs. URI vs. URN

You may often hear the terms **URI** (Uniform Resource Identifier) and **URL** (Uniform Resource Locator) used
interchangeably. While they are related, they have distinct meanings in technical specifications:

* **URI** is the broad category of all identifiers.
* **URL** is a type of URI that identifies a resource by its *location* (how to get there).
* **URN** (Uniform Resource Name) is another type of URI that identifies a resource by a persistent _name_, regardless
  of location (e.g., `urn:isbn:0-486-27557-4` for a book). URNs are rarely encountered in modern web API development.

**Note:** All URLs are URIs, but not all URIs are URLs.

In practice, almost every identifier used in web APIs is a **URL**. However, it is common for developers to use the
term "URI" when referring specifically to the _path_ portion of a URL (e.g., `/v1/users/123`). This usage reflects the
fact that the path is the identifier within the context of a particular host.

For more definitions of common API terminology, see the Glossary (AEP-9).

## Anatomy of a URL

**Note:** URLs have additional components and rules beyond what is covered in this AEP, but those are not typically
relevant for API development. For example, the **Fragment** (`#fragment`), which is used by browsers to navigate to a
specific part of a page, but is not used in API requests.

A URL looks like this:

```http
https://mycompany.com:443/api/v1/users?status=active&limit=10
```

It has several parts:

* **[Scheme](#scheme)**: The protocol being used (e.g., `https`).
* **[Host](#host)**: The domain name or IP address of the server (e.g., `mycompany.com`).
* **[Port](#port)**: The port number for the connection (e.g., `443`) (optional).
* **[Path](#path)**: The hierarchical location of the resource (e.g., `/v1/users`, `/v1/users/12345`).
* **[Query Parameters](#query-parameters)**: Key-value pairs for filtering or options (e.g.,
  `?status=active&limit=10`) (optional).

{% image 'url.png', 'Anatomy of a URL' %}

**Note:** A helpful analogy is to think of a URL like a postal address: the scheme is the delivery method (Standard vs.
Express), the host is the street address, the port is like a specific building entrance, the path represents the
specific department or office, and query parameters are additional delivery instructions (e.g., "Leave at front desk").

### Scheme

The scheme (also called the protocol) indicates how the client should communicate with the server. It appears at the
beginning of the URL, followed by a colon and two forward slashes (`://`).

Common schemes in web APIs include:

* `https`: Secure HTTP, which encrypts communication using TLS/SSL
* `http`: Standard HTTP without encryption

Modern web APIs almost exclusively use `https` to ensure secure communication and protect sensitive data in transit.
Many servers and API gateways automatically redirect `http` requests to `https` or reject unencrypted connections
entirely.

### Host

The host identifies the server where the resource is located. It can be either a domain name (like `mycompany.com`) or
an IP address (like `192.168.1.1`).

Domain names are the most common form of host in web APIs, as they are human-readable, memorable, and can be mapped to
different IP addresses as infrastructure changes. API hosts often use subdomains to distinguish between different
environments or services, such as:

* `mycompany.com` for production
* `staging.mycompany.com` for staging environments
* `dev.mycompany.com` for development environments

### Port

The port specifies which port on the server should handle the request. It appears after the host, separated by a colon (
e.g., `:443`).

Ports are optional in URLs because standard ports are assumed by default:

* Port `443` for `https` URLs
* Port `80` for `http` URLs

When using standard ports, the port number is omitted from the URL. Explicit port numbers are only necessary when the
server uses non-standard ports, such as `https://mycompany.com:8443` for a service running on port `8443`.

### Path

The path identifies the specific resource or collection being accessed on the server. In the context of REST APIs, the
path
represents the thing (noun) that the HTTP method (verb) acts upon. It appears after the host (and optional port),
starting with a forward slash (`/`).

Paths in APIs are typically hierarchical, using forward slashes to separate segments that represent resources and their
relationships. For example:

* `/v1/users` might represent a collection of users
* `/v1/users/12345` might represent a specific user with ID `12345`
* `/v1/users/12345/orders` might represent the orders belonging to that user

The path often includes a version prefix (like `/v1`) to allow APIs to evolve over time while maintaining backward
compatibility with existing clients.

For specific patterns on constructing resource paths, see AEP-122.

### Query Parameters

Query parameters provide a mechanism to pass additional information to the server without changing which resource is
being accessed. They appear after the path, starting with a question mark (`?`), and consist of key-value pairs
separated by ampersands (`&`).

Common uses for query parameters in APIs include:

* Filtering: `?status=active&type=premium`
* Pagination: `?page=2&limit=50`
* Sorting: `?sort=created_time&order=desc`

Query parameter keys and values should be URL-encoded to handle special characters properly. For example, spaces are
encoded as `%20` or `+`. A search for "Victor Hugo" would be encoded as `Victor%20Hugo` (or `Victor+Hugo`), since spaces
are not allowed in raw URLs. Characters like `&`, `=`, and `?` must also be encoded to avoid conflicting with URL
syntax. See AEP-129 for guidelines on query parameters.

## Further Reading

* [MDN Web Docs: What is a URL?](https://developer.mozilla.org/en-US/docs/Learn/Common_questions/What_is_a_URL)
* [RFC 3986: Uniform Resource Identifier (URI): Generic Syntax](https://datatracker.ietf.org/doc/html/rfc3986)

## Changelog

* **2026-01-16**: Initial creation.
