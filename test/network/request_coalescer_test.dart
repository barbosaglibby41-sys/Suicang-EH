import 'package:flutter_test/flutter_test.dart';
import 'package:suicang_eh/core/network/network_exception.dart';
import 'package:suicang_eh/core/network/network_retry_policy.dart';
import 'package:suicang_eh/core/network/request_coalescer.dart';

void main() {
  test('shares one in-flight operation for equivalent keys', () async {
    final coalescer = RequestCoalescer<String, int>();
    var calls = 0;
    Future<int> work() async {
      calls += 1;
      await Future<void>.delayed(const Duration(milliseconds: 2));
      return 42;
    }

    final results = await Future.wait(
        [coalescer.run('same', work), coalescer.run('same', work)]);

    expect(results, [42, 42]);
    expect(calls, 1);
    expect(coalescer.activeCount, 0);
  });

  test('retries transient failures but not authentication failures', () async {
    const policy = NetworkRetryPolicy(baseDelay: Duration.zero);
    var attempts = 0;
    final value = await policy.run(() async {
      attempts += 1;
      if (attempts < 3) {
        throw const NetworkException(
            kind: NetworkFailureKind.timeout, message: 'timeout');
      }
      return 'ok';
    });
    expect(value, 'ok');
    expect(attempts, 3);

    var authAttempts = 0;
    await expectLater(
      policy.run(() async {
        authAttempts += 1;
        throw const NetworkException(
          kind: NetworkFailureKind.authenticationRequired,
          message: 'login',
        );
      }),
      throwsA(isA<NetworkException>()),
    );
    expect(authAttempts, 1);
  });
}
