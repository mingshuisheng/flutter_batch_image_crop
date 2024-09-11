import 'package:fluent_ui/fluent_ui.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:provider/provider.dart';

import './theme.dart';
import './widgets/index.dart';

part 'app.g.dart';

const appTitle = "批量裁切图片";

@swidget
Widget _myApp() {
  return ApplicationStateProvider(
    child: ChangeNotifierProvider(
      create: (_) => AppTheme(),
      builder: (context, _) {
        final appTheme = context.watch<AppTheme>();
        return FluentApp(
          title: appTitle,
          themeMode: appTheme.mode,
          debugShowCheckedModeBanner: false,
          color: appTheme.color,
          darkTheme: FluentThemeData(
            brightness: Brightness.dark,
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            dialogTheme: appTheme.dialogTheme,
            focusTheme:
                FocusThemeData(glowFactor: is10footScreen(context) ? 2.0 : 0.0),
          ),
          theme: FluentThemeData(
            accentColor: appTheme.color,
            visualDensity: VisualDensity.standard,
            dialogTheme: appTheme.dialogTheme,
            focusTheme:
                FocusThemeData(glowFactor: is10footScreen(context) ? 2.0 : 0.0),
          ),
          locale: appTheme.locale,
          home: const MyHomePage(appTitle: appTitle),
        );
      },
    ),
  );
}
