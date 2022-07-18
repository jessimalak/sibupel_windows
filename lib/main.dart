import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sibupel/data/provider.dart';
import 'package:sibupel/screens/list.dart';
import 'package:sibupel/screens/movies.dart';
import 'package:sibupel/widgets/dialogs.dart';
import 'package:sibupel/widgets/window.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions options = const WindowOptions(
      minimumSize: Size(755, 550),
      titleBarStyle: TitleBarStyle.hidden,
      skipTaskbar: false);
  windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
  });
  await dotenv.load(fileName: ".env");
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
        home: const MyHomePage(),
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
    return NavigationView(
        appBar: NavigationAppBar(
            leading: Image.asset(
              "assets/app_icon.ico",
              height: 24,
            ),
            title: const DragToMoveArea(
                child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text("Sibupel"))),
            actions: Row(
              children: [
                const Spacer(),
                IconButton(
                    icon: const Icon(FluentIcons.note_pinned),
                    onPressed: () {
                      Dialogs.showWaitList(context);
                    }),
                IconButton(
                    icon: const Icon(FluentIcons.settings),
                    onPressed: () {
                      Dialogs.showSettingsDialog(context);
                    }),
                const WindowButtons()
              ],
            )),
        content: NavigationBody(
          index: index,
          children: const [MoviesScreen()],
        )
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
