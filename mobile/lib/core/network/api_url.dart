/// API path prefix applied by the networking layer to every backend request.
const apiPrefix = '/api/v1';

/// Builds the API base URL from a configured server root.
String buildApiBaseUrl(String serverRoot) =>
    '${serverRoot.replaceFirst(RegExp(r'/+$'), '')}$apiPrefix';
