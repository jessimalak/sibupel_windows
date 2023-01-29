import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart' hide FluentIcons;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sibupel/data/provider.dart';
import 'package:sibupel/screens/home.dart';
import 'package:sibupel/widgets/dialogs.dart';
import 'package:sibupel/widgets/window.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as acrylic;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await acrylic.Window.initialize();
  WindowOptions options = const WindowOptions(minimumSize: Size(755, 550), titleBarStyle: TitleBarStyle.hidden, skipTaskbar: false);
  windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
  });
  await dotenv.load(fileName: ".env");
  String storageLocation = (await getApplicationDocumentsDirectory()).path;
  await FastCachedImageConfig.init(subDir: storageLocation, clearCacheAfter: const Duration(days: 15));
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
          child: FluentApp(
        title: 'Sibupel',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(brightness: Brightness.dark, accentColor: Colors.teal),
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
    return Listener(
      onPointerDown: (event) {
        ContextMenuController.removeAny();
      },
      child: NavigationView(
        key: viewKey,
        appBar: NavigationAppBar(
            backgroundColor: Colors.transparent,
            leading: Image.asset(
              "assets/app_icon.ico",
              height: 24,
            ),
            title: const DragToMoveArea(child: Align(alignment: AlignmentDirectional.centerStart, child: Text("Sibupel"))),
            actions: Row(
              children: [
                const Spacer(),
                ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 250, minWidth: 64),
                    child: TextBox(
                      controller: searchController,
                      placeholder: "Buscar...",
                      prefix: const Icon(FluentIcons.search_20_regular),
                      onEditingComplete: () {
                        context.read<DataProvider>().searchByData(searchController.text);
                      },
                      suffix: IconButton(
                          icon: const Icon(FluentIcons.dismiss_16_regular),
                          onPressed: () {
                            searchController.text = "";
                            context.read<DataProvider>().resetSearch();
                          }),
                    )),
                const Spacer(),
                IconButton(
                    icon: const Icon(FluentIcons.info_20_regular),
                    onPressed: () {
                      showGeneralDialog(
                          barrierLabel: "label",
                          barrierDismissible: true,
                          context: context,
                          pageBuilder: ((context, animation, secondaryAnimation) => ContentDialog(
                                title: const Text("Acerca de Sibupel"),
                                content: Row(children: [
                                  Image.asset(
                                    "assets/app_icon.ico",
                                    height: 56,
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        "Versión 1.3.0",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      Text("Developed by Malak;")
                                    ],
                                  )
                                ]),
                              )));
                    }),
                IconButton(
                    icon: const Icon(FluentIcons.note_pin_20_regular),
                    onPressed: () {
                      Dialogs.showWaitList(context);
                    }),
                IconButton(
                    icon: const Icon(FluentIcons.settings_20_regular),
                    onPressed: () {
                      Dialogs.showSettingsDialog(context);
                    }),
                const WindowButtons()
              ],
            )),
        content: const HomePage(),

        // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
