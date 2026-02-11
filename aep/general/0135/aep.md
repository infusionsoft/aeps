# Delete

In REST APIs, it is customary to make a `DELETE` request to a resource's URI
(for example, `/v1/publishers/{publisher_id}/books/{book_id}`) in order to
delete that resource.

Resource-oriented design (AEP-121) honors this pattern through the `Delete`
method. This method accepts the URI representing that resource and usually
returns an empty response.

## Guidance

APIs **should** generally provide a delete method for resources unless it is
not valuable for users to do so.

The Delete method **should** succeed if and only if a resource was present and
was successfully deleted. If the resource did not exist, the method **should**
send a `404 Not found` (`NOT_FOUND`) error.

The method **must** have [strong consistency][]: the completion of a delete
method **must** mean that the existence of the resource has reached a
steady-state and reading resource state returns a consistent `404 Not found`
(`NOT_FOUND`) response.

### Operation

Delete methods are specified using the following pattern:

### Requests

Delete methods implement a common request pattern:

- The HTTP verb **must** be `DELETE`.
- If a delete request contains a body, the body **must** be ignored, and **must
  not** cause an error (this is required by [RFC 9110][])
- The request **must not** require any fields in the query string. The request
  **should not** include optional fields in the query string unless described
  in another AEP.

### Errors

If the user does not have permission to access the resource, regardless of
whether or not it exists, the service **must** error with `403 Forbidden`
(`PERMISSION_DENIED`). Permission **must** be checked prior to checking if the
resource exists.

If the user does have proper permission, but the requested resource does not
exist, the service **must** error with `404 Not found` (`NOT_FOUND`).

### Soft delete

**Note:** This material was moved into its own document to provide a more
comprehensive treatment: AEP-164.

### Cascading delete

Sometimes, it may be necessary for users to be able to delete a resource as
well as all applicable child resources. However, since deletion is usually
permanent, it is also important that users not do so accidentally, as
reconstructing wiped-out child resources may be quite difficult.

If an API allows deletion of a resource that may have child resources, the API
**must** provide a `bool force` field on the request, which the user sets to
explicitly opt in to a cascading delete.

## Further reading

- For soft delete and undelete, see AEP-164.
- For bulk deleting large numbers of resources based on a filter, see AEP-165.

## Changelog

- **2024-02-11**: Imported from https://google.aip.dev/135

<!-- prettier-ignore-start -->











[strong consistency]: ./0121.md#strong-consistency
[etag]: ./0134.md#etags
[RFC 9110]: https://www.rfc-editor.org/rfc/rfc9110.html#name-delete
<!-- prettier-ignore-end -->
