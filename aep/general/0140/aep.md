# JSON Payloads

The most common way APIs exchange structured data with clients is using JSON payloads. Consistent rules for how JSON is
shaped, encoded, and interpreted are essential for interoperability, long-term stability, and ease of use across clients
and services. This AEP defines the conventions and constraints APIs must follow when producing and consuming JSON
payloads.

## Guidance

JSON **must** be well-formed and compliant with [RFC 8259].

JSON payloads:

* **must** use [UTF-8 encoding](https://datatracker.ietf.org/doc/html/rfc8259#section-8.1)
* **must** consist of [valid Unicode characters](https://datatracker.ietf.org/doc/html/rfc8259#section-8.2)
    * Characters **should** be escaped _only as required by JSON_
    * Implementations **should** prefer literal Unicode characters over `\uXXXX` escapes when possible
* **must** be conveyed with `Content-Type: application/json`
    * APIs **must** accept `application/json` with optional parameters (e.g., `; charset=utf-8` or `; profile=...`)
    * The `charset` parameter **should** be omitted in responses (as UTF-8 is the default), but other parameters **may**
      be included if required for the use case
* **must** contain only unique member names (no duplicate names)
* **must not** rely on member ordering (JSON objects are unordered per [RFC 8259])
* **must not** contain comments
* **should not** contain trailing commas

APIs **must** ignore unknown fields in JSON request bodies.

### Keys

JSON keys **must** be `camelCase` and **should** avoid special characters.

### Naming patterns

**Important:** **_API fields are not database columns!_** API fields **must not** be tied to database column names.
Exposing an API that is identical to the database schema is an antipattern; it tightly couples the public interface to
internal implementation details. APIs **must** provide a stable, consumer-oriented representation of the data, even if
it requires mapping or transformation from the storage layer.

To ensure consistent semantics across fields, APIs **should** follow these naming patterns:

* **Timestamps**: Use the suffix `Time` (e.g., `expireTime`, `publishTime`). See [Time and duration] for format
  requirements.
* **Dates**: Use the suffix `Date` (e.g., `birthDate`, `usageDate`). See [Time and duration] for format requirements.
* **Booleans**: Use the prefix `is` (e.g., `isActive`, `isDefault`).
* **Quantities**: Use the suffix `Count` (e.g., `itemCount`, `retryCount`).
* **Identifiers**: Use the suffix `Id` (e.g., `publisherId`, `authorId`). These **must** be strings.
    * The resource's own unique identifier **must** be named `id`. The `{resource}Id` pattern is used for referencing
      _other_ resources.

Initialisms **must** be treated as words in `camelCase`:

* `userId`, not `userID`
* `apiKey`, not `APIKey`
* `url`, not `URL`

### Standard fields

To ensure consistency across the API ecosystem, APIs **should** use the standard field names defined
in [Standard Names] for common terms.

### Values and types

A JSON value **must** be one of the following:

* object
* array
* number
* string
* the literal values `true`, `false`, or `null`
    * Literal values **must** be lowercase. No other literal names are allowed.

Field types **must** be stable over time. Do not return a string sometimes and an object other times under the same key.

### Null fields

Fields **may** be documented as nullable. If a field is nullable, APIs **must** be prepared to handle `null` values. If
an API accepts `null` for a field, the meaning of `null` **must** be explicitly documented (for example, whether it
represents "clear the value" vs. "unknown/not specified").

Fields **may** be documented as non-nullable. If a non-nullable field is missing in the request, APIs **must** return
`400 Bad Request`.

For create (`POST`) and full-replacement updates (`PUT`), omitted fields **should** be interpreted as "not provided".
The API **may** apply a default value (which may be `null` or some other value).

For clearing fields in partial updates, see [Field Masking](/134#field-masking).

### Identifiers

All identifiers, regardless of format or generation strategy, **must** be represented as strings.

### Booleans

Boolean values **must** be represented using the JSON literals `true` and `false`. Booleans **must not** be encoded as
strings (`"yes"`/`"no"`, `"true"`/`"false"`) or numbers (`1`/`0`).

Correct:

```json
{
  "isEnabled": true,
  "isDefault": false
}
```

Incorrect:

```json
{
  "isEnabled": "true",
  "isDefault": 0,
  "isAvailable": "yes"
}
```

### Enumerations

Enum values **must** be uppercase `strings`. Numeric enums **should not** be used. See [Enumerations].

### Collections

Arrays **should** contain elements of the same logical type.

Empty collections **must** be represented as `[]` (an empty array), not `null`. APIs **must not** return `null` for an
empty or missing collection. If a collection is not applicable to a specific resource, the key **should** be entirely
omitted from the payload.

List endpoints **must** include pagination metadata in an envelope object, see [Pagination].

Example:

```json
{
  "tags": [],
  "comments": [
    {
      "id": "123"
    },
    {
      "id": "456"
    }
  ]
}
```

### Time and duration

All representations of dates, timestamps, and time intervals in JSON payloads **must** follow the standards defined
in [Time and duration].

### Numbers

In most environments, JSON numbers are parsed
as [IEEE‑754 double precision](https://en.wikipedia.org/wiki/Double-precision_floating-point_format) values.

* APIs **must not** produce or accept non-finite values (such as `NaN`, `Infinity`, or `-Infinity`), even if supported
  by the underlying serializer or language.
* APIs **should** avoid numeric representations that can lead to precision loss.
* Identifiers or values requiring full precision (e.g., 64‑bit integers, [money](#money)) **must** be represented as
  strings.

Correct:

```json
{
  "count": 42,
  "percentage": 99.9,
  "veryLargeNumber": "9007199254740993"
}
```

Incorrect:

```json
{
  "veryLargeNumber": 9007199254740993,
  "score": NaN,
  "limit": Infinity
}
```

### Money

Monetary values **must** be represented as objects with explicit `currency` and `amount` fields. The `amount` **must**
be represented as a decimal string. Floating‑point numbers **must not** be used for monetary amounts. APIs **may**
include additional fields (e.g., `displayAmount`, `formatted`, `symbol`) as needed for their use case.

Example:

```json
{
  "amount": "12.34",
  "currency": "USD"
}
```

### Error payloads

Error responses **must** follow the standard error payload format. See [Errors] for details.

### Internationalization

APIs **must** use [BCP 47 tags] (e.g., `en-GB`, `bg`, `zh-Hant-TW`) when representing locales or language tags in
payloads.

Example:

```json
{
  "language": "en-US",
  "locale": "zh-Hant-TW"
}
```

## Rationale

Why `camelCase`?

Most OpenAPI tooling and JSON client code generators default to `camelCase`, particularly in JavaScript and TypeScript
ecosystems. Aligning with this convention reduces friction when generating clients and mapping payloads to native data
structures, and it matches the property-naming style used by many commonly used programming languages.

Why IDs as strings?

Representing identifiers as strings prevents precision loss in languages and databases that cannot safely round-trip
64-bit integers. It also decouples the API contract from the underlying ID generation strategy, allowing implementations
to change formats (UUIDs, ULIDs, database sequences, or composite identifiers) without breaking clients.

Why use strings for currency amount?

Floating-point numbers cannot precisely represent many decimal fractions, which can lead to rounding errors in monetary
calculations. These errors accumulate over time and can result in incorrect totals, balances, or comparisons. Using
decimal values encoded as strings preserves exactness across systems and programming languages. This ensures consistent
and predictable handling of money regardless of client or backend implementation.

Why `createdTime` over `createdAt`?

It avoids the natural language ambiguity while remaining slightly more "standard" for REST APIs than the more
database-centric `createdTimestamp`.

## Further reading

* [RFC 8259] The JavaScript Object Notation (JSON) Data Interchange Format
* [RFC 3339] Date and Time on the Internet: Timestamps
* [RFC 5646](https://datatracker.ietf.org/doc/html/rfc5646) Tags for Identifying Languages

[RFC 8259]: https://datatracker.ietf.org/doc/html/rfc8259

[RFC 3339]: https://datatracker.ietf.org/doc/html/rfc3339

[BCP 47 tags]: https://developer.mozilla.org/en-US/docs/Glossary/BCP_47_language_tag

[Enumerations]: /enumerations

[Pagination]: /pagination

[Errors]: /errors

[Time and duration]: /time-and-duration

[Standard Names]: /standard-names

## Changelog

* **2025-12-16**: Initial creation
