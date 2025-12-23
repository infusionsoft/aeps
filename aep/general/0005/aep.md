# Designing an API

This AEP serves as a high-level guide for designing AEP-compliant APIs.

## Process summary

1. Enumerate the use cases you would like your API to satisfy.
2. Identify resources.
3. Identify standard operations.
4. Identify custom operations.

## Enumerate use cases

The first step in designing an API is understanding precisely what operations
you would like your user to be able to perform. Enumerate these operations,
attempting to be as granular as possible.

For example, if the API is for VM management in a public cloud, the operations
may include:

- Create a VM.
- List all VMs owned by a company.
- List all VMs owned by a user.
- Restart a running VM.

Or for a multiplayer online game, operations may include:

- Proposing a trade to another player.
- Accepting a proposed trade.
- Find open trade offers containing an item.
- List items in a player's inventory.

Some best practices:

- Attempt to define granular use cases that can be composed to satisfy more
  complex use cases.
- Be comprehensive and consider lower-priority use cases: having more use cases
  enumerated often leads to better API design.

## Identify resources

Once your use cases are defined, consider how to represent those as resources: entities that are created, read, updated,
and deleted.

Examples include:

- users
- virtual machines
- load balancers
- services

One of the core concepts described by the AEPs is resource-oriented design:
this design paradigm allows for uniform standard operations that reduce the
cognitive overhead in learning about the operations and schemas exposed by your
API.

Resources can relate to each other. For example:

- A parent-child relationship defining ownership/scope (A user who created a VM).
- A resource dependency, where one resource depends on another to function (A VM depending on a disk).

See the following AEPs to learn more about resource-oriented design:

- [resource-oriented design][aep-121]
- [resource paths][aep-122]

## Identify standard operations

Once the resources are defined, identify one or more standard operations for each of those resources. Standard
operations perform actions on resources by creating, reading, updating, deleting, and listing them. Each of these
operations maps to a specific HTTP verb (`POST`, `GET`, `PUT`, `PATCH`, `DELETE`). See the [standard methods][aep-130]
AEP to learn more.

APIs **should** use standard methods whenever possible. However, there are cases where custom methods are more
appropriate.

## Identify custom operations

As mentioned above, in some cases, it may be more appropriate to define a custom method rather than using a standard
method. Some examples include:

- restarting a virtual machine
- bulk create and update operations
- simple state changes

Break down each of the actions into granular operations, then follow the
[custom operations][aep-136] AEP on how to design them.

## Changelog

- **2025-10-30**: Initial AEP-5 for Thryv, adapted from aep.dev [AEP-5][].

[AEP-5]: https://aep.dev/5
