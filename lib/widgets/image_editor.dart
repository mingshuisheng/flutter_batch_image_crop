import 'dart:io';
import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:window_manager/window_manager.dart';

import '../hooks/index.dart';
import '../styled/index.dart';
import 'application_state.dart';
import 'my_keyboard_listener.dart';
import 'single_child_two_dimensional_scroll_view.dart';

part 'image_editor.g.dart';

enum ActionState {
  none,
  resizing,
  moving,
}

(Rect, ValueNotifier<Rect>) useClipRect(double scale, Offset initOffset) {
  final originClipRect =
      useState(Rect.fromLTWH(initOffset.dx, initOffset.dy, 100, 100));

  final clipRect = useMemoized(() {
    final left = originClipRect.value.left * scale;
    final top = originClipRect.value.top * scale;
    final right = originClipRect.value.right * scale;
    final bottom = originClipRect.value.bottom * scale;
    return Rect.fromLTRB(left, top, right, bottom);
  }, [scale, originClipRect.value]);

  return (clipRect, originClipRect);
}

(
  PointerDownEventListener,
  PointerUpEventListener,
  PointerMoveEventListener,
  PointerSignalEventListener
) useListenerEventHandler(
  ValueNotifier<Rect> originClipRect,
  ValueNotifier<bool> isCtrlPressed,
  ValueNotifier<ResizeDirection> resizeDirection,
  ValueNotifier<ActionState> actionState,
  ValueNotifier<MouseCursor> cursor,
  ValueNotifier<double> scale,
  double originBorderWidth,
  ObjectRef<Size> originSize,
) {
  final moveDetail = useRef(Offset.zero);

  final onPointerDown = useMemoized(() => (PointerDownEvent e) {
        moveDetail.value = Offset.zero;
        if (cursor.value != MouseCursor.defer) {
          if (cursor.value == SystemMouseCursors.move) {
            actionState.value = ActionState.moving;
          } else {
            actionState.value = ActionState.resizing;
          }
        }
      });
  final onPointerUp = useMemoized(() => (PointerUpEvent e) {
        actionState.value = ActionState.none;
        moveDetail.value = Offset.zero;
      });
  final onPointerMove = useMemoized(() => (PointerMoveEvent e) {
        if (actionState.value == ActionState.none) return;
        moveDetail.value += e.delta / scale.value;
        final maxRect =
            (Offset.zero & originSize.value).deflate(originBorderWidth);

        final dy = moveDetail.value.dy.abs() >= 1.0
            ? moveDetail.value.dy.floorToDouble()
            : 0.0;
        final dx = moveDetail.value.dx.abs() >= 1.0
            ? moveDetail.value.dx.floorToDouble()
            : 0.0;
        if (dx == 0 && dy == 0) {
          return;
        }
        moveDetail.value -= Offset(dx, dy);
        if (actionState.value == ActionState.moving) {
          final originClipSize = originClipRect.value.size;
          final maxTop = maxRect.bottom - originClipSize.height;
          final maxLeft = maxRect.right - originClipSize.width;
          final top =
              (originClipRect.value.top + dy).clamp(maxRect.top, maxTop);
          final left =
              (originClipRect.value.left + dx).clamp(maxRect.left, maxLeft);

          originClipRect.value = Rect.fromLTWH(
              left, top, originClipSize.width, originClipSize.height);
        } else if (actionState.value == ActionState.resizing) {
          final direction = resizeDirection.value;
          var top = originClipRect.value.top - (direction.hasTop ? -dy : 0.0);
          var left =
              originClipRect.value.left - (direction.hasLeft ? -dx : 0.0);
          var right =
              originClipRect.value.right + (direction.hasRight ? dx : 0.0);
          var bottom =
              originClipRect.value.bottom + (direction.hasBottom ? dy : 0.0);
          if (direction.hasTop) {
            top = top.clamp(maxRect.top, bottom - 1.0);
          }
          if (direction.hasLeft) {
            left = left.clamp(maxRect.left, right - 1.0);
          }
          if (direction.hasRight) {
            right = right.clamp(left + 1.0, maxRect.right);
          }
          if (direction.hasBottom) {
            bottom = bottom.clamp(top + 1.0, maxRect.bottom);
          }
          originClipRect.value = Rect.fromLTRB(left, top, right, bottom);
        }
      });
  final onPointerSignal = useMemoized(() => (PointerSignalEvent e) {
        if (isCtrlPressed.value && e is PointerScrollEvent) {
          scale.value = (scale.value - e.scrollDelta.dy / 200).clamp(1.0, 8.0);
        }
      });

  return (onPointerDown, onPointerUp, onPointerMove, onPointerSignal);
}

