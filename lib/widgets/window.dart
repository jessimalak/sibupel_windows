import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 138,
        height: 50,
        child: WindowCaption(
          brightness: Brightness.dark,
          backgroundColor: Colors.transparent,
        ),
      );
}
