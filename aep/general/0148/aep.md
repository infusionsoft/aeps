# Standard fields

Certain concepts are common throughout any corpus of APIs. In these situations,
it is useful to have a standard field name and behavior that is used
consistently to communicate that concept.

## Guidance

Standard fields **should** be used to describe their corresponding concept, and
**should not** be used for any other purpose.

### JSON field names

APIs **should** use the standard field names defined in this section for their corresponding concepts.
See [JSON Payloads] for complete guidance.

#### `id`

**Must** be a string. The unique identifier for the resource. This is the resource's own ID; use the pattern
`{resource}Id` (e.g., `authorId`, `publisherId`) when referencing other resources.

#### `organizationId`

**Must** be a string. The organization identifier. See AEP-218 for full guidance.

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

#### `purgeTime`

**Must** be a timestamp. Read-only. The time when a soft deleted resource will be purged from the system (see AEP-164).
Resources that support soft delete **should** include this field.

Services **may** provide a `purgeTime` value that is inexact, but the resource **must not** be purged from the system
before that time.

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

#### `pageToken`

**Must** be a string. Cursor for next page. Token-based pagination. See [Pagination] for complete guidance.

#### `pageSize`

**Must** be an integer. Maximum number of results to return. Token and Offset-based pagination. See [Pagination] for
complete guidance.

#### `pageNumber`

**Must** be an integer. Which page of results to return for offset-based pagination. See [Pagination] for complete
guidance.

#### `q`

**Must** be a string. Free-text search query. See [Filtering] for complete guidance.

#### `orderBy`

**Must** be a string. Field(s) to sort results by. See [Filtering] for complete guidance.

#### `cascade`

**Must** be a boolean. Used in [Delete] operations to indicate whether child resources should be deleted along with the
parent resource. When `cascade` is `true`, the API deletes the specified resource and all its child resources. When
`cascade` is unset, it **must** default to `false`.

#### `organizationId`

**Must** be a string. The organization identifier. See AEP-218 for full guidance.

#### `updateMask`

**Must** be a string. Fields to update in [PATCH requests](/134#field-masking).

#### `readMask`

**Must** be a string. Fields to include in [partial responses](/partial-responses).

#### `showDeleted`

**Must** be a boolean (`true`/`false`). Indicates if [soft deleted](/soft-delete) resources should be included in
responses.

## Rationale

Some fields represent very well defined concepts or artifacts that sometimes
also have strict governance of their semantics. For such fields, presenting an
equally standardized API surface is important. This enables development of
improved API consumer tools and documentation, as well as a more unified user
experience across the platform.

### Why `createdTime` over `createdAt`?

`createdAt` could also refer to a location. `createdTime` avoids that language ambiguity while remaining slightly more
"standard" for REST APIs than the more database-centric `createdTimestamp`.

[Pagination]: /pagination

[Filtering]: /filtering

[States]: /states

[Time and duration]: /time-and-duration

[JSON payloads]: /json-payloads

[Query Parameters]: /query-parameters

[delete]: /delete

## Changelog

* **2026-03-11**: Update tenant terminology to organization ID. Move detailed organization ID guidance to AEP-218.
* **2026-02-20**: Add `cascade`
* **2026-01-30**: Enforce `camelCase`, not `snake_case` for query parameters
* **2026-01-21**: Add new terms `purgeTime` and `show_deleted`.
* **2026-01-20**: Add rationale for `createdTime` over `createdAt`.
* **2026-01-13**: Initial creation, adapted from [Google AIP-148][] and aep.dev [AEP-148][].

[Google AIP-148]: https://google.aip.dev/148

[AEP-148]: https://aep.dev/148
