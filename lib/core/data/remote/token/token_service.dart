import 'package:dio/dio.dart';
import 'package:flutter_learn_riverpod/common/dto/refresh_token_response.dart';
import 'package:flutter_learn_riverpod/common/http_status/status_code.dart';
import 'package:flutter_learn_riverpod/core/data/local/secure_storage/secure_storage_const.dart';
import 'package:flutter_learn_riverpod/core/data/local/secure_storage/secure_storage_interface.dart';
import 'package:flutter_learn_riverpod/core/data/remote/token/token_service_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../local/secure_storage/secure_storage.dart';

final tokenServiceProvider = Provider.family<ITokenService, Dio>((ref, dio) {
  final secureStorage = ref.watch(secureStorageProvider);
  return TokenService(dio, secureStorage);
});

class TokenService implements ITokenService {
  final Dio _dio;
  final ISecureStorage _secureStorage;

  TokenService(this._dio, this._secureStorage);

  @override
  Future<void> clearAccessToken() {
    return Future.wait([
      _secureStorage.delete(accessTokenKey),
      _secureStorage.delete(refreshTokenKey),
    ]);
  }

  @override
  Future<String?> getAccessToken() => _secureStorage.read(accessTokenKey);

  @override
  Future<RefreshTokenResponse> refreshAccessToken() async {
    final response =
        await _dio.get<Map<String, dynamic>>('/api/v1/refresh-token');

    if (response.statusCode == ok) {
      return RefreshTokenResponse.fromJson(response.data ?? {});
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
      );
    }
  }

  @override
  Future<void> saveAccessToken(String accessToken) {
    return Future.wait([
      _secureStorage.write(accessTokenKey, accessToken),
    ]);
  }
}
