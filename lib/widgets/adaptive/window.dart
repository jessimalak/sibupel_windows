import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart' hide ThemeData, OverlayVisibilityMode;
import 'package:flutter/cupertino.dart' hide OverlayVisibilityMode;
import 'package:flutter/material.dart'
    show
        NavigationRailLabelType,
        NavigationRailThemeData,
        Theme,
        ThemeData,
        NavigationRail,
        NavigationRailDestination;
import 'package:macos_ui/macos_ui.dart';
import 'package:window_manager/window_manager.dart';

class AdaptiveWindow extends StatelessWidget {
  final Widget content;
  final Widget? title, leading;
  final Sidebar? endSidebar;
  final int currentIndex;
  final void Function(int index)? onIndexChange;
  final List<AdaptiveSideBarItem> sidebarItems;
  final bool showTitleOnMac;
  final void Function(String? text)? onSearch;
  const AdaptiveWindow(
      {super.key,
      required this.content,
      required,
      this.title,
      this.leading,
      this.currentIndex = 0,
      this.onIndexChange,
      this.sidebarItems = const [],
      this.showTitleOnMac = true,
      this.endSidebar,
      this.onSearch});

  @override
  Widget build(BuildContext context) {
    // ignore: sort_child_properties_last
    if (Platform.isMacOS) {
      return MacosWindow(

        titleBar: title != null && showTitleOnMac
            ? TitleBar(
                title: title,
                height: 48,
              )
            : null,
        endSidebar: endSidebar,
        sidebar: sidebarItems.isEmpty
            ? null
            : Sidebar(topOffset: 48,
              top: onSearch != null ? MacosTextField(padding: const EdgeInsets.all(6.5), clearButtonMode: OverlayVisibilityMode.editing,placeholder: 'Buscar', onSubmitted: onSearch, onChanged: (value) {
                if(value.isEmpty){
                  onSearch!(value);
                }
              },prefix: const MacosIcon(CupertinoIcons.search),) : null,
                builder: (context, scrollController) => SidebarItems(
                    items: sidebarItems
                        .map((item) => SidebarItem(
                            label: Text(item.label),
                            leading: MacosIcon(item.macosIcon),
                            disclosureItems: item.items.isEmpty
                                ? null
                                : item.items
                                    .map((e) => SidebarItem(
                                            label: Flexible(
                                                child: Text(
                                          e.label,
                                          overflow: TextOverflow.ellipsis,
                                        ))))
                                    .toList()))
                        .toList(),
                    currentIndex: currentIndex,
                    onChanged: onIndexChange ?? (val) {}),
                minWidth: 200,
              ),
        child: content,
      );
    }
    return NavigationView(
      key: key,
      paneBodyBuilder: sidebarItems.isEmpty ? null : (_)=>content,
      pane: sidebarItems.isEmpty
          ? null
          : NavigationPane(
            selected: currentIndex,
              items: sidebarItems
                  .map<NavigationPaneItem>((e) => e.items.isEmpty
                      ? PaneItem(
                        title: Text(e.label),
                          icon: Icon(e.windowsIcon),
                          body: const SizedBox.shrink())
                      : PaneItemExpander(
                          body: const SizedBox.shrink(),
                          icon: Icon(e.windowsIcon),
                          title: Text(e.label),
                          items: e.items
                              .map((item) => PaneItem(title: Text(item.label),
                                  icon: Icon(item.windowsIcon),
                                  body: const SizedBox()))
                              .toList()))
                  .toList(),
              onChanged: onIndexChange),
      appBar: NavigationAppBar(
          title: Platform.isMacOS
              ? title
              : DragToMoveArea(
                  child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: title))),
      content: sidebarItems.isEmpty
          ? Row(
              children: [
                Theme(
                  data: ThemeData(
                      useMaterial3: true,
                      colorSchemeSeed: Colors.teal,
                      brightness: Brightness.dark,
                      navigationRailTheme:const NavigationRailThemeData(
                          backgroundColor: Colors.transparent,
                          minWidth: 64,
                          labelType: NavigationRailLabelType.all,
                          groupAlignment: 0)),
                  child: NavigationRail(
                    onDestinationSelected: onIndexChange,
                    destinations: sidebarItems
                        .map((e) => NavigationRailDestination(
                            icon: Icon(e.windowsIcon), label: Text(e.label)))
                        .toList(),
                    selectedIndex: currentIndex,
                  ),
                ),
                Expanded(child: content)
              ],
            )
          : null,
    );
  }
}

class AdaptiveSideBarItem {
  String label;
  IconData windowsIcon, macosIcon;
  List<AdaptiveSideBarItem> items;

  AdaptiveSideBarItem(
      {required this.label,
      required this.macosIcon,
      required this.windowsIcon,
      this.items = const []});
}
