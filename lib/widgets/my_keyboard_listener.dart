import 'package:fluent_ui/fluent_ui.dart';

class MyKeyboardListener extends StatefulWidget {
  const MyKeyboardListener(
      {super.key, required this.child, this.onKeyEvent, this.onFocusChange});

  final Widget child;

  final ValueChanged<KeyEvent>? onKeyEvent;
  final ValueChanged<bool>? onFocusChange;

  @override
  State<MyKeyboardListener> createState() => _MyKeyboardListenerState();
}

class _MyKeyboardListenerState extends State<MyKeyboardListener> {
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: widget.onKeyEvent,
      child: Focus(
        onFocusChange: widget.onFocusChange,
        child: widget.child,
      ),
    );
  }
}

extension ListenKeyboard on Widget {
  Widget listenKeyboard(ValueChanged<KeyEvent>? onKeyEvent,
      [ValueChanged<bool>? onFocusChange]) {
    return MyKeyboardListener(
        onKeyEvent: onKeyEvent, onFocusChange: onFocusChange, child: this);
  }
}
