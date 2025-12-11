# Authorization checks

The majority of operations, whether reads or writes, require authorization:
permission to do the thing the user is asking to do. Additionally, it is
important to be careful how much information is provided to _unauthorized_
users, since leaking information can be a security concern.

## Guidance

Services **must** check permissions before checking resource existence to avoid information
disclosure. [RFC 7231 Section 6.5.4] notes that `404 Not Found` can be used when a server "is not willing to disclose
that a resource exists". The response depends on the caller's permission level:

* If the caller lacks permission to know whether the resource exists, the service **should** return `404 Not Found`,
  regardless of whether the resource actually exists. This prevents information disclosure about resources the caller
  should not know about.
* If the caller has permission to know the resource exists but cannot perform the requested operation on it, the service
  **should** return `403 Forbidden`.
* If the caller has proper permission but the resource does not exist, the service **must** return `404 Not Found`.

This guidance applies to all HTTP methods.

### Multiple operations

A service could encounter situations where different operations with different permission requirements could reveal the
existence of a resource. For example, a user might have permission to create resources but not read them within a
collection that uses client-specified IDs.

In this situation, the service **must** only check authorization applicable to the specific operation being called,
rather than checking for related permissions that would provide indirect knowledge of existence. Cross-operation
permission checks are complicated to implement correctly and prone to accidental information leaks.

For example, consider a scenario where:

- A resource exists that a user cannot read
- The user _does_ have permission to create resources in the collection
- The collection uses client-specified IDs (meaning a duplicate ID error would reveal existence)

In this case:

- A `GET` request for the existing resource **must** return `404 Not Found` (because the user lacks read permission)
- A `POST` request to create a resource with the same ID **must** return `409 Conflict` (because the user has create
  permission and the ID conflict is relevant to that operation)

Each endpoint **must** only evaluate permissions relevant to its own operation, not permissions for other operations
that might indirectly reveal information.

[RFC 7231 Section 6.5.4]: https://tools.ietf.org/html/rfc7231#section-6.5.4

## Changelog

* **2025-12-10**: Initial creation, adapted from [Google AIP-211][] and aep.dev [AEP-211][].

[Google AIP-211]: https://google.aip.dev/211

[AEP-211]: https://aep.dev/211
