import 'package:dio/dio.dart';
import 'package:flutter_learn_riverpod/common/dto/refresh_token_response.dart';
import 'package:flutter_learn_riverpod/common/http_status/status_code.dart';
import 'package:flutter_learn_riverpod/core/data/local/secure_storage/secure_storage_const.dart';
import 'package:flutter_learn_riverpod/core/data/local/secure_storage/secure_storage_interface.dart';
import 'package:flutter_learn_riverpod/core/data/remote/token/token_service.dart';
import 'package:flutter_learn_riverpod/core/data/remote/token/token_service_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/secure_storage/secure_storage.dart';

final networkServiceInterceptorProvider =
    Provider.family<NetworkServiceInterceptor, Dio>((ref, dio) {
  final tokenService = ref.watch(tokenServiceProvider(dio));
  return NetworkServiceInterceptor(tokenService, dio);
});

final class NetworkServiceInterceptor extends Interceptor {
  final ITokenService _tokenService;
  final Dio _dio;

  NetworkServiceInterceptor(this._tokenService, this._dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await _tokenService.getAccessToken();

    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    options.headers['Authorization'] = 'Bearer $accessToken';

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == unauthorized) {
      try {
        final result = await _tokenService.refreshAccessToken();

        final accessToken = result.token;
        await _tokenService.saveAccessToken(accessToken);

        final options = err.requestOptions;
        // update request header w/ new token
        options.headers['Authorization'] = 'Bearer $accessToken';
        // repeat request
        return handler.resolve(await _dio.fetch(options));
      } on DioException catch (e) {
        if (err.response?.statusCode == invalidToken) {
          await _tokenService.clearAccessToken();
          // return handler.next(err);
        }

        // return handler.next(err);
      }
    }

    // super.onError(err, handler);
    return handler.next(err);
  }

  Future<Response<Map<String, dynamic>>> _refreshToken() async {
    return await _dio.get<Map<String, dynamic>>('/api/v1/refresh-token');
  }
}
