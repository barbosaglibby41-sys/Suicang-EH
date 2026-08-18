import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

Future<void> bootstrap(Widget Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  runZonedGuarded<void>(
    () => runApp(ProviderScope(child: builder())),
    (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stackTrace),
      );
    },
  );
}

class TaroEhBootstrap extends StatelessWidget {
  const TaroEhBootstrap({super.key});

  @override
  Widget build(BuildContext context) => const TaroEhApp();
}
