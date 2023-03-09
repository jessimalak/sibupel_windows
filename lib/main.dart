import 'dart:io';

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluent_ui/fluent_ui.dart' hide FluentIcons;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_acrylic/window_effect.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sibupel/data/movie.dart';
import 'package:sibupel/data/provider.dart';
import 'package:sibupel/firebase_options.dart';
import 'package:sibupel/screens/home/movies.dart';
import 'package:sibupel/screens/home/sagas.dart';
import 'package:sibupel/screens/home/settings.dart';
import 'package:sibupel/screens/saga.dart';
import 'package:sibupel/widgets/adaptive/window.dart';
import 'package:sibupel/widgets/dialogs.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as acrylic;
import 'package:macos_ui/macos_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  if (Platform.isWindows) {
    await acrylic.Window.initialize();
    await acrylic.Window.setEffect(effect: WindowEffect.mica);
  } else {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.macos);
  }
  WindowOptions options = const WindowOptions(
      minimumSize: Size(755, 550),
      titleBarStyle: TitleBarStyle.hidden,
      skipTaskbar: false);
  windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
  });
  await dotenv.load(fileName: ".env");
  String storageLocation = (await getApplicationDocumentsDirectory()).path;
  await FastCachedImageConfig.init(
      subDir: storageLocation, clearCacheAfter: const Duration(days: 15));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => DataProvider(),
      child: OKToast(
          child: Platform.isMacOS
              ? MacosApp(
                  title: "Sibupel",
                  debugShowCheckedModeBanner: false,
                  theme: MacosThemeData.light(),
                  darkTheme: MacosThemeData(
                      brightness: Brightness.dark,
                      primaryColor: Colors.teal,
                      popupButtonTheme: MacosPopupButtonThemeData(
                          highlightColor: Colors.teal,
                          backgroundColor:
                              const Color.fromRGBO(255, 255, 255, 0.247),
                          popupColor: MacosColors.controlColor)),
                  routes: {'/': (p0) => const MyHomePage()},
                  onGenerateRoute: (settings) {
                    if (settings.name == '/saga') {}
                  },
                )
              : FluentApp(
                  title: 'Sibupel',
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData(
                      brightness: Brightness.dark,
                      accentColor: Colors.teal,
                      navigationPaneTheme: const NavigationPaneThemeData(
                          backgroundColor: Colors.transparent)),
                  routes: {'/': (context) => const MyHomePage()},
                )),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  int index = 0;
  TextEditingController searchController = TextEditingController();
  final viewKey = GlobalKey(debugLabel: 'Navigation View Key');

  void setScreen(int newIndex) {
    setState(() {
      index = newIndex;
    });
  }

  @override
  void initState() {
    windowManager.addListener(this);
    context.read<DataProvider>().init();
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    context.read<DataProvider>().close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sagas = context.watch<DataProvider>().sagas;
    List<Widget> screens = [
      const MoviesScreen(),
      ...(sagas.isEmpty
          ? const [SagasScreen()]
          : Platform.isMacOS
              ? sagas.keys
                  .map<Widget>(
                      (e) => SagaPage(sagas[e] ?? Saga('id', 'name', [])))
                  .toList()
              : [
                  const SagasScreen(),
                  ...sagas.keys
                      .map<Widget>(
                          (e) => SagaPage(sagas[e] ?? Saga('id', 'name', [])))
                      .toList()
                ]),
      const SettingsScreen()
    ];
    return AdaptiveWindow(
      navigationKey: viewKey,
      title: const Text("Sibupel"),
      showTitleOnMac: false,
      onIndexChange: (index) {
        setScreen(index);
      },
      currentIndex: index,
      sidebarItems: [
        AdaptiveSideBarItem(
            label: 'Pelis',
            macosIcon: CupertinoIcons.film,
            windowsIcon: FluentIcons.video_clip_20_regular),
        AdaptiveSideBarItem(
            label: 'Sagas',
            macosIcon: CupertinoIcons.collections,
            items: sagas.keys
                .map((key) => AdaptiveSideBarItem(
                    label: sagas[key]?.name ?? '',
                    macosIcon: CupertinoIcons.rectangle_stack_person_crop_fill,
                    windowsIcon: FluentIcons.access_time_20_filled))
                .toList(),
            windowsIcon: FluentIcons.video_clip_multiple_20_regular),
        AdaptiveSideBarItem(
            label: 'Ajustes',
            macosIcon: CupertinoIcons.settings,
            windowsIcon: FluentIcons.settings_20_regular)
      ],
      content: IndexedStack(
        index: index,
        children: screens,
      ),
      endSidebar: Sidebar(
          shownByDefault: false,
          //
          topOffset: 0,
          builder: (context, scrollController) => SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              controller: scrollController,
              child: const SidebarMovieInfo()),
          minWidth: 256),
    );
  }
}