ValueNotifier<MouseCursor> useCursor(ActionState actionState,
    bool isCtrlPressed, ResizeDirection resizeDirection, bool mouseInClipRect) {
  final cursor = useState(MouseCursor.defer);
  useEffect(() {
    if (actionState != ActionState.none) {
      return null;
    }
    if (isCtrlPressed) {
      cursor.value = MouseCursor.defer;
      return null;
    }
    if (mouseInClipRect && !resizeDirection.isEmpty) {
      cursor.value = resizeDirection.getResizeCursor();
      return null;
    }

    if (mouseInClipRect) {
      cursor.value = SystemMouseCursors.move;
      return null;
    }
    cursor.value = MouseCursor.defer;
    return null;
  }, [isCtrlPressed, resizeDirection, mouseInClipRect, actionState]);
  return cursor;
}

(
  ValueNotifier<bool>,
  ValueNotifier<ResizeDirection>,
  void Function(ResizeDirection v),
  void Function(),
  void Function()
) useClipMaskHandle(ValueNotifier<ActionState> actionState) {
  final mouseInClipRect = useState(false);
  final resizeDirection = useState(ResizeDirection());
  final onMouseHover = useMemoized(() => (ResizeDirection v) {
        if (actionState.value != ActionState.none) return;
        resizeDirection.value = v;
      });
  final onMouseEnter = useMemoized(() => () {
        if (actionState.value != ActionState.none) return;
        mouseInClipRect.value = true;
      });
  final onMouseExit = useMemoized(() => () {
        if (actionState.value != ActionState.none) return;
        mouseInClipRect.value = false;
      });
  return (
    mouseInClipRect,
    resizeDirection,
    onMouseHover,
    onMouseEnter,
    onMouseExit
  );
}

TapEventListener useDoubleClickHandler(
    ValueNotifier<ActionState> actionState,
    ValueNotifier<bool> isCtrlPressed,
    ValueNotifier<Rect> originClipRect,
    ValueNotifier<double> scale,
    ScrollController horizontalController,
    ScrollController verticalController) {
  return useMemoized(() => (TapEvent e) {
        if (actionState.value == ActionState.none && !isCtrlPressed.value) {
          final newPos = (e.localPos +
                  Offset(
                      horizontalController.offset, verticalController.offset)) /
              scale.value;
          originClipRect.value = newPos & originClipRect.value.size;
        }
      });
}

class HandleWindowMaximize with WindowListener {
  final VoidCallback callback;

  HandleWindowMaximize({required this.callback});

  @override
  void onWindowMaximize() {
    callback();
    super.onWindowMaximize();
  }
}

@hwidget
Widget _imageEditor(BuildContext buildContext, {required String path}) {
  // fix full screen is not rebuild
  // MediaQuery.of(buildContext);

  // final toResult = useState(UniqueKey());

  final scale = useState(1.0);
  const originBorderWidth = 5.0;
  final originSize = useRef(Size.zero);
  final borderWidth =
      useMemoized(() => originBorderWidth * scale.value, [scale.value]);
  final (clipRect, originClipRect) = useClipRect(
    scale.value,
    const Offset(originBorderWidth, originBorderWidth),
  );

  final applicationState = buildContext.read<ApplicationState>();
  useEffect(() {
    applicationState.clipRect =
        originClipRect.value.translate(-originBorderWidth, -originBorderWidth);
    return null;
  }, [originClipRect.value]);

  final (isCtrlPressed, keyboardHandler) = useIsCtrlPressed();
  final actionState = useState(ActionState.none);

  final hovController = useScrollController();
  final verController = useScrollController();

  //fix on Window Maximize scroll position incorrect
  useEffect(() {
    final handler = HandleWindowMaximize(callback: () {
      hovController.jumpTo(0);
      verController.jumpTo(0);
    });
    windowManager.addListener(handler);
    return () {
      windowManager.removeListener(handler);
    };
  }, []);

  final doubleClickHandler = useDoubleClickHandler(actionState, isCtrlPressed,
      originClipRect, scale, hovController, verController);

  final (
    mouseInClipRect,
    resizeDirection,
    onMouseHover,
    onMouseEnter,
    onMouseExit
  ) = useClipMaskHandle(actionState);
  final cursor = useCursor(actionState.value, isCtrlPressed.value,
      resizeDirection.value, mouseInClipRect.value);
  final (onPointerDown, onPointerUp, onPointerMove, onPointerSignal) =
      useListenerEventHandler(originClipRect, isCtrlPressed, resizeDirection,
          actionState, cursor, scale, originBorderWidth, originSize);

  final imageFuture = useMemoized(() async {
    final image = await img.decodeImageFile(path);
    final width = image!.width.toDouble();
    final height = image.height.toDouble();
    return Size(width, height);
  }, [path]);
  final imageData = useFuture(imageFuture);

  return LayoutBuilder(builder: (ctx, cons) {
    final originImageSize = (imageData.data ?? cons.biggest);
    originSize.value = Size(originImageSize.width + originBorderWidth * 2,
        originImageSize.height + originBorderWidth * 2);

    final size = originSize.value * scale.value;
    final imageSize = originImageSize * scale.value;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          Image.file(
            File(path),
            width: imageSize.width,
            height: imageSize.height,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.none,
          ).dottedBorder(
            strokeWidth: borderWidth,
            customPath: (size) => Path()
              ..addRRect(RRect.fromLTRBR(0, 0, size.width, size.height,
                      Radius.circular(borderWidth))
                  .deflate(borderWidth / 2)),
            padding: EdgeInsets.all(borderWidth),
            dashPattern: [borderWidth * 2],
            color: Colors.white.withOpacity(1.0),
          ),
          ClipMask(
            clipRect: clipRect,
            borderWidth: borderWidth,
            onMouseHover: onMouseHover,
            onMouseEnter: onMouseEnter,
            onMouseExit: onMouseExit,
          ),
        ],
      ),
    )
        .twoDimensionalScrollView(
            disable: isCtrlPressed.value,
            horizontalController: hovController,
            verticalController: verController)
        .gestureX(onDoubleTap: doubleClickHandler)
        .listener(
            onPointerDown: onPointerDown,
            onPointerUp: onPointerUp,
            onPointerMove: onPointerMove,
            onPointerSignal: onPointerSignal);
  }).listenKeyboard(keyboardHandler).cursor(cursor.value);
}

