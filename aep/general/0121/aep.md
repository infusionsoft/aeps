# Resource-oriented design

Resource-oriented design is a pattern for specifying [REST] APIs, based on the
following high-level design principles:

- The fundamental building blocks of an API are individually named _resources_
  (nouns) and the relationships and hierarchy that exist between them.
- A small number of standard _methods_ (verbs) provide the semantics for most
  common operations. When the standard methods do not fit, custom methods may
  be introduced.

These principles align with core [REST] concepts such as resources, uniform
interface, and representations. This AEP focuses on applying resource-oriented
design to REST APIs.

## Guidance

When designing a REST API, consider the following:

- The resources (nouns) the API will expose.
- The relationships and hierarchies between those resources.
- The schema (representation) of each resource.
- The methods (HTTP verbs) each resource supports, relying as much as possible
  on the standard verbs.

### Resources

A resource-oriented REST API **must** be modeled as a resource hierarchy, where
each node is either a simple resource or a collection of resources.

A collection contains resources of _the same type_. For
example, a publisher has the collection of books that it publishes. A resource
usually has fields, and resources may have any number of sub-resources (usually
collections).

REST APIs **should** model a domain through resources (things/nouns) rather than operations (actions/verbs). Think of
resources as entities or objects that can be manipulated, not as procedures to be invoked. This approach provides:

* Predictable patterns: Clients can apply the same mental model across different resource types.
* Composability: Resources can be combined and nested in intuitive ways.
* Discoverability: A well-designed resource hierarchy is self-documenting.

**Important:** While there is some conceptual alignment between storage systems and
APIs, a service with a resource-oriented API is not necessarily a database and
has enormous flexibility in how it interprets resources and methods. API
designers **should not** expect that their API will be reflective of their
database schema. In fact, having an API that is identical to the underlying
database schema is actually an antipattern, as it tightly couples the surface
to the underlying system.

### Methods

Resource-oriented REST APIs emphasize resources (data model) over the methods
performed on those resources (functionality). A typical REST API exposes a large
number of resources with a small number of methods on each resource. The
methods can be either the [standard methods] or carefully designed [custom methods].

If the request to, or the response from, a standard method (or a custom method in
the same _service_) **is** the resource or **contains** the resource, the
resource schema for that resource across all methods **must** be the same.

A resource **must** support at minimum [GET][]: clients must be able to
validate the state of resources after performing a mutation such as creation,
updates, or deletes.

APIs **must** also support listing collections of resources, except for singleton resources
where more than one resource is not possible.

In REST, APIs **must not** invent new HTTP methods. When operations do not cleanly map to these standard verbs applied
to resources, APIs **may** use custom methods, but APIs **should** strongly prefer standard methods and reified
resources over custom methods. For detailed guidance on designing custom methods, see AEP-136.

### Reification

When an operation feels like a verb (e.g., "calculating," "importing," "deploying"), APIs **should** model the process
or result of that action as a resource rather than using a custom method. This technique, known as [reification], allows
standard CRUD patterns to be applied to complex operations.

For example, instead of an RPC-style endpoint like `POST /run-import` or a custom method like `POST /data:import`, model
the import as a resource: `POST /imports`. This approach provides several benefits:

* State tracking: Clients can use `GET /imports/{id}` to monitor progress or retrieve errors.
* Audit trail: Clients can use `GET /imports` to view a history of past operations.
* Standard semantics: The operation follows predictable REST patterns that clients already understand.
* Queryability: Clients can filter, sort, and paginate through operations using standard list operations.
* Consistency: The API surface remains uniform rather than accumulating dozens of custom methods with unique behaviors.

Common examples of reified resources include `/imports`, `/exports`, `/shipments`, `/deployments`, `/calculations`, and
`/scans`.

However, strict adherence to "everything is a resource" is not always practical. Consider the difference between a
simple state change and a tracked process. For something like "canceling an order":

* Resource approach: `POST /orders/{id}/cancellations`. This is useful when tracking _who_ canceled the order, _why_ it
  was canceled, or when the cancellation requires an approval workflow.
