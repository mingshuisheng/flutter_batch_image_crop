import 'package:batch_image_crop/styled/index.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:styled_widget/styled_widget.dart';

import '../colors.dart';

part 'side_bar.g.dart';

class SideBarItemData {
  final String text;
  final String toolTip;

  SideBarItemData({required this.text, required this.toolTip});
}

@swidget
Widget _sideBar({
  required List<SideBarItemData> items,
  required int selected,
  required Function(int) onTap,
  required Function(int) onDelete,
}) {
  return ListView(
    children: items
        .asMap()
        .entries
        .map((entry) => SideBarItem(
                sideBarItemData: entry.value,
                onDelete: () => onDelete(entry.key),
                onPressed: () => onTap(entry.key))
            .backgroundColor(entry.key == selected
                ? MyColors.selectedColor
                : Colors.transparent))
        .toList(),
  );
}

@swidget
Widget _sideBarItem(
    {required SideBarItemData sideBarItemData,
    VoidCallback? onPressed,
    VoidCallback? onDelete}) {
  return HoverButton(
    cursor: SystemMouseCursors.click,
    focusEnabled: false,
    forceEnabled: true,
    onPressed: onPressed,
    builder: (_, states) => Tooltip(
      message: sideBarItemData.toolTip,
      child: Stack(
        children: [
          Text(
            sideBarItemData.text,
            style: const TextStyle(fontSize: 30),
          ).center().padding(horizontal: 50, vertical: 10).backgroundColor(
              states.isHovered ? MyColors.hoverColor : Colors.transparent),
          Positioned.fill(
            child: IconButton(
                    icon: const Icon(
                      FluentIcons.delete,
                      size: 20.0,
                    ),
                    onPressed: onDelete)
                .padding(left: 10)
                .centerStart(),
          ),
        ],
      ),
    ),
  );
}
