import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:sibupel/data/provider.dart';
import 'package:sibupel/widgets/cards.dart';

class SagasScreen extends StatefulWidget {
  const SagasScreen({super.key});

  @override
  State<SagasScreen> createState() => _SagasScreenState();
}

class _SagasScreenState extends State<SagasScreen> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sagas = context.watch<DataProvider>().sagas;
    return ScaffoldPage(
      header: PageHeader(
        title: const Text("Sagas", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600)),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [CommandBarButton(onPressed: () {}, icon: const Icon(FluentIcons.add), label: const Text("Agregar"))],
        ),
      ),
      content: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: sagas.length,
          gridDelegate:
              const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 300, mainAxisSpacing: 8, crossAxisSpacing: 8),
          itemBuilder: (c, i) {
            final saga = sagas.values.toList()[i];
            return SagaCard(
              saga,
            );
          }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
