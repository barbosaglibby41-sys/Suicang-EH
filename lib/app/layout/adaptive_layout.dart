import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';

enum AdaptiveSize { compact, medium, expanded }

abstract final class AdaptiveLayout {
  static AdaptiveSize sizeOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1024) return AdaptiveSize.expanded;
    if (width >= 600) return AdaptiveSize.medium;
    return AdaptiveSize.compact;
  }

  static int gridColumns(BuildContext context) {
    return switch (sizeOf(context)) {
      AdaptiveSize.compact => 2,
      AdaptiveSize.medium => 4,
      AdaptiveSize.expanded => 5,
    };
  }
}
