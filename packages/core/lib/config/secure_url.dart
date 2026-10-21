/// Returns [url] when it is an absolute `https` URL with a host and no
/// embedded credentials; throws [StateError] otherwise, so a misconfigured
/// build fails at startup.
String requireHttpsUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null ||
      uri.scheme != 'https' ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty) {
    throw StateError('API base URL must be an absolute https URL.');
  }
  return url;
}
