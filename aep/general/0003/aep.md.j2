# AEP Versioning

The AEP (API Enhancement Proposals) specification evolves over time as API best practices advance and organizational
needs change. This document establishes how the AEP specification itself is versioned, ensuring clear expectations for
both specification maintainers and API developers who follow these guidelines.

## Major-only Versioning

AEPs will be published in versions, using major version numbering only (e.g., `v3`, `v4`).
[Non-breaking](#breaking-changes) updates **may** be applied directly to the current major version.

* There are two types of versions: **stable** versions which do not break compliance, and **preview** versions which
  represent the next major iteration.
* The naming of a stable version will be the major version (e.g. `v3`, `v4`).
* Upon promoting a preview version to a stable version, the next preview version will be created immediately (e.g.
  `v5-preview`).
* New major versions will be published approximately every 1 year.

Each major version represents a living specification that evolves over time within its [non-breaking](#breaking-changes)
change boundaries.

Each AEP **must** maintain a changelog documenting all modifications (including typos, grammar fixes, etc.). The
Changelog **must** contain:

* Date of change
* Description of what was added, modified, or clarified
* Whether the change was additive or clarifying in nature

## Breaking changes

A breaking change is a change to the specification that would result in one of the following:

- A change which could cause a previously compliant API to become non-compliant.
- A change which would break client functionality that was leveraging guidance explicitly stated in the specification.

A new AEP major version **may** have breaking changes.

The AEP specification will generally strive to minimize breaking changes across versions.

Changes that may be applied to the current major version without creating a new version:

* Correcting typos and grammatical errors
* Fixing broken links or references
* Clarifying ambiguous wording without changing the underlying requirement
* Formatting improvements
* Styling improvements
* Entirely new AEPs on topics not previously covered that do not change requirements
* Optional guidance that APIs may choose to adopt
* Additional examples or clarifications that do not change requirements
* Recommended (but not required) patterns

Not allowed (requires major version):

* **Any change that would require a compliant API to be modified to remain compliant**
* Adding new required fields, patterns, or behaviors to existing guidance
* Changing the interpretation of existing requirements, even if the change seems additive
* Adding guidance that could conflict with implementations of existing AEPs

**Important:** If an API is compliant with `v3` today, it **must** remain compliant with `v3` tomorrow after any
updates, without requiring modifications.

## Preview versions

There **must** be exactly one preview version active at any time, representing the next major version before it is
stabilized.

* Named using the format `v{MAJOR}-preview` (e.g., `v5-preview`)
* May change at any time without notice
* Accumulates proposed breaking changes for the next major release
* Not subject to the stability guarantees of stable versions
* When a new stable version is released, the next preview version is created immediately

**Note:** APIs **may** adopt the preview version to provide early feedback, **_BUT DO SO AT THEIR OWN RISK AS THE
SPECIFICATION MAY CHANGE WITHOUT NOTICE_** before stabilization.

## Lifecycle

New major versions will be published approximately every 1 year. When a new major version is released:

1. The previous major version is frozen (no further updates, for any reason, can be made)
2. The new major version is created as a copy of the old with breaking changes applied
3. The new major version becomes the living specification
4. A new preview version is created for the next major version

If the new AEP version introduces guidance that requires breaking changes to implement (such as renaming standard fields
or changing response structures), teams will need to cut a new major version of their API. In these cases, standard API
versioning practices apply. See AEP-4 for guidance on managing API versioning.

* New APIs **must** use the latest AEP version
* Existing APIs **must** migrate to the new version as soon as practical

APIs **should** prioritize adoption of new AEP versions in their planning and roadmaps. While we recognize that
immediate migration may not be feasible due to resource constraints, release schedules, or other priorities, teams
should actively work toward upgrading rather than waiting indefinitely.

APIs **should not** defer AEP upgrades until they happen to need a breaking change for other reasons. Adopting new AEP
versions should be treated as a proactive improvement, not a side effect of unrelated work.

## Rationale

### Balancing stability and evolution

We determined that a purely immutable specification (where even typos require a new version) prevents valuable
clarifications from reaching developers quickly. Conversely, a constantly shifting specification breaks compliance.
Therefore, we adopted a hybrid approach: Major Versions provide a stability guarantee: "If it complies today, it
complies tomorrow." Living Specs allow non-breaking improvements (new patterns, clarifications) to land immediately,
ensuring the spec remains relevant without forcing teams to constantly upgrade their version numbers.

### Why version AEPs

The AEPs have the goal to provide a set of modern best practices for APIs.

Best practices are constantly evolving and may contradict older best practices, and therefore result in a breaking
change. These breaking changes can be difficult for services producing these APIs to adopt.

A versioned system will help provide clear expectations around the cadence in which breaking changes could be
introduced.

### Why major versions only

Using only major version numbers simplifies the versioning scheme while still providing the necessary guarantees. The
key insight is that what matters most is whether a change is breaking or non-breaking, not how many non-breaking changes
have accumulated. Semantic versioning (`major.minor.patch`) would require:

* Creating new directory copies for minor and patch versions (e.g., `v3.1.0`, `v3.2.2`)
* Additional complexity tracking which minor version an API follows
* More frequent file duplication even for small changes like typos

### Why no AEP-level support windows

Unlike API versions, AEP specification versions do not have prescribed support windows or deprecation timelines.
However, this does not mean teams can indefinitely defer upgrades. When a new major AEP version is released with
breaking changes, existing APIs don't suddenly break or become non-functional. They continue to operate correctly; they
simply follow older design guidelines. Teams should prioritize adopting new AEP versions as part of their regular
planning and improvement cycles. Waiting for "the right time" or deferring until other breaking changes are needed is
discouraged. New AEP versions represent improved best practices and should be treated as valuable upgrades worth
pursuing independently.

By not imposing rigid timelines at the AEP level, we acknowledge that teams have varying priorities and constraints.
However, this flexibility comes with the expectation that teams will actively work toward adoption rather than
indefinitely maintaining old versions. The goal is steady progress, not indefinite stagnation.

### Why APIs are versioned separately

Although APIs are expected to support recent AEP versions and could have a similar versioning scheme, they may also need
to introduce breaking changes for a variety of reasons unrelated to a new AEP version.

This necessitates the ability to express these changes to consumers. As such, decoupling the client version from the AEP
versions is a critical requirement.

See AEP-4 for the API versioning strategy.

## Changelog

**2025-11-21**: Initial creation, adapted from [Google AIP-3] and aep.dev [AEP-300].

[Google AIP-3]: https://google.aip.dev/3

[AEP-300]: https://aep.dev/300
