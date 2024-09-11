import 'package:dotted_border/dotted_border.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';
import 'package:window_manager/window_manager.dart';

extension WindowManagerWidget on Widget {
  Widget dragToMoveArea({
    Key? key,
  }) =>
      DragToMoveArea(
        key: key,
        child: this,
      );
}

extension FluentStyle on Widget {
  Widget mica() => Mica(child: this);
}

extension MyStyleUtils on Widget {
  Widget full() =>
      SizedBox(width: double.infinity, height: double.infinity, child: this);

  Widget fullWidth() => SizedBox(width: double.infinity, child: this);

  Widget fullHeight() => SizedBox(height: double.infinity, child: this);

  Widget ignorePointer() => IgnorePointer(child: this);

  Widget centerStart() =>
      Align(alignment: AlignmentDirectional.centerStart, child: this);

  Widget topStart() =>
      Align(alignment: AlignmentDirectional.topStart, child: this);

  Widget cursor(MouseCursor cursor) => MouseRegion(
        cursor: cursor,
        child: this,
      );
  Widget dottedBorder({
    Color color = Colors.black,
    double strokeWidth = 1.0,
    BorderType borderType = BorderType.Rect,
    List<double> dashPattern = const <double>[3, 1],
    EdgeInsets padding = const EdgeInsets.all(2),
    EdgeInsets borderPadding = EdgeInsets.zero,
    Radius radius = const Radius.circular(0),
    StrokeCap strokeCap = StrokeCap.butt,
    PathBuilder? customPath,
    StackFit stackFit = StackFit.loose,
  }) =>
      DottedBorder(
          color: color,
          strokeWidth: strokeWidth,
          borderType: borderType,
          dashPattern: dashPattern,
          padding: padding,
          borderPadding: borderPadding,
          radius: radius,
          strokeCap: strokeCap,
          customPath: customPath,
          stackFit: stackFit,
          child: this);
}

extension MyStyleFlexUtils on Flex {
  Widget gap(double gap) {
    final List<Widget> newChildren = [];
    for (final oldChild in children) {
      newChildren.add(oldChild);
      newChildren.add(SizedBox(width: gap, height: gap));
    }
    return Flex(
      key: key,
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      clipBehavior: clipBehavior,
      children: newChildren,
    );
  }
}

extension MyEventListener on Widget {
  Widget keyboard() {
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      child: this,
      onKeyEvent: (e) {
        debugPrint("keyboard ${e.logicalKey}");
      },
    );
  }

  Widget listener({
    Key? key,
    PointerDownEventListener? onPointerDown,
    PointerMoveEventListener? onPointerMove,
    PointerUpEventListener? onPointerUp,
    PointerHoverEventListener? onPointerHover,
    PointerCancelEventListener? onPointerCancel,
    PointerPanZoomStartEventListener? onPointerPanZoomStart,
    PointerPanZoomUpdateEventListener? onPointerPanZoomUpdate,
    PointerPanZoomEndEventListener? onPointerPanZoomEnd,
    PointerSignalEventListener? onPointerSignal,
    behavior = HitTestBehavior.deferToChild,
  }) =>
      Listener(
        key: key,
        onPointerDown: onPointerDown,
        onPointerMove: onPointerMove,
        onPointerUp: onPointerUp,
        onPointerHover: onPointerHover,
        onPointerCancel: onPointerCancel,
        onPointerPanZoomStart: onPointerPanZoomStart,
        onPointerPanZoomUpdate: onPointerPanZoomUpdate,
        onPointerPanZoomEnd: onPointerPanZoomEnd,
        onPointerSignal: onPointerSignal,
        behavior: behavior,
        child: this,
      );

  Widget mouseRegion({
    Key? key,
    PointerEnterEventListener? onEnter,
    PointerExitEventListener? onExit,
    PointerHoverEventListener? onHover,
    MouseCursor cursor = MouseCursor.defer,
    bool opaque = true,
    HitTestBehavior? hitTestBehavior,
  }) =>
      MouseRegion(
        key: key,
        onEnter: onEnter,
        onExit: onExit,
        onHover: onHover,
        cursor: cursor,
        opaque: opaque,
        hitTestBehavior: hitTestBehavior,
        child: this,
      );

  Widget gestureX({
    TapEventListener? onTap,
    MoveEventListener? onMoveUpdate,
    MoveEventListener? onMoveEnd,
    MoveEventListener? onMoveStart,
    void Function(Offset initialFocusPoint)? onScaleStart,
    ScaleEventListener? onScaleUpdate,
    void Function()? onScaleEnd,
    TapEventListener? onDoubleTap,
    Function(ScrollEvent event)? onScrollEvent,
    bool bypassMoveEventAfterLongPress = true,
    bool bypassTapEventOnDoubleTap = false,
    int doubleTapTimeConsider = 250,
    int longPressTimeConsider = 350,
    TapEventListener? onLongPress,
    MoveEventListener? onLongPressMove,
    Function()? onLongPressEnd,
    HitTestBehavior behavior = HitTestBehavior.deferToChild,
    int longPressMaximumRangeAllowed = 25,
  }) =>
      XGestureDetector(
          onTap: onTap,
          onMoveUpdate: onMoveUpdate,
          onMoveEnd: onMoveEnd,
          onMoveStart: onMoveStart,
          onScaleStart: onScaleStart,
          onScaleUpdate: onScaleUpdate,
          onScaleEnd: onScaleEnd,
          onDoubleTap: onDoubleTap,
          onScrollEvent: onScrollEvent,
          bypassMoveEventAfterLongPress: bypassMoveEventAfterLongPress,
          bypassTapEventOnDoubleTap: bypassMoveEventAfterLongPress,
          doubleTapTimeConsider: doubleTapTimeConsider,
          longPressTimeConsider: longPressTimeConsider,
          onLongPress: onLongPress,
          onLongPressMove: onLongPressMove,
          onLongPressEnd: onLongPressEnd,
          behavior: behavior,
          longPressMaximumRangeAllowed: longPressMaximumRangeAllowed,
          child: this);
}
