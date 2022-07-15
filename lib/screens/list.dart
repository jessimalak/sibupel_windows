import 'package:fluent_ui/fluent_ui.dart';

class ListScreen extends StatefulWidget{
  const ListScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ListScreen();

}

class _ListScreen extends State<ListScreen>{
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: const Text("Lista de espera"),
        commandBar: IconButton(
          icon: const Icon(FluentIcons.add),
          onPressed: () {
            showDialog(
                context: context,
                builder: (c) => ContentDialog(
                  title: const Text("Agregar peli a la lista"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text("Agregar peliculón")],
                  ),actions: [FilledButton(child: const Text("Guardar"), onPressed: (){Navigator.pop(context);}),Button(child:const Text("Cerrar"), onPressed: (){Navigator.pop(context);})],
                ));
          },
        ),
      ),
      content: const Center(
        child: Text("Lista"),
      ),
    );
  }

}