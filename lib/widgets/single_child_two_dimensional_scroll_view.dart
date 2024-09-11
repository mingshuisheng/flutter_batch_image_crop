import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:single_child_two_dimensional_scroll_view/single_child_two_dimensional_scroll_view.dart'
    as sv;

part 'single_child_two_dimensional_scroll_view.g.dart';

@hwidget
Widget _singleChildTwoDimensionalScrollView(Widget child,
    {bool disable = false}) {
  final hovController = useScrollController();
  final verController = useScrollController();
  return LayoutBuilder(builder: (ctx, _) {
    return Scrollbar(
      controller: verController,
      child: Scrollbar(
        controller: hovController,
        child: sv.SingleChildTwoDimensionalScrollView(
          horizontalController: hovController,
          verticalController: verController,
          horizontalPhysics: disable ? NeverScrollableScrollPhysics() : null,
          verticalPhysics: disable ? NeverScrollableScrollPhysics() : null,
          child: child,
        ),
      ),
    );
  });
}

extension TwoDimensionalScrollView on Widget {
  Widget twoDimensionalScrollView([bool disable = false]) =>
      SingleChildTwoDimensionalScrollView(this, disable: disable);
}
