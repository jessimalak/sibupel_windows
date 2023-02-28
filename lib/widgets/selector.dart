import 'package:fluent_ui/fluent_ui.dart';
import 'package:sibupel/data/provider.dart';

class OrderBySelector extends StatelessWidget {
  final OrderBy value;
  final void Function(OrderBy value) onChanged;
  const OrderBySelector({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Text('Orden: '),
      ComboBox(
        value: value,
        items: OrderBy.values.map((e) => ComboBoxItem(value: e, child: Text(e.label))).toList(),
        onChanged: (OrderBy? value) {
          onChanged(value ?? OrderBy.random);
        },
      ),
    ]);
  }
}