* Custom method approach: `POST /orders/{id}:cancel`. This is appropriate when the action is a simple state transition
  with no additional data or history requirements.

If an operation is instantaneous, has no state, and leaves no trace, a custom method **may** be appropriate. However, if
tracking _who_ performed the action, _when_ it happened, or its _status_ is necessary, the operation **should** be
reified as a resource.

### Strong Consistency

Changes **should** be visible immediately after an operation completes.

A method is strongly consistent if changes are immediately visible after an operation completes. When you create,
update, or delete a resource, any subsequent GET request **should** reflect that change until another modification is
made.

User-settable fields (fields that clients provide) **must** return the same value on all subsequent requests after an
operation completes, until another mutation changes the resource.

Output-only fields (system-managed fields like `createdTime`, `state`, or IDs) **should** also return
consistent values after an operation completes.

- However, there's an exception for fields that represent "live state" that takes significant time to stabilize (for
  example, a field tracking the instantiation status of a VM cluster that takes an hour to fully provision).

Examples of strong consistency include:

- Following a successful create that is the latest mutation on a resource, a `GET` request for a resource **must**
  return the resource.
- Following a successful update that is the latest mutation on a resource, a `GET` request for a resource **must**
  return the final values from the update request.
- Following a successful delete that is the latest mutation on a resource, a `GET` request for a resource **must**
  return `NOT_FOUND` (or the resource with the `DELETED` state value in the case of soft delete, if applicable)

**Why strong consistency matters**:

Clients often need to perform multiple operations in sequence (for example, create resource A, then create resource B
that depends on A). Strong consistency ensures that when an operation completes, clients can immediately proceed to the
next step without worrying whether their changes are visible yet.

Output-only fields ideally follow the same guidelines, but since these fields often represent a resource's live state,
they may sometimes need to change after a mutation operation to reflect ongoing state transitions.

### Cyclic References

Don't make resources that reference each other in circles; it makes CRUD operations unnecessarily complex.

The relationship between resources, such as parent-child or resource references, **must** be representable via
a [directed acyclic graph][]. In simpler terms: APIs **must not** design resources that reference each other in circles.

**Why circular references are problematic**:

Cyclic relationships make resource management unnecessarily complex. Consider two resources, A and B, that need to
reference each other:

1. Create resource A without a reference to B (because B doesn't exist yet). Get A's ID.
2. Create resource B with a reference to A. Get B's ID.
3. Update resource A to add the reference to B.

This requires three operations instead of two, just to create two related resources.

Deletion also becomes more complex because you must figure out which resource to dereference first for successful
deletion.

**Good alternatives to circular references**:

- Use parent-child relationships (one-way): `Order → Items`
- Use intermediate linking resources: `User → Membership ← Team`
- Allow cyclic relationships only in system-generated fields that clients don't manage

## Rationale

**Why reification over custom methods?**

The guidance to prefer reified resources over custom methods stems from the observation that most "actions" in a system
have state, history, or metadata that is valuable to track. By modeling these as resources:

* Clients gain visibility into the operation's lifecycle.
* The system maintains an audit trail automatically.
* Operations become queryable and manageable using standard patterns.
* The API remains consistent and predictable.

Custom methods should be reserved for truly stateless, instantaneous operations where no tracking is needed.

APIs that overuse custom methods become increasingly difficult to work with. A well-designed REST API should have far
more resources than custom methods. If your API has dozens of custom methods, it's likely straying from
resource-oriented principles and becoming an RPC API disguised as REST.

[create]: ./0133

[standard methods]: ./0130

[custom methods]: ./0136

[reification]: https://en.wikipedia.org/wiki/Reification_(computer_science)

[directed acyclic graph]: https://en.wikipedia.org/wiki/Directed_acyclic_graph

[get]: ./0131

[rest]: ./10

## Changelog

- **2025-12-09**: Initial creation, adapted from [Google AIP-121][] and aep.dev [AEP-121][].

[Google AIP-121]: https://google.aip.dev/121

[AEP-121]: https://aep.dev/121
