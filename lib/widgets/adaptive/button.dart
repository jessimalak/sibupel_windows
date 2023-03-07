import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:macos_ui/macos_ui.dart';

class AdaptiveButton extends StatelessWidget {
  final String label;
  final ButtonSize buttonSize;
  final void Function() onPressed;
  final List<Color> stateColors;
  const AdaptiveButton(
      {super.key,
      required this.label,
      this.buttonSize = ButtonSize.large,
      required this.onPressed,
      this.stateColors = const []});

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return PushButton(
        buttonSize: buttonSize,
        onPressed: onPressed,
        color: stateColors.isNotEmpty ? stateColors[0] : null,
        child: Text(label),
      );
    }
    return FilledButton(
      onPressed: onPressed,
      style: stateColors.length < 3
          ? null
          : ButtonStyle(backgroundColor: ButtonState.resolveWith((states) {
              if (states.contains(ButtonStates.pressing)) {
                return stateColors[0];
              }
              if (states.contains(ButtonStates.hovering)) {
                return stateColors[1];
              }
              return stateColors[2];
            })),
      child: Text(label),
    );
  }
}

class AdaptiveCheckbox extends StatelessWidget {
  final bool isChecked;
  final void Function(bool? isChecked) onChanged;
  final Widget content;
  const AdaptiveCheckbox(
      {super.key,
      required this.isChecked,
      required this.onChanged,
      required this.content});

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MacosCheckbox(value: isChecked, onChanged: onChanged),
          const SizedBox(
            width: 4,
          ),
          content
        ],
      );
    }
    return Checkbox(
      checked: isChecked,
      onChanged: onChanged,
      content: content,
    );
  }
}
