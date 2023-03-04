import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:macos_ui/macos_ui.dart';

class AdaptiveDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final void Function() onPrimaryButtonPress;
  final void Function()? onSecondaryButtonPress;
  const AdaptiveDialog(
      {super.key,
      required this.title,
      required this.content,
       this.primaryButtonText,
      this.secondaryButtonText,
      required this.onPrimaryButtonPress,
      this.onSecondaryButtonPress});

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return MacosAlertDialog(
          appIcon: FlutterLogo(),
          title: Text(title),
          message: content,
          primaryButton: Visibility(visible: primaryButtonText != null,
            child: PushButton(
              onPressed: onPrimaryButtonPress,
              buttonSize: ButtonSize.large,
              child: Text(primaryButtonText ?? ''),
            ),
          ), secondaryButton: Visibility(visible: secondaryButtonText != null,child: PushButton(isSecondary: true, onPressed: onSecondaryButtonPress, buttonSize: ButtonSize.large,child: Text(secondaryButtonText ?? ""),)),);
    }
    return ContentDialog(
      title: Text(title),
      content: content,
      actions: [
        Visibility(visible: primaryButtonText != null,
          child: FilledButton(
              onPressed: onPrimaryButtonPress, child: Text(primaryButtonText ?? "")),
        ),
        Visibility(visible: secondaryButtonText != null,
            child: Button(
          onPressed: onSecondaryButtonPress,
          child: Text(secondaryButtonText ?? ""),
        ))
      ],
    );
  }
}
