import 'dart:ui' as ui;

import 'package:fluent_ui/fluent_ui.dart';

class MyImage extends LeafRenderObjectWidget {
  const MyImage({super.key, this.image});
  final ui.Image? image;
  @override
  void updateRenderObject(BuildContext context, MyImageRender renderObject) {
    renderObject.image = image?.clone();
  }

  @override
  MyImageRender createRenderObject(BuildContext context) =>
      MyImageRender(image: image);
}

class MyImageRender extends RenderBox {
  MyImageRender({ui.Image? image}) : _image = image;

  ui.Image? _image;

  set image(ui.Image? value) {
    if (value == _image) {
      return;
    }
    // If we get a clone of our image, it's the same underlying native data -
    // dispose of the new clone and return early.
    if (value != null && _image != null && value.isCloneOf(_image!)) {
      value.dispose();
      return;
    }
    _image?.dispose();
    _image = value;
    markNeedsPaint();
    markNeedsLayout();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void performLayout() {
    debugPrint("performLayout: $constraints");
    final imageSize = getImageSize();
    var canvasWidth = imageSize.width;
    var canvasHeight = imageSize.height;
    if (constraints.maxWidth != double.infinity) {
      canvasWidth = constraints.maxWidth;
    }
    if (constraints.maxHeight != double.infinity) {
      canvasHeight = constraints.maxHeight;
    }
    size = Size(canvasWidth, canvasHeight);
  }

  Size getImageSize() {
    if (_image == null) {
      return const Size(0, 0);
    }
    return Size(_image!.width.toDouble(), _image!.height.toDouble());
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_image != null) {
      context.canvas.drawImage(_image!, offset, Paint());
    }
  }
}
