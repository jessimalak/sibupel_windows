import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sibupel/data/provider.dart';
import 'package:sibupel/widgets/adaptive/scaffold.dart';
import 'package:sibupel/widgets/adaptive/toolbar_item.dart';
import 'package:sibupel/widgets/cards.dart';

class SagasScreen extends StatefulWidget {
  const SagasScreen({super.key});

  @override
  State<SagasScreen> createState() => _SagasScreenState();
}

class _SagasScreenState extends State<SagasScreen> {
  @override
  Widget build(BuildContext context) {
    final sagas = context.watch<DataProvider>().sagas;
    return AdaptiveScaffold(
      key: const ValueKey('sagas'),
      title: Platform.isMacOS
          ? const Text("Sagas")
          : const Text(
              "Sagas",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
            ),
      actions: [
        AdaptiveToolBarItem(
            type: ToolBaItemType.button,
            label: 'Agregar',
            macIcon: CupertinoIcons.add,
            windowsIcon: FluentIcons.add)
      ],
      // PageHeader(
      //   title: ,
      //   commandBar: CommandBar(
      //     mainAxisAlignment: MainAxisAlignment.end,
      //     primaryItems: [CommandBarButton(onPressed: () {}, icon: const Icon(FluentIcons.add), label: const Text("Agregar"))],
      //   ),
      // ),
      content: GridView.builder(
          padding: Platform.isMacOS
              ? const EdgeInsets.all(16)
              : const EdgeInsets.symmetric(horizontal: 8),
          itemCount: sagas.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300, mainAxisSpacing: 8, crossAxisSpacing: 8),
          itemBuilder: (c, i) {
            final saga = sagas.values.toList()[i];
            return SagaCard(
              saga,
            );
          }),
    );
  }
}
