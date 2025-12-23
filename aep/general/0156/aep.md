# Singleton resources

APIs sometimes need to represent a resource where exactly one instance of the
resource always exists within any given parent. A common use case for this is
for a config object.

## Guidance

An API **may** define _singleton resources_. A singleton resource **must**
always exist by virtue of the existence of its parent, with one and exactly one
per parent.

For example:

{% tab proto %}

{% tab oas %}

```yaml
components:
  schemas:
    Config:
      type: object
      properties:
        name:
          type: string
        # additional properties...
      required:
        - name
  parameters:
    user:
      in: path
      name: user
      required: true
      schema:
        type: string
```

The `Config` singleton would have the following methods:

```yaml
paths:
  users/{user}/config:
    get:
      operationId: getUserConfig
      parameters:
        - $ref: '#/components/parameters/user'
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Config'
    patch:
      operationId: updateUserConfig
      parameters:
        - $ref: '#/components/parameters/user'
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/Config'
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Config'
```

{% endtabs %}

- Singleton resources **must not** have a user-provided or system-generated ID;
  their [resource path][aep-122] includes the name of their parent followed by
  one static-segment.
    - Example: `users/1234/config`
- Singleton resources **must** be singular.
    - Example: `users/1234/thing`
- Singleton resources **may** parent other resources.
- Singleton resources **must not** define the [`POST`][aep-132], [`PUT`][aep-133], or
  [`DELETE`][aep-135] methods. The singleton is implicitly created or
  deleted when its parent is created or deleted.
- Singleton resources **should** define the [`GET`][aep-131] and
  [`PATCH`][aep-134] methods, and **may** define [custom methods] as
  appropriate.
    - However, singleton resources **must not** define the [`PATCH`][aep-134]
      method if all fields on the resource are output only.
- Singleton resources **may** be exposed as a collection to support [reading across collections]. See the example below.
    - The trailing segment in the path pattern that typically represents the
      collection **should** be the `plural` form of the Singleton resource e.g.
      `/v1/users/-/configs`.
    - If a parent resource ID is provided instead of the hyphen `-` as per
      AEP-159 (for example, `/users/123/configs`), then the service **should** return a collection of one Singleton
      resource corresponding to the specified parent resource.
    - The response **must** be wrapped in a [pagination] object, even if only one result is in the collection.

{% tab proto %}

{% tab oas %}

```yaml
components:
  schemas:
    UserConfigCollection:
      type: object
      properties:
        configs:
          type: array
          items:
            '$ref': '#/components/schemas/Config'

paths:
  users/-/configs:
    get:
      operationId: listUserConfigs
      # standard pagination parameters...
      responses:
        '200':
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/UserConfigCollection'
```

{% endtabs %}

## Rationale

### Support for Standard List

While Singleton resources are not directly part of a collection themselves,
they can be viewed as part of their parent's collection. The one-to-one
relationship of parent-to-singleton means that for every one parent there is
one singleton instance, naturally enabling some collection-based methods when
combined with the pattern of [Reading Across Collections][aep-159]. The
Singleton can present as a collection to the API consumer as it is indirectly
one based on its parent. Furthermore, presenting the Singleton resource as a
pseudo-collection in such methods enables future expansion to a real
collection, should a Singleton be found lacking.

## Changelog

* **2025-12-22**: Initial creation, adapted from [Google AIP-156][] and aep.dev [AEP-156][].

[Google AIP-156]: https://google.aip.dev/156

[AEP-156]: https://aep.dev/156

[custom methods]: /custom-methods

[reading across collections]: /reading-across-collections

[pagination]: /pagination
