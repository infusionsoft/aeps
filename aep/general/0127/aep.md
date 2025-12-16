# Content Negotiation & Media Types

APIs communicate with clients by exchanging representations of resources. The format of these representations is
specified using media types (also known as MIME types or content types). Properly handling content negotiation ensures
that clients and servers can agree on the format of data being exchanged.

## Guidance

### Default media type

APIs **must** support JSON as the default media type for both request and response bodies. JSON is widely supported,
human-readable, and has excellent tooling across all programming languages.

* Request bodies **should** use the media type `application/json`
* Response bodies **should** use the media type `application/json`
* If a client does not specify an `Accept` header, the API **must** default to `application/json`

See [JSON payloads] for guidelines.

### Character encoding

All text-based media types **must** use UTF-8 encoding. APIs **must** accept UTF-8 encoded request bodies. APIs
**should not** require clients to specify the charset, as UTF-8 is the default.

### Content-Type header

The `Content-Type` header indicates the media type of the request body sent by the client.

* Clients **must** include a `Content-Type` header when sending a request body
* Servers **must** validate that the `Content-Type` is supported for the endpoint
* If the server does not support the provided `Content-Type`, it **must** return `415 Unsupported Media Type`

Example:

```http request
POST /v1/publishers
Content-Type: application/json
```

### Accept header

The `Accept` header allows clients to specify which media types they can handle in the response.

* Clients **should** include an `Accept` header to indicate their preferred response format
* Servers **should** honor the `Accept` header when possible
* If the server cannot provide any of the requested media types, it **should** return `406 Not Acceptable`
* If no `Accept` header is provided, servers **must** default to `application/json`

Example:

```http request
GET /v1/publishers/123
Accept: application/json
```

### Multiple media types

Some endpoints **may** support multiple media types to accommodate different use cases. When supporting multiple
formats:

* The API **must** clearly document which media types are supported for each endpoint
* The API **should** use content negotiation via the `Accept` header to determine the response format
* The default format **must** be JSON if no `Accept` header is specified

Common scenarios where multiple media types are useful:

* **Reports and exports**: Offer JSON for programmatic access and CSV for spreadsheet import
* **Documentation**: Provide both JSON and HTML representations
* **Binary data**: Support both JSON metadata and raw binary content

Example:

```http request
GET /v1/reports/sales
Accept: text/csv
```

responds with:

```csv
date,revenue,orders
2024-01-01,15000,42
2024-01-02,18000,51
```

### Custom media types

APIs **should not** use custom media types unless there is a specific, compelling reason to do so. Custom media types
add complexity for clients and should be considered carefully.

If a custom media type is truly necessary, it **should** follow the format `application/{type}+{suffix}`.

* Always provide a `+json` or `+xml` suffix to indicate the underlying format
* Document the custom media type thoroughly in the API specification
* Ensure the custom media type provides clear value over standard `application/json`

An example of an appropriate custom media type is the standardized error response `application/vnd.error+json` (
see [Errors](./errors)).

**Note:** Simply wanting to indicate a version number or resource type is **not** a sufficient reason for a custom media
type. Use standard `application/json` with appropriate URL versioning or content structure instead.

### Unsupported media types

When a client requests or sends an unsupported media type:

* If the `Content-Type` header specifies an unsupported request format, return `415 Unsupported Media Type`
* If the `Accept` header requests an unsupported response format, return `406 Not Acceptable`
* Error responses **should** indicate which media types are supported for the endpoint

Example error response:

```json
{
  "message": "Unsupported media type 'application/xml'. Supported types: application/json",
  "logref": "415-001",
  "_links": {
    "help": {
      "href": "https://docs.example.com/api/media-types"
    }
  }
}
```

## Further reading

* [RFC 7231 §5.3](https://tools.ietf.org/html/rfc7231#section-5.3) HTTP Accept header specification
* [RFC 6838](https://tools.ietf.org/html/rfc6838) Media type specifications
* [Content-Type Header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Type) Documentation
* [Accept Header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Accept) Documentation
* [415 Unsupported Media Type](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/415) Documentation
* [406 Not Acceptable](https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/406) Documentation

[JSON payloads]: /json-payloads

## Changelog

* **2025-12-16**: Initial creation
