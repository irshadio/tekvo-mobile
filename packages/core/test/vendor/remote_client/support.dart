import 'dart:convert';

import 'package:dio/dio.dart';

/// One scripted answer: status, JSON body and headers.
typedef Reply = ({int status, Object? body, Map<String, List<String>> headers});

Reply reply(
  int status, {
  Object? body = const <String, Object?>{},
  Map<String, List<String>> headers = const <String, List<String>>{},
}) => (status: status, body: body, headers: headers);

/// Answers each request from [script] and records what was sent.
class ScriptedAdapter implements HttpClientAdapter {
  ScriptedAdapter(this.script, {this.delay = Duration.zero});

  final Reply Function(RequestOptions options) script;
  final Duration delay;
  final List<RequestOptions> requests = <RequestOptions>[];

  /// Headers as sent; a replay may reuse and mutate the same options object.
  final List<Map<String, Object?>> sentHeaders = <Map<String, Object?>>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    sentHeaders.add(Map<String, Object?>.of(options.headers));
    await Future<void>.delayed(delay);
    final answer = script(options);
    return ResponseBody.fromString(
      jsonEncode(answer.body),
      answer.status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
        ...answer.headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio dioWith(HttpClientAdapter adapter) =>
    Dio(BaseOptions(baseUrl: 'https://api.example.test'))
      ..httpClientAdapter = adapter;
