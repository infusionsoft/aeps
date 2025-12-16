# Enumerations

It is common for a field to only accept or provide a discrete and limited set
of values. In these cases, it can be useful to use enumerations (generally
abbreviated "enums") in order to clearly communicate what the set of allowed
values are.

## Guidance

APIs **may** expose enum objects for sets of values that are expected to change
infrequently:

```java
// Possible formats in which a book may be published.
public enum Format {
    // The printed format, in hardback.
    HARDBACK,

    // The printed format, in paperback.
    PAPERBACK,

    // An electronic book format.
    EBOOK,

    // An audio recording.
    AUDIOBOOK
}
```

- All enum values **should** use a consistent case format across an API.
- Enums **should** document whether the enum is frozen or they expect to add
  values in the future.
- String fields with enumerated values **should** use uppercase `SNAKE_CASE`.

### When to use enums

Enums can be more accessible and readable than strings or booleans in many
cases, but they do add overhead when they change. Therefore, enums **should**
receive new values infrequently. While the definition of "infrequently" may
change based on individual use cases, a good rule of thumb is no more than once
a year. For enums that change frequently, the API **should** use a string and
document the format.

**Note:** If an enumerated value needs to be shared across APIs, an enum
**may** be used, but the assignment between enum values and their wire
representation **must** match.

### Alternatives

Enums **should not** be used when there is a competing, widely adopted standard
representation (such as with [language codes][bcp-47] or [media types]).
Instead, that standard representation **should** be used. This is true even if
only a small subset of values are permitted, because using enums in this
situation often leads to frustrating lookup tables when trying to use multiple
APIs together.

For enumerated values where the set of allowed values changes frequently, APIs
**should** use a `string` field instead, and **must** document the allowed
values.

To document allowed values on a `string` field in Java, use the `allowableValues` parameter of the `@Schema` OpenAPI
annotation.

```java

@Schema(type = "string", allowableValues = {"hardback", "paperback", "audiobook"})
String format;
```

### Compatibility

Adding values to an enum has the potential to be disruptive to existing
clients. Consider code written against the `Format` enum in an earlier version
where only the first two options were available:

```typescript
switch (book.format) {
  case Format.Hardback:
    // Do something...
    break;
  case Format.Paperback:
    // Do something...
    break;
  default:
    // When new enum values are introduced, pre-existing client code may
    // throw errors or act in unexpected ways.
    throw new Error('Unrecognized value.');
}
```

Services **may** add new values to existing enums; however, they **should** add
enums carefully; think about what will happen if a client system does not know
about a new value.

## Interface Definitions

{% tab proto %}

{% tab oas %}

{% sample 'enum.oas.yaml', '$.components.schemas.Book.properties.format.enum' %}

- Enumerated fields **should** be strings.
- If the enum is optional, `null` **should** be used as the empty value.

**Note:** If `null` is a valid value, OpenAPI 3.0 also requires that
`nullable: true` is specified for the field.

{% endtabs %}

## Further reading

- For states, a special type of enum, see AEP-216.

[bcp-47]: https://en.wikipedia.org/wiki/IETF_language_tag

[media types]: https://en.wikipedia.org/wiki/Media_type

## Changelog

* **2025-12-03**: Add a Java example on how to document string enums.
* **2025-11-10**: Initial AEP-126 for Thryv, adapted from [Google AIP-126][] and aep.dev [AEP-126][].

[Google AIP-126]: https://google.aip.dev/126

[AEP-126]: https://aep.dev/126
