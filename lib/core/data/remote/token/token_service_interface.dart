import 'package:flutter_learn_riverpod/common/dto/refresh_token_response.dart';

abstract interface class ITokenService {
  Future<String?> getAccessToken();
  Future<void> saveAccessToken(String accessToken);
  Future<void> clearAccessToken();
  Future<RefreshTokenResponse> refreshAccessToken();
  }