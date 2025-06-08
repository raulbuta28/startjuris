import 'package:flutter/foundation.dart';

const String _envApiUrl = String.fromEnvironment('API_URL');

String get apiBaseUrl {
  if (_envApiUrl.isNotEmpty) {
    return _envApiUrl;
  }

  if (kIsWeb) {
    return 'http://localhost:8080/api';
  }

  if (defaultTargetPlatform == TargetPlatform.android) {
    // Android emulators cannot access the host machine via localhost
    return 'http://10.0.2.2:8080/api';
  }

  return 'http://localhost:8080/api';
}

String get wsBaseUrl {
  if (apiBaseUrl.startsWith('https')) {
    return apiBaseUrl.replaceFirst('https', 'wss');
  }
  return apiBaseUrl.replaceFirst('http', 'ws');
}
