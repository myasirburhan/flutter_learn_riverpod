import 'package:dio/dio.dart';
import 'package:dio_http_formatter/dio_http_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'network_service_interceptor.dart';

final networkServiceProvider = Provider<Dio>((ref) {
  final options = BaseOptions(
    baseUrl: 'https://api.openweathermap.org/data/2.5/',
    // receiveDataWhenStatusError: true,
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 60),
  );
  final dio = Dio(options);

  final networkServiceInterceptor =
      ref.watch(networkServiceInterceptorProvider);
  dio.interceptors.addAll([
    HttpFormatter(),
    networkServiceInterceptor,
  ]);

  return dio;
});
