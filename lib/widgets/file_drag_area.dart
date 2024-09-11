import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

import '../styled/index.dart';

part 'file_drag_area.g.dart';

typedef AddFileCallback = void Function(List<XFile> files);

@hwidget
Widget _fileDragArea(BuildContext context,
    {Widget? child, required AddFileCallback callback}) {
  final dragging = useState(false);
  final FluentThemeData theme = FluentTheme.of(context);

  return DropTarget(
    onDragDone: (detail) {
      callback(detail.files);
    },
    onDragEntered: (detail) {
      dragging.value = true;
    },
    onDragExited: (detail) {
      dragging.value = false;
    },
    child: Stack(children: [
      if (child != null) Positioned.fill(child: child),
      if (child == null || dragging.value)
        Positioned.fill(
          child: Container(
            color: theme.dialogTheme.barrierColor,
            child: Center(
              child: const Text(
                "拖拽添加图片",
                style: TextStyle(fontSize: 50, color: Colors.white),
              ).fittedBox(fit: BoxFit.fitWidth),
            ),
          ).ignorePointer(),
        ),
    ]),
  );
}

extension WrapFileDragArea on Widget {
  Widget fileDragArea(AddFileCallback callback) => FileDragArea(
        callback: callback,
        child: this,
      );
}
