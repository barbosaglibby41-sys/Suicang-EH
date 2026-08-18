import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a cancellation token records a user initiated pause', () {
    final token = CancelToken();
    token.cancel('paused');

    expect(token.isCancelled, isTrue);
  });
}
