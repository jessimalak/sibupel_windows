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
  final BoxConstraints constraints;
  const AdaptiveDialog(
      {super.key,
      required this.title,
      required this.content,
      this.primaryButtonText,
      this.secondaryButtonText,
      required this.onPrimaryButtonPress,
      this.onSecondaryButtonPress,
      this.constraints = const BoxConstraints(maxWidth: 368)});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final padding = (width / 4);
    if (Platform.isMacOS) {
      return MacosSheet(insetPadding: EdgeInsets.symmetric(horizontal: padding, vertical:  48),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Text(title, style:const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
            const SizedBox(height: 16,),
            Expanded(child: content),
            const SizedBox(height: 16,),
            Row(mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                  visible: primaryButtonText != null,
                  child: PushButton(
                    onPressed: onPrimaryButtonPress,
                    buttonSize: ButtonSize.large,
                    child: Text(primaryButtonText ?? ''),
                  ),
                ),Visibility(visible: secondaryButtonText != null,child: PushButton(isSecondary: true, onPressed: onSecondaryButtonPress, buttonSize: ButtonSize.large,child: Text(secondaryButtonText ?? ""),))
              ],
            )
          ]),
        ),
      );
    }
    return ContentDialog(
      title: Text(title),
      content: content,
      constraints: constraints,
      actions: [
        Visibility(
          visible: primaryButtonText != null,
          child: FilledButton(
              onPressed: onPrimaryButtonPress,
              child: Text(primaryButtonText ?? "")),
        ),
        Visibility(
            visible: secondaryButtonText != null,
            child: Button(
              onPressed: onSecondaryButtonPress,
              child: Text(secondaryButtonText ?? ""),
            ))
      ],
    );
  }
}
