import 'package:fluent_ui/fluent_ui.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:window_manager/window_manager.dart';

import '../styled/index.dart';

part 'app_bar.g.dart';

@swidget
Widget _myAppBar(BuildContext context, {required String title}) {
  final FluentThemeData theme = FluentTheme.of(context);
  return Row(
    children: [
      Text(title)
          .alignment(Alignment.centerLeft)
          .padding(left: 10)
          .dragToMoveArea()
          .height(50)
          .expanded(),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // ToggleSwitch(
          //   content: const Text('Dark Mode'),
          //   checked: theme.brightness.isDark,
          //   onChanged: (v) => appTheme.setMode(v),
          // ),
          WindowCaption(
            brightness: theme.brightness,
            backgroundColor: Colors.transparent,
          ).width(138).height(50),
        ],
      )
    ],
  );
}
