import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:single_child_two_dimensional_scroll_view/single_child_two_dimensional_scroll_view.dart'
    as sv;

part 'single_child_two_dimensional_scroll_view.g.dart';

@hwidget
Widget _singleChildTwoDimensionalScrollView(Widget child,
    {bool disable = false,
    required ScrollController horizontalController,
    required ScrollController verticalController}) {
  return LayoutBuilder(builder: (ctx, _) {
    return Scrollbar(
      controller: verticalController,
      child: Scrollbar(
        controller: horizontalController,
        child: sv.SingleChildTwoDimensionalScrollView(
          horizontalController: horizontalController,
          verticalController: verticalController,
          horizontalPhysics:
              disable ? const NeverScrollableScrollPhysics() : null,
          verticalPhysics:
              disable ? const NeverScrollableScrollPhysics() : null,
          child: child,
        ),
      ),
    );
  });
}

extension TwoDimensionalScrollView on Widget {
  Widget twoDimensionalScrollView(
          {bool disable = false,
          required ScrollController horizontalController,
          required ScrollController verticalController}) =>
      SingleChildTwoDimensionalScrollView(
        this,
        disable: disable,
        horizontalController: horizontalController,
        verticalController: verticalController,
      );
}
