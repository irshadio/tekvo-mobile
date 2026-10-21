import 'package:dio/dio.dart';

import '../models/base_response.dart';
import 'response_parser.dart';
import '../models/request_timeout_config.dart';
import '../types/either.dart';
import '../types/failure.dart';

/// File operations interface following ISP
/// Separated from basic HTTP operations for clients that need file handling
abstract class FileClient {
  Future<Either<Failure, BaseResponse<T>>> multiPartPost<T>(
    String endpoint, {
    required FormData data,
    void Function(int, int)? onSendProgress,
    T Function(Object?)? fromJson,
    CancelToken? cancelToken,
    Options? options,
    RequestTimeoutConfig? timeout,
    ResponseParser? parser,
  });

  Future<Either<Failure, BaseResponse<T>>> multiPartPatch<T>(
    String endpoint, {
    required FormData data,
    void Function(int, int)? onSendProgress,
    T Function(Object?)? fromJson,
    CancelToken? cancelToken,
    Options? options,
    RequestTimeoutConfig? timeout,
    ResponseParser? parser,
  });

  Future<Either<Failure, BaseResponse<void>>> download(
    String url,
    String path, {
    void Function(int, int)? onReceiveProgress,
    CancelToken? cancelToken,
    Options? options,
    RequestTimeoutConfig? timeout,
    ResponseParser? parser,
  });
}
