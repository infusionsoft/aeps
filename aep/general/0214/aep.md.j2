# Resource expiration

Customers often want to provide the time that a given resource or resource
attribute is no longer useful or valid (e.g. a rotating security key).
Currently, we recommend that customers do this by specifying an exact
"expiration time" into a [Timestamp] `expireTime` field; however, this adds
additional strain on the user when they want to specify a relative time offset
until expiration rather than a specific time until expiration.

Furthermore, the world understands the concept of a "time-to-live", often
abbreviated to TTL, but the typical format of this field (an integer, measured
in seconds) results in a subpar experience when using an auto-generated client
library.

## Guidance

1. APIs wishing to convey an expiration **must** rely on a [Timestamp] field
   called `expireTime`.
2. APIs **may** use domain-specific field names when the semantics differ from
   general expiration (e.g., `purgeTime` for soft-deleted resources in AEP-164,
   `tokenExpireTime` for credentials with multiple expiration semantics, etc.).
3. APIs wishing to allow a relative expiration time **must** define both the
   `expireTime` field and a separate `ttlSeconds` field (integer, measured in seconds),
   the latter marked as write-only (input only).
4. APIs **must** always return the expiration time in the `expireTime` field
   and **must not** return the `ttlSeconds` field when retrieving the resource.
5. APIs **must** require exactly one of `expireTime` or `ttlSeconds` on input when
   both are supported. If both are provided, the API **must** return [400 Bad Request].
6. APIs that rely on the specific semantics of a "time to live" (e.g., DNS
   which must represent the TTL as an integer) **may** use only a `ttlSeconds`
   field (and **should** provide a [precedent](/precedent) comment in
   this case).

### Example

{% tab proto %}

{% tab oas %}

```yaml
schema:
  type: object
  properties:
    expireTime:
      type: string
      format: date-time
      description: >
        Timestamp in UTC of when this resource is considered expired. This is
        *always* provided on output, regardless of what was sent on input.
    ttlSeconds:
      type: integer
      format: int64
      description: >
        The TTL for this resource, in seconds from the current time.
        Input only - never returned in responses.
      writeOnly: true
  oneOf:
    - required:
        - expireTime
    - required:
        - ttlSeconds
```

{% endtabs %}

## Further reading

- For soft delete purging, see AEP-164
- For duration field formatting, see AEP-142

## Rationale

### Alternatives considered

#### A new standard field called `ttl`

We considered allowing a standard field called `ttl` as an alternative way of
defining the expiration, however doing so would require that API services
continually update the field, like a clock counting down. This could
potentially cause problems with the read-modify-write lifecycle where a
resource is being processed for some time, and effectively has its life
extended as a result of that processing time.

#### Always use `expire_time`

This is the current state of the world with a few exceptions. In this scenario,
we could potentially push the computation of `now + ttl = expire_time` into
client libraries; however, this leads to a somewhat frustrating experience in
the command-line and using REST/JSON. Leaving things as they are is typically
the default, but it seems many customers want the ability to define relative
expiration times as it is quite a bit easier and removes questions of time
zones, stale clocks, and other silly mistakes.

## Changelog

* **2026-01-22**: Initial creation, adapted from [Google AIP-214][] and aep.dev [AEP-214][].

[Google AIP-214]: https://google.aip.dev/214

[AEP-214]: https://aep.dev/214

[Timestamp]: /time-and-duration

[400 Bad Request]: /63#400-bad-request
