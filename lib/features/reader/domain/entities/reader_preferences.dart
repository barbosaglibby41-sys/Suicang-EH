import 'reader_models.dart';

class ReaderPreferences {
  const ReaderPreferences({
    this.mode = ReaderMode.horizontal,
    this.direction = ReaderDirection.ltr,
    this.fit = ReaderFit.contain,
    this.keepScreenOn = true,
  });

  final ReaderMode mode;
  final ReaderDirection direction;
  final ReaderFit fit;
  final bool keepScreenOn;

  ReaderPreferences copyWith({
    ReaderMode? mode,
    ReaderDirection? direction,
    ReaderFit? fit,
    bool? keepScreenOn,
  }) => ReaderPreferences(
        mode: mode ?? this.mode,
        direction: direction ?? this.direction,
        fit: fit ?? this.fit,
        keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      );
}
