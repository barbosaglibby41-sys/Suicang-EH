import 'dart:async';
import 'dart:math';

import 'network_exception.dart';

class NetworkRetryPolicy {
  const NetworkRetryPolicy({
    this.maxAttempts = 3,
    this.baseDelay = const Duration(milliseconds: 250),
  });

  final int maxAttempts;
  final Duration baseDelay;

  Future<T> run<T>(Future<T> Function() operation) async {
    NetworkException? last;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await operation();
      } on NetworkException catch (error) {
        last = error;
        if (!_isRetryable(error) || attempt == maxAttempts) rethrow;
        final jitter = Random().nextInt(baseDelay.inMilliseconds ~/ 2 + 1);
        await Future<void>.delayed(
          Duration(milliseconds: baseDelay.inMilliseconds * attempt + jitter),
        );
      }
    }
    throw last ?? const NetworkException(
      kind: NetworkFailureKind.unknown,
      message: 'Network request failed.',
    );
  }

  bool _isRetryable(NetworkException error) => switch (error.kind) {
        NetworkFailureKind.timeout ||
        NetworkFailureKind.noConnection ||
        NetworkFailureKind.transient => true,
        _ => false,
      };
}
