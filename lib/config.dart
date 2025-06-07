const String apiBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:8080/api',
);

String get wsBaseUrl {
  if (apiBaseUrl.startsWith('https')) {
    return apiBaseUrl.replaceFirst('https', 'wss');
  }
  return apiBaseUrl.replaceFirst('http', 'ws');
}
