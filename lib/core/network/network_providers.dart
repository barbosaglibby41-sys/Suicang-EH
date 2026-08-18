import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/authentication/presentation/providers/auth_providers.dart';
import 'site_http_client.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      followRedirects: true,
    ),
  );
});

final siteHttpClientProvider = Provider<SiteHttpClient>((ref) {
  return SiteHttpClient(
    dio: ref.watch(dioProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
});
