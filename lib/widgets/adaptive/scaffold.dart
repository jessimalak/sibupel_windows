import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:sibupel/widgets/adaptive/toolbar_item.dart';

class AdaptiveScaffold extends StatelessWidget {
  final Widget content, title;
  final List<AdaptiveToolBarItem> actions;
  final bool macosButtonsSpace;
  final bool centerTitle;
  final bool wrapMacosNavigator;
  final GlobalKey<NavigatorState>? navigationKey;
  const AdaptiveScaffold(
      {super.key,
      required this.content,
      required this.title,
      this.actions = const [],
      this.macosButtonsSpace = false,
      this.centerTitle = false,
      this.wrapMacosNavigator = false,
      this.navigationKey});

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      final scaffold = MacosScaffold(
          toolBar: ToolBar(
            // titleWidth: 500,
            centerTitle: centerTitle,
            padding: macosButtonsSpace
                ? const EdgeInsets.fromLTRB(96, 4, 8, 4)
                : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            actions: actions.map((action) {
              switch (action.type) {
                case ToolBaItemType.button:
                  return ToolBarIconButton(
                      icon: MacosIcon(action.macIcon),
                      onPressed: action.onPressed,
                      label: action.label,
                      showLabel: action.showLabel);
                case ToolBaItemType.pulldown:
                  return ToolBarPullDownButton(
                      label: action.label,
                      icon: action.macIcon ?? CupertinoIcons.add,
                      items: action.dropdownItems
                          .map((item) => MacosPulldownMenuItem(
                                title: item.title,
                                onTap: () {
                                  action.onChanged!(item.value);
                                },
                              ))
                          .toList());
                case ToolBaItemType.textField:
                  // TODO: Handle this case.
                  break;
                case ToolBaItemType.dropdown:
                  return CustomToolbarItem(
                      inToolbarBuilder: (context) => MacosPopupButton(
                          value: action.value,
                          items: action.dropdownItems
                              .map((e) => MacosPopupMenuItem(
                                    value: e.value,
                                    child: e.title,
                                  ))
                              .toList(),
                          onChanged: action.onChanged));
              }
              return const ToolBarSpacer();
            }).toList(),
            title: title,
          ),
          children: [ContentArea(builder: (c, controller) => content)]);
      return wrapMacosNavigator
          ? CupertinoTabView(
              navigatorKey: navigationKey,
              builder: (context) => scaffold,
            )
          : scaffold;
    }
    return ScaffoldPage(
      content: content,
      header: PageHeader(
        commandBar: Row(
            children: actions.map((action) {
          if (action.type == ToolBaItemType.button) {
            return IconButton(
                icon: Icon(action.windowsIcon), onPressed: action.onPressed);
          }
          return const SizedBox.shrink();
        }).toList()),
        title: title,
      ),
    );
  }
}
