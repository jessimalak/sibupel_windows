import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:sibupel/widgets/selector.dart';

class AdaptiveDropdown<T> extends StatelessWidget {
  final List<AdaptiveDropdownItem> items;
  final void Function(T? value) onChanged;
  final T? value;
  final String placeholder;
  const AdaptiveDropdown(
      {super.key, required this.items, required this.onChanged, this.value, this.placeholder = ''});

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return MacosPopupButton<T>(
        value: value,
        hint: Text(placeholder),
          items: items
              .map((e) => MacosPopupMenuItem<T>(
                    value: e.value,
                    child: e.title,
                  ))
              .toList(),
          onChanged: onChanged);
    }
    return ComboBox(value: value,
    placeholder: Text(placeholder),
      items: items
          .map((e) => ComboBoxItem<T>(value: e.value, child: e.title))
          .toList(),
      onChanged: onChanged,
    );
  }
}
