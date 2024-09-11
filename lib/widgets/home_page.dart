// import 'dart:async';
import 'dart:async';
import 'dart:isolate';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:windows_notification/notification_message.dart';
import 'package:windows_notification/windows_notification.dart';

import '../colors.dart';
import '../file_utils.dart';
import '../styled/index.dart';
import 'app_bar.dart';
import 'application_state.dart';
import 'file_drag_area.dart';
import 'image_editor.dart';
import 'side_bar.dart';

part 'home_page.g.dart';

final _winNotifyPlugin =
    WindowsNotification(applicationId: "mss_batch_picture_corp_z5JracVR09Nx");

@swidget
Widget _myHomePage(BuildContext context, {required String appTitle}) {
  return Page(appBar: MyAppBar(title: appTitle), content: Content());
}

@swidget
Widget _page({required Widget appBar, required Widget content}) {
  return Column(
    children: [
      appBar,
      content.expanded(),
    ],
  ).mica();
}

@hwidget
Widget _content(BuildContext context) {
  final fileList = useState<List<XFile>>([]);
  return FileDragArea(
    child:
        fileList.value.isEmpty ? null : RealContent(fileList: fileList.value),
    callback: (files) async {
      final newImages = await getImageFileByXFile(files);
      fileList.value = <XFile>{
        ...fileList.value,
        ...newImages,
      }.toList();
    },
  );
}

@hwidget
Widget _realContent(BuildContext context, {required List<XFile> fileList}) {
  final theme = FluentTheme.of(context);
  final selected = useState(0);
  final showLoading = useState(false);
  final applicationState = context.read<ApplicationState>();

  return Stack(children: [
    Row(
      children: [
        Side(
            fileList: fileList,
            selected: selected.value,
            onChange: (index) => selected.value = index,
            onExport: () async {
              showLoading.value = true;
              final distPath = await FilePicker.platform.getDirectoryPath(
                  dialogTitle: "选择图片输出目录", lockParentWindow: true);
              final clipRect = applicationState.clipRect;
              if (distPath == null) {
                showLoading.value = false;
                return;
              }
              final receive = ReceivePort();
              receive.listen((_) {
                receive.close();
                showLoading.value = false;
                final message = NotificationMessage.fromPluginTemplate(
                    "batch_crop_app", "批量图片裁切", "图片导出成功：$distPath");
                _winNotifyPlugin.showNotificationPluginTemplate(message);
              });
              Isolate.spawn((message) async {
                final clipRect = message.$1;
                final fileList = message.$2;
                final distPath = message.$3;
                final sendPort = message.$4;

                final tasks = <Future<bool>>[];
                for (final file in fileList) {
                  final task = img
                      .decodeImageFile(file.path)
                      .then((image) => img.copyCrop(image!,
                          x: clipRect.left.ceil(),
                          y: clipRect.top.ceil(),
                          width: clipRect.width.floor(),
                          height: clipRect.height.floor()))
                      .then((image) => img.encodeImageFile(
                          "$distPath\\${file.name}", image));
                  tasks.add(task);
                }
                await Future.wait(tasks);
                sendPort.send("");
              }, (clipRect, fileList, distPath, receive.sendPort));
            }).padding(all: 10).width(300),
        ImageEditor(path: fileList[selected.value].path)
            .padding(all: 10)
            .backgroundColor(theme.scaffoldBackgroundColor)
            .expanded(),
      ],
    ),
    if (showLoading.value)
      const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [ProgressRing(), Text("正在导出，请稍后")],
      ).center().backgroundColor(MyColors.barrierColor),
  ]);
}

@hwidget
Widget _side(BuildContext context,
    {required List<XFile> fileList,
    required int selected,
    required void Function(int) onChange,
    required void Function() onExport}) {
  final sidebarItems = fileList
      .map((file) => SideBarItemData(text: file.name, toolTip: file.path))
      .toList();

  return Column(
    children: [
      SideBar(
        items: sidebarItems,
        selected: selected,
        onTap: onChange,
      ).expanded(),
      const SizedBox(height: 10),
      FilledButton(
        onPressed: onExport,
        child: const Text("导出图片"),
      ).width(double.infinity),
      const SizedBox(height: 10),
    ],
  );
}
