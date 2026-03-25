# Organization ID

**Note:** This AEP standardizes on the term "organization ID" for the concept
of tenancy. To keep this document simple and consistent, it uses _only_ the
"organization ID" terminology, although the industry standard term is "tenant".

Some endpoints are **organization-scoped**, meaning requests operate within the
context of a specific organization instance. One organization instance cannot
access data from other organizations. An **organization** represents an
isolated instance of the application with its own data, users, and
configuration.

## Guidance

API code and interfaces **must** refer to this concept as "organization ID".
The following terms have historically referred to the same concept and are now
deprecated in code and interface definitions:

- Tenant
- Tenant Name
- Tenant ID
- App
- App Name
- App ID
- Account
- Account Name
- Account ID

API code **should not** use deprecated terms, and **must not** introduce any
new alternate terms for this concept.

When represented in API fields or parameters, APIs **must** use the standard
identifier `organizationId`, formatted according to each location's naming
convention:

| Location        | Form                                                        |
| --------------- | ----------------------------------------------------------- |
| Path parameter  | `{organizationId}`                                          |
| Query parameter | `organizationId`                                            |
| JSON field      | `organizationId` (or `organizationIds` for repeated values) |
| Header          | `Organization-ID` (legacy only; see below)                  |

### Organization-scoped endpoints

Organization-scoped endpoints are endpoints where each request operates within
exactly one organization context.

For organization-scoped endpoints, organization ID **must** be accepted in
exactly one location per request. An endpoint **must not** define organization
ID in more than one location.

_New_ services **must not** place organization ID in a header. _New_ services
**should** place organization ID in the path as `{organizationId}`. A non-path
location, such as the request body or a query parameter, **may** be used where
it is more appropriate, but **must** provide justification as per AEP-200.

Existing services that already accept organization ID via a header are not
required to migrate immediately, but **should** plan migration to path-based
organization scoping in the next major API release for that service. Until
migration is complete, the header **must** be named `Organization-ID`.

### Non-organization-scoped endpoints

Non-organization-scoped endpoints are endpoints that do not operate within a
single organization context.

When a non-organization-scoped endpoint requires one or more organization IDs,
the endpoint **must** use the standard names (`organizationId`,
`organizationIds`, etc.) and **may** place them where best suited to the use
case. A header **must not** be used.

## Rationale

Standardizing on a single term reduces confusion during onboarding, improves
searchability across documentation and tooling, and prevents divergence across
teams working on the same platform.

Requiring organization ID in exactly one location per request prevents
ambiguity and eliminates a class of subtle authorization bugs that arise when
two locations carry conflicting values.

Discouraging header usage reflects a gradual migration away from legacy
patterns while keeping existing services functional during the transition.

## Changelog

- **2026-03-25**: Clarify "tenant" vs. "organization ID" terminology.
- **2026-03-11**: Initial creation.
