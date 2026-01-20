# Precedent

Many times, APIs are written in ways that do not match new guidance that is
added to these standards after those APIs have already been released.
Additionally, sometimes it can make sense to intentionally violate standards
for particular reasons, such as maintaining consistency with established
systems, meeting stringent performance requirements, or other practical
concerns. Finally, as carefully as everyone reviews APIs before they are
released, sometimes mistakes can slip through.

Since it often is not feasible to fix past mistakes or make the standards serve
every use case, APIs may be stuck with these exceptions for quite some time.
Further, since new APIs often base their designs (names, types, structures,
etc.) on existing APIs, it is possible that a standards violation in one API
could spill over into other APIs, even if the original reason for the exception is
not applicable to the other APIs.

As a result of this problem, it is important to "stop the bleeding" of these
standards exceptions into new APIs and additionally document the reasons for
each exception so that historical wisdom is not lost.

## Guidance

If an API violates "**should**" or "**should not**" AEP guidance for any
reason, there **must** be an internal comment linking to this document to ensure others do not copy
the violations or cite the errors as precedent of a "previously approved API".

**Important:** APIs **must not** violate guidance specified with "**must**" or
"**must not**", even with a link to this AEP. Tools such as documentation
generators and client generators **may** assume full compliance with "**must**"
and "**must not**" guidance.

The comment should also include an explanation of what violates standards and
why it is necessary. For example:

```java
class DailyMaintenanceWindow {
    /**
     * Time within the maintenance window to start.
     * Format: "HH MM" (e.g., "22 00")
     */
    // <link to doc>: This was designed for consistency with a legacy
    // crontab-style internal system.
    // Ordinarily, this should follow RFC 3339 'time' (HH:MM:SSZ).
    String startTime;

    /**
     * Duration of the time window.
     */
    // <link to doc>: This field uses ISO 8601 strings (e.g., PT1H).
    // Ordinarily, this should be an integer 'durationSeconds' or an
    // 'endTime' timestamp per our AEP duration guidelines.
    String duration;
}
```

**Important:** APIs should only be considered to be precedent-setting if they are in beta or GA.

### Local consistency

If an API violates a standard throughout, it would be jarring and frustrating
to users to break the existing pattern only for the sake of adhering to the
global standard.

For example, if all of an API's resources use `creationTime` (instead of the
standard field `createdTime` described in AEP-107), a new resource in that API
should continue to follow the local pattern.

However, others who might otherwise copy that API should be made aware that
this is contra-standard and not something to cite as precedent when launching
new APIs.

```java
public class Book {
    // <link to doc>: This API uses snake_case for legacy reasons. 
    // Ordinarily, we use default camelCase for all new REST APIs.
    @JsonProperty("published_at")
    private OffsetDateTime publishedAt;
}

public class Author {
    // <link to doc>: 'Book' used snake_case, so we match that here 
    // for local consistency. Ordinarily, this would be 'publishedAt'.
    @JsonProperty("published_at")
    private OffsetDateTime publishedAt;
}
```

### Pre-existing functionality

Standards violations are sometimes overlooked before launching, resulting in
APIs that become stable and therefore cannot easily be modified. Additionally,
a stable API may pre-date a standards' requirement.

In these scenarios, it is difficult to make the API fit the standard. However,
the API should still cite that the functionality is contra-standard so that
other APIs do not copy the mistake and cite the existing API as a reason why
their design should be approved.

### Adherence to external spec

Occasionally, APIs must violate standards because specific requests are
implementations of an external specification (for example, OAuth), and their
specification may be at odds with AEP guidelines. In this case, it is likely to
be appropriate to follow the external specification.

### Adherence to existing systems

Similar to the example of an external specification above, it may be proper for
an API to violate AEP guidelines to fit in with an existing system in some way.
This is a fundamentally similar case where it is wise to meet the customer
where they are. A potential example of this might be integration with or
similarity to a partner API.

### Expediency

Sometimes there are users who need an API surface by a very hard deadline or
money walks away. Since most APIs serve a business purpose, there will be times
when an API could be better but cannot get it that way and into users' hands
before the deadline. In those cases, API review councils **may** grant
exceptions to ship APIs that violate guidelines due to time and business
constraints.

### Technical concerns

Internal systems sometimes have very specific implementation needs (e.g., they
rely on operation transforms that speak UTF-16, not UTF-8), and adhering to AEP
guidelines would require extra work that does not add significant value to API
consumers. Future systems which are likely to expose an API at some point
should bear this in mind to avoid building underlying infrastructure which
makes it difficult to follow AEP guidelines.

## Changelog

* **2025-12-22**: Initial creation
