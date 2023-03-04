import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:macos_ui/macos_ui.dart';

class AdaptiveButton extends StatelessWidget{
  final String label;
  final ButtonSize buttonSize;
  final void Function() onPressed;
  const AdaptiveButton({super.key,required this.label, this.buttonSize = ButtonSize.large, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    if(Platform.isMacOS){
      return PushButton(buttonSize: buttonSize, onPressed: onPressed, child: Text(label),);
    }
    return FilledButton(onPressed: onPressed, child: Text(label));
  }

}

class AdaptiveCheckbox extends StatelessWidget{
  final bool isChecked;
  final void Function(bool? isChecked) onChanged;
  final Widget content;
  const AdaptiveCheckbox({super.key, required this.isChecked, required this.onChanged, required this.content});

  @override
  Widget build(BuildContext context) {
    if(Platform.isMacOS){
      return Row(mainAxisSize: MainAxisSize.min,
        children: [
          MacosCheckbox(value: isChecked, onChanged: onChanged),
          const SizedBox(width: 4,),
          content
        ],
      );
    }
    return Checkbox(checked: isChecked, onChanged: onChanged, content: content,);
  }

}