import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';

import './app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemTheme.accentColor.load();
  await flutter_acrylic.Window.initialize();
  if (defaultTargetPlatform == TargetPlatform.windows) {
    await flutter_acrylic.Window.hideWindowControls();
  }
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    await windowManager.setMinimumSize(const Size(500, 600));
  });
  runApp(const MyApp());
}
