import 'package:fluent_ui/fluent_ui.dart';
import 'package:sibupel/widgets/selector.dart';

enum ToolBaItemType { button, dropdown, textField, pulldown }

class AdaptiveToolBarItem<T> {
  ToolBaItemType type;
  String label;
  IconData? windowsIcon, macIcon;
  void Function()? onPressed;
  void Function(T value)? onChanged;
  T? value;
  bool showLabel;
  List<AdaptiveDropdownItem<T>> dropdownItems;

  AdaptiveToolBarItem(
      {required this.type,
      this.label = '',
      this.windowsIcon,
      this.macIcon,
      this.onChanged,
      this.onPressed,
      this.showLabel = false,
      this.dropdownItems = const [], this.value});
}
