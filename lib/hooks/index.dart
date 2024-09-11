import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

(ValueNotifier<bool>, void Function(KeyEvent e)) useIsKeyPressed(
    List<LogicalKeyboardKey> keys) {
  final isKeyPressed = useState(false);
  final handleKeyboard = useMemoized(
      () => (KeyEvent e) {
            if (keys.contains(e.logicalKey)) {
              if (e is KeyUpEvent) {
                isKeyPressed.value = false;
              } else if (e is KeyDownEvent) {
                isKeyPressed.value = true;
              }
            }
          },
      []);
  return (isKeyPressed, handleKeyboard);
}

(ValueNotifier<bool>, void Function(KeyEvent e)) useIsCtrlPressed() {
  return useIsKeyPressed(
      const [LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.controlRight]);
}
