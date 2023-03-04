import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' hide ThemeData;
import 'package:flutter/material.dart'
    show
        NavigationRailLabelType,
        NavigationRailThemeData,
        Theme,
        ThemeData,
        NavigationRail;
import 'package:macos_ui/macos_ui.dart';
import 'package:window_manager/window_manager.dart';

class AdaptiveWindow extends StatelessWidget {
  final Widget content;
  final Widget? title, sidebar, leading;
  final int currentIndex;
  final void Function(int index)? onIndexChange;
  final List<AdaptiveSideBarItem> sidebarItems;
  final bool showTitleOnMac;
  const AdaptiveWindow(
      {super.key,
      required this.content,
      required,
      this.title,
      this.sidebar,
      this.leading,
      this.currentIndex = 0,
      this.onIndexChange,
      this.sidebarItems = const [], this.showTitleOnMac = true});

  @override
  Widget build(BuildContext context) {
    // ignore: sort_child_properties_last
    if (Platform.isMacOS){
      return MacosWindow(
        titleBar: title != null && showTitleOnMac ? TitleBar(title: title, height: 48,) : null,
        sidebar: sidebarItems.isEmpty
            ? null
            : Sidebar(
                builder: (context, scrollController) => SidebarItems(
                    items: sidebarItems
                        .map((item) => SidebarItem(
                            label: Text(item.label),
                            leading: MacosIcon(item.macosIcon)))
                        .toList(),
                    currentIndex: currentIndex,
                    onChanged: onIndexChange ?? (val) {}),
                minWidth: 150,
              ),
        child: content,
      );}
    return NavigationView(
      appBar: NavigationAppBar(
          title: Platform.isMacOS
              ? title
              : DragToMoveArea(
                  child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: title))),
      content: Row(
        children: [
          Theme(
            data: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Colors.teal,
                brightness: Brightness.dark,
                navigationRailTheme: NavigationRailThemeData(
                    backgroundColor: Colors.grey[170],
                    minWidth: 64,
                    labelType: NavigationRailLabelType.all,
                    groupAlignment: 0)),
            child: NavigationRail(
              onDestinationSelected: onIndexChange,
              destinations: const [],
              selectedIndex: currentIndex,
            ),
          ),
          Expanded(child: content)
        ],
      ),
    );
  }
}

class AdaptiveSideBarItem {
  String label;
  IconData windowsIcon, macosIcon;

  AdaptiveSideBarItem(
      {required this.label,
      required this.macosIcon,
      required this.windowsIcon});
}
