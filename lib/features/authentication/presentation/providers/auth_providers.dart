import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/flutter_secure_cookie_store.dart';
import '../../data/repositories/secure_auth_repository.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repository = SecureAuthRepository(FlutterSecureCookieStore());
  ref.onDispose(repository.dispose);
  return repository;
});

final authSessionProvider = StreamProvider<AuthSession>((ref) {
  return ref.watch(authRepositoryProvider).watchSession();
});
