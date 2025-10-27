# Time and duration

Many services need to represent the concepts surrounding time. Representing
time can be challenging due to the intricacies of calendars and time zones, as
well as the fact that common exchange formats (such as JSON) lack a native
concept of time.

## Guidance

Fields representing time **must** use a `string` field with values conforming
to [RFC 3339], such as `2012-04-21T15:00:00Z`.

**Note:** Date/time values in _HTTP headers_ are an exception to this rule; these
**should** use the HTTP-date format defined in [RFC 9110, Section 5.6.7].

Services **must** use appropriate [OpenAPI format indicators] for all date and
time fields.

### Timestamps

Fields that represent an absolute point in time **must** use a `string` field
with [RFC 3339] values. In OpenAPI, these fields **must** use `type: string` with
`format: date-time`.

These values **must** include an explicit timezone offset (`Z` or `±hh:mm`).
Services **should** default to UTC (`Z`) for timestamps unless preserving the
original offset is semantically meaningful for the business use case (such as
scheduling or local audit trails). Timestamps **must not** include non-standard
language-specific suffixes in the JSON string, such as the Java
`[America/New_York]` suffix. If a specific IANA timezone ID is required, it
**must** be provided in a separate field, such as `timeZone`.

These fields **should** have names ending in `Time`, such as `createdTime` or
`expireTime`. For array fields, the names **should** end in `Times`.

To maintain consistency with metadata fields like `createdBy` and `updatedBy`,
the fields `createdTime`, `updatedTime`, and `deletedTime` **must** use the past
tense. For all other timestamps, the field **may** be named using either the
root form of the verb (such as `expireTime` or `publishTime`) or the past tense
(such as `completedTime`), depending on which best conveys the field's intent.

Example:

```yaml
Book:
  type: object
  properties:
    createdTime:
      type: string
      format: date-time
      readOnly: true
      example: "2025-12-18T10:00:00Z"
    publishTime:
      type: string
      format: date-time
      description: "The scheduled time for the book to become available."
      example: "2025-12-25T09:00:00-05:00"
```

### Durations

Fields that represent a span between two points in time **should** be
represented as explicit start and end timestamps, such as `startTime` and
`endTime`.

If a single duration value better fits the use case, services **should** use an
`int` field representing a numeric count of a specific unit. The unit of
measurement **must** be explicitly included as a suffix in the field name, such
as `durationSeconds`, `retryIntervalMillis`, or `ttlSeconds`.

**Note:** A `float` field **may** be used if fractional seconds are needed.
However, only fractional seconds are permitted; other fractional units (such as
hours or days) **must not** be used.

Services **should not** use [ISO 8601] duration strings (such as `PT1H`)
unless required by an external specification or for compatibility with a
specific library.

Example:

```yaml
Session:
  type: object
  properties:
    startTime:
      type: string
      format: date-time
    endTime:
      type: string
      format: date-time
    ttlSeconds:
      type: integer
      description: "Remaining time before session expires."
      example: 3600
```

### Fractional seconds

Services **may** support fractional seconds for both timestamps and durations,
but **should not** support precision more granular than the nanosecond.
Services **may** also limit the supported precision, and **may** _truncate_
values received from the user to the supported precision.

**Note:** Truncation is recommended rather than rounding because rounding to
the nearest second has the potential to change day, month, year, etc., which is
surprisingly significant.

### Civil dates and times

Fields that represent a calendar date independent of a specific time (such as a
birthday) **should** use the `YYYY-MM-DD` format. In OpenAPI, these fields
**must** use `type: string` with `format: date`. These fields **should** have
names ending in `Date`, such as `birthDate`.

Fields that represent a "wall-clock" time independent of a specific date (such
as an opening hour) **should** use the `hh:mm:ss` format. To distinguish these
from absolute timestamps, these fields **should** have names ending in
`TimeOfDay`, such as `openingTimeOfDay`.

Example:

```yaml
Store:
  type: object
  properties:
    openingDate:
      type: string
      format: date
      example: "2025-06-01"
    openingTimeOfDay:
      type: string
      pattern: "^[0-9]{2}:[0-9]{2}:[0-9]{2}$"
      example: "09:00:00"
```

### Recurring time

A service that needs to document a recurring event **should** use cronspec if
cronspec is able to support the service's use case.

### Compatibility

Occasionally, APIs are unable to use RFC 3339 strings for legacy or
compatibility reasons. For example, an API may conform to a separate
specification that mandates that timestamps be Unix timestamp integers.

In these situations, fields **may** use other types. If possible, the following
naming conventions apply:

* Unix timestamps **should** use a `UnixTime` suffix.
    * Multipliers of Unix time (such as milliseconds) **should not** be used; if
      they are unavoidable, the field name **should** use both `UnixTime` and
      the unit, such as `unixTimeMillis`.
* For other integers, include the meaning (examples: `time`, `duration`,
  `delay`, `latency`) _and_ the unit of measurement (valid values: `seconds`,
  `millis`, `micros`, `nanos`) as a final suffix. For example,
  `sendTimeMillis`.
* For strings, include the meaning (examples: `time`, `duration`, `delay`,
  `latency`) but no unit suffix.

In all cases, clearly document the expected format, and the rationale for its
use.

## Rationale

Why avoid ISO 8601 duration?

This is to maximize developer productivity and ensure cross-platform predictability. While ISO 8601 strings are
syntactically standard, they lack native parsing support in many common environments; notably modern web browsers and
standard Go or Python libraries. This often requires additional third-party dependencies to handle. Furthermore, units
like "months" or "years" within these strings introduce calendar ambiguity that can lead to calculation errors across
client-server boundaries. By prioritizing explicit `startTime`/`endTime` pairs or unit-suffixed integers (e.g.,
`durationSeconds`), the API provides immediate clarity and allows developers to perform mathematical operations using
native numeric types without the overhead of complex string parsing.

[iso 8601]: https://www.iso.org/iso-8601-date-and-time-format.html

[rfc 3339]: https://datatracker.ietf.org/doc/html/rfc3339

[rfc 9110, section 5.6.7]: https://datatracker.ietf.org/doc/html/rfc9110#section-5.6.7

[OpenAPI format indicators]: https://swagger.io/docs/specification/v3_0/data-models/data-types/#strings

## Changelog

**2025-12-02**: Initial creation, adapted from [Google AIP-142][] and aep.dev [AEP-142][].

[Google AIP-142]: https://google.aip.dev/142

[AEP-142]: https://aep.dev/142
