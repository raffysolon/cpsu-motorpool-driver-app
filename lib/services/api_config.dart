class ApiConfig {
  static const String _defaultApiBaseUrl =
      'https://cpsu-motorpool-backend.onrender.com/api';
  static const String _configuredApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultApiBaseUrl,
  );

  static final Uri _baseUri = _normalize(_configuredApiBaseUrl);

  static String get apiBaseUrl =>
      _baseUri.toString().replaceFirst(RegExp(r'/$'), '');

  static String get storageNamespace => Uri.encodeComponent(apiBaseUrl);

  static Uri apiUri(String endpoint, {Map<String, String>? queryParameters}) {
    var path = endpoint.replaceFirst(RegExp(r'^/+'), '');
    while (path.toLowerCase() == 'api' ||
        path.toLowerCase().startsWith('api/')) {
      path = path.length == 3 ? '' : path.substring(4);
    }
    final uri = _baseUri.replace(
      path: path.isEmpty ? _baseUri.path : '${_baseUri.path}/$path',
      query: null,
      fragment: null,
    );
    return queryParameters == null
        ? uri
        : uri.replace(queryParameters: queryParameters);
  }

  static Uri _normalize(String value) {
    final uri = Uri.parse(value.trim());
    if ((uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw const FormatException(
        'API_BASE_URL must be an absolute HTTP(S) URL without credentials, '
        'a query, or a fragment.',
      );
    }
    var path = uri.path.replaceAll(RegExp(r'/+$'), '');
    path = path.replaceAll(RegExp(r'(?:/api)+$', caseSensitive: false), '/api');
    if (!path.toLowerCase().endsWith('/api')) path = '$path/api';
    return uri.replace(path: path);
  }
}
