import 'package:fluent_ui/fluent_ui.dart' hide FluentIcons, IconButton;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart'
    show
        NavigationRail,
        NavigationRailDestination,
        TabController,
        TabBarView,
        Theme,
        ThemeData,
        NavigationRailThemeData,
        NavigationRailLabelType;
import 'package:sibupel/screens/home/movies.dart';
import 'package:sibupel/screens/home/sagas.dart';
import 'package:sibupel/screens/home/settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _index = 0;
  late TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Theme(
          data: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Colors.teal,
              brightness: Brightness.dark,
              navigationRailTheme: NavigationRailThemeData(
                  backgroundColor: Colors.grey[170], minWidth: 64, labelType: NavigationRailLabelType.all, groupAlignment: 0)),
          child: NavigationRail(
            onDestinationSelected: (value) {
              _tabController.animateTo(value);
              setState(() {
                _index = value;
              });
            },
            destinations: const [
              NavigationRailDestination(
                  icon: Icon(FluentIcons.video_clip_20_regular),
                  selectedIcon: Icon(FluentIcons.video_clip_20_filled),
                  label: Text("Pelis")),
              NavigationRailDestination(
                  icon: Icon(FluentIcons.video_clip_multiple_20_regular),
                  selectedIcon: Icon(FluentIcons.video_clip_multiple_20_filled),
                  label: Text("Sagas")),
              NavigationRailDestination(
                  icon: Icon(FluentIcons.settings_20_regular),
                  selectedIcon: Icon(FluentIcons.settings_20_filled),
                  label: Text("Ajustes"))
            ],
            selectedIndex: _index,
          ),
        ),
        Expanded(child: TabBarView(controller: _tabController, children: const [MoviesScreen(), SagasScreen(), SettingsScreen()]))
      ],
    );
  }
}
