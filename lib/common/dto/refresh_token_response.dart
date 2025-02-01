import 'package:freezed_annotation/freezed_annotation.dart';

part 'refresh_token_response.freezed.dart';
part 'refresh_token_response.g.dart';

@freezed
class RefreshTokenResponse with _$RefreshTokenResponse {
  const factory RefreshTokenResponse({
    @JsonKey(name: "success") required bool success,
    @JsonKey(name: "message") required dynamic message,
    @JsonKey(name: "data") required List<dynamic> data,
    @JsonKey(name: "errors") required dynamic errors,
    @JsonKey(name: "token") required String token,
  }) = _RefreshTokenResponse;

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenResponseFromJson(json);
}