class ResizeDirection {
  ResizeDirection();

  int direction = 0;

  static int left = 1;
  static int top = 2;
  static int right = 4;
  static int bottom = 8;

  bool get isEmpty => direction == 0;
  bool get hasLeft => (direction & ResizeDirection.left) != 0;
  bool get hasTop => (direction & ResizeDirection.top) != 0;
  bool get hasRight => (direction & ResizeDirection.right) != 0;
  bool get hasBottom => (direction & ResizeDirection.bottom) != 0;

  ResizeDirection.calc(Offset offset, Size size, double borderWidth) {
    final dx = offset.dx;
    final dy = offset.dy;
    final width = size.width;
    final height = size.height;
    final dr = width - dx;
    final db = height - dy;
    if (dx <= borderWidth && dx >= 0) direction |= ResizeDirection.left;
    if (dy <= borderWidth && dy >= 0) direction |= ResizeDirection.top;
    if (dr <= borderWidth && dr >= 0) direction |= ResizeDirection.right;
    if (db <= borderWidth && db >= 0) direction |= ResizeDirection.bottom;
  }

  MouseCursor getResizeCursor() {
    return switch ((hasTop, hasLeft, hasRight, hasBottom)) {
      (true, true, false, false) => SystemMouseCursors.resizeUpLeft,
      (true, false, false, false) => SystemMouseCursors.resizeUp,
      (true, false, true, false) => SystemMouseCursors.resizeUpRight,
      (false, false, true, false) => SystemMouseCursors.resizeRight,
      (false, false, true, true) => SystemMouseCursors.resizeDownRight,
      (false, false, false, true) => SystemMouseCursors.resizeDown,
      (false, true, false, true) => SystemMouseCursors.resizeDownLeft,
      (false, true, false, false) => SystemMouseCursors.resizeLeft,
      _ => MouseCursor.defer
    };
  }

  @override
  bool operator ==(Object other) {
    if (super == other) {
      return true;
    }
    if (other is ResizeDirection) {
      return direction == other.direction;
    }
    return false;
  }
}

@hwidget
Widget _clipMask({
  required Rect clipRect,
  required double borderWidth,
  void Function(ResizeDirection)? onMouseHover,
  void Function()? onMouseExit,
  void Function()? onMouseEnter,
}) {
  final clipBorderRect =
      useMemoized(() => clipRect.inflate(borderWidth), [clipRect]);
  return Stack(
    children: [
      ClipPath(
        key: ValueKey(clipRect),
        clipper: CenterTransparentMask(
            hollowRect: clipRect, borderWidth: borderWidth),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
      ),
      Container(
        width: clipBorderRect.width,
        height: clipBorderRect.height,
        decoration: BoxDecoration(
          border: Border.all(
              color: Colors.white.withOpacity(0.8), width: borderWidth),
        ),
      ).mouseRegion(
        onEnter: (e) {
          if (onMouseEnter != null) onMouseEnter();
        },
        onHover: (e) {
          if (onMouseHover != null) {
            onMouseHover(ResizeDirection.calc(
                e.localPosition, clipBorderRect.size, borderWidth));
          }
        },
        onExit: (e) {
          if (onMouseExit != null) onMouseExit();
        },
      ).positioned(left: clipBorderRect.left, top: clipBorderRect.top),
    ],
  );
}

class CenterTransparentMask extends CustomClipper<Path> {
  CenterTransparentMask({required this.hollowRect, this.borderWidth = 0.0});

  final Rect hollowRect;
  final double borderWidth;

  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRect(
          Rect.fromLTWH(0, 0, size.width, size.height).deflate(borderWidth))
      ..addRect(hollowRect);

    return path..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
