import 'api_service.dart';

String resolveUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }
  final base = ApiService.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
  if (url.startsWith('/')) {
    return '$base$url';
  }
  return '$base/$url';
}
