# Standard Names

Certain concepts are common throughout any corpus of APIs. In these situations,
it is useful to have a standard field name and behavior that is used
consistently to communicate that concept.

## Guidance

Standard fields **should** be used to describe their corresponding concept, and
**should not** be used for any other purpose.

### Tenancy

Our software is multi-tenanted, meaning users exist only within their own tenant instance and cannot access data from
other tenants. A **tenant** represents an isolated instance of the application with its own data, users, and
configuration.

The following terms are synonymous and refer to the same concept:

- Tenant
- Tenant ID
- App Name
- App ID

APIs **must** use the term "tenant" in all _**new**_ development. The legacy terms "app name" and "app ID" are deprecated
and exist only for backward compatibility in existing APIs.

### HTTP headers

#### `X-AEP-Version`

Response only. Required. Identifies which set of organizational API design standards the service follows, independent of
the API's own version number. APIs **must** include this header in all responses. Clients **must not** send this header
in requests.

#### `X-Tenant`

**Must** be a string. The tenant this request or response is scoped to. **Must** be included in both requests and
responses for tenant-scoped operations, even if the tenant identifier appears elsewhere (path, query parameters, or
body). **Must not** be included for non-tenanted operations. This replaces legacy headers such as `x-is-app-name`,
`x-keap-tenant`, `x-is-tenant`, etc.

### JSON field names

APIs **should** use the standard field names defined in this section for their corresponding concepts.
See [JSON Payloads] for complete guidance.

#### `id`

**Must** be a string. The unique identifier for the resource. This is the resource's own ID; use the pattern
`{resource}Id` (e.g., `authorId`, `publisherId`) when referencing other resources.

#### `tenant`

**Must** be a string. The tenant identifier. The `X-Tenant` header **must** be the source of truth for tenant scope;
this field **should** generally be omitted from request and response bodies. When a tenant identifier is needed in the
body, use `tenant` for a single tenant or `tenants` for a list.

#### `createdTime`

**Must** be a timestamp. Read-only. When the resource was created. This **may** be either the time creation was
initiated or the time it was completed. See [Time and duration] for format requirements.

#### `updatedTime`

**Must** be a timestamp. Read-only. When the resource was last updated. Any change made by users **must** refresh
this value; changes made internally by the service **should** refresh this value. See [Time and duration] for format
requirements.

#### `deletedTime`

**Must** be a timestamp. Read-only. When the resource was soft deleted. This **may** correspond to either when the
user requested deletion or when the service successfully soft deleted the resource. See [Time and duration] for format
requirements.

#### `createdBy`

**Must** be a string. Read-only. The identifier of the user or service that created the resource.

#### `updatedBy`

**Must** be a string. Read-only. The identifier of the user or service that last modified the resource.

#### `displayName`

**Must** be a string. A user-friendly name for the resource, suitable for display in UIs. **Should** be mutable and
user-settable. **Should not** have uniqueness requirements.

#### `description`

**Must** be a string. A detailed textual description of the resource.

#### `state`

**Must** be an enum. The current lifecycle state of the resource (e.g., `ACTIVE`, `PENDING`, `DELETED`). Use `state`
rather than `status` to avoid confusion with HTTP status codes. See [States] for guidance on defining state enums.

#### `nextPageToken`

**Must** be a string. Token for retrieving the next page in [Pagination].

#### `prevPageToken`

**Must** be a string. Token for retrieving the previous page in [Pagination].

#### IP addresses

Fields representing IP addresses **must** comply with the following:

- Use type `string`
- Use the name `ipAddress` or end with the suffix `IpAddress` (e.g., `resolvedIpAddress`, `sourceIpAddress`)
- Specify the IP address version format via one of the supported formats: `IPV4`, `IPV6`, or `IPV4_OR_IPV6` if either
  version is acceptable

### Query parameters

APIs **should** use the standard query parameter names defined in this section. See [Query Parameters] for complete
guidance.

#### `page_token`

**Must** be a string. Cursor for next page. Token-based pagination. See [Pagination] for complete guidance.

#### `page_size`

**Must** be an integer. Maximum number of results to return. Token-based pagination. See [Pagination] for complete
guidance.

#### `offset`

**Must** be an integer. Starting position. Offset-based pagination. See [Pagination] for complete guidance.

#### `limit`

**Must** be an integer. Maximum number of results. Offset-based pagination. See [Pagination] for complete guidance.

#### `q`

**Must** be a string. Free-text search query. See [Filtering] for complete guidance.

#### `order_by`

**Must** be a string. Field(s) to sort results by. See [Filtering] for complete guidance.

#### `tenant`

**Must** be a string. The tenant identifier. The `X-Tenant` header **must** be the source of truth for tenant scope;
this query parameter **should** generally be omitted. When a tenant identifier is needed in the query string (like for
filtering), use `tenant` for a single tenant or `tenants` for a list.

#### `update_mask`

**Must** be a string. Fields to update in [PATCH requests](/134#field-masking).

#### `read_mask`

**Must** be a string. Fields to include in [partial responses](/partial-responses).

## Rationale

Some fields represent very well defined concepts or artifacts that sometimes
also have strict governance of their semantics. For such fields, presenting an
equally standardized API surface is important. This enables development of
improved API consumer tools and documentation, as well as a more unified user
experience across the platform.

[Pagination]: /pagination

[Filtering]: /filtering

[States]: /states

[Time and duration]: /time-and-duration

[JSON payloads]: /json-payloads

[Query Parameters]: /query-parameters

## Changelog

**2026-01-13**: Initial creation, adapted from [Google AIP-148][] and aep.dev [AEP-148][].

[Google AIP-148]: https://google.aip.dev/148

[AEP-148]: https://aep.dev/148
