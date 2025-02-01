import 'package:dio/dio.dart';
import 'package:flutter_learn_riverpod/common/dto/refresh_token_response.dart';
import 'package:flutter_learn_riverpod/common/http_status/status_code.dart';
import 'package:flutter_learn_riverpod/core/data/local/secure_storage/secure_storage_const.dart';
import 'package:flutter_learn_riverpod/core/data/local/secure_storage/secure_storage_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/secure_storage/secure_storage.dart';

final networkServiceInterceptorProvider =
    Provider.family<NetworkServiceInterceptor, Dio>((ref, dio) {
  final secureStorage = ref.watch(secureStorageProvider);
  return NetworkServiceInterceptor(secureStorage, dio);
});

final class NetworkServiceInterceptor extends Interceptor {
  final ISecureStorage _secureStorage;
  final Dio _dio;

  NetworkServiceInterceptor(this._secureStorage, this._dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await _secureStorage.read(accessTokenKey);

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
        final response = await _refreshToken();

        final json = response.data;
        final result = RefreshTokenResponse.fromJson(json ?? {});

        final statusCode = response.statusCode;
        if (statusCode == 200) {
          final accessToken = result.token;
          await _storeAccessToken(accessToken);

          final options = err.requestOptions;
          // update request header w/ new token
          options.headers['Authorization'] = 'Bearer $accessToken';
          // repeat request
          return handler.resolve(await _dio.fetch(options));
        }
      } on DioException catch (e) {
        if (err.response?.statusCode == invalidToken) {
          await _clearAccessToken();

          err.response?.statusCode = invalidToken;
          // return handler.next(err);
        }

        // return handler.next(err);
      }
    }

    // super.onError(err, handler);
    return handler.next(err);
  }

  Future<void> _clearAccessToken() async {
    await _secureStorage.delete(accessTokenKey);
    await _secureStorage.delete(refreshTokenKey);
  }

  Future<void> _storeAccessToken(String accessToken) async {
    await _secureStorage.write(accessTokenKey, accessToken);
  }

  Future<Response<Map<String, dynamic>>> _refreshToken() async {
    return await _dio.get<Map<String, dynamic>>('/api/v1/refresh-token');
  }
}
