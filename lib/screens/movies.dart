import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:sibupel/data/provider.dart';
import 'package:sibupel/widgets/cards.dart';
import 'package:sibupel/widgets/dialogs.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MovieScreen();
}

class _MovieScreen extends State<MoviesScreen> {
  @override
  void initState() {
    super.initState();
    print("inited movies screen");
  }

  @override
  Widget build(BuildContext context) {
    var movies = context.watch<DataProvider>().movies;
    return ScaffoldPage(
      header: PageHeader(
        title: const Text("Mis Peliculas"),
        commandBar: IconButton(
          icon: const Icon(FluentIcons.add),
          onPressed: () {
            Dialogs.showAddMovieDialog(context);
          },
        ),
      ),
      content: ResponsiveGridList(horizontalGridMargin: 16,
          minItemWidth: 200,
          children: movies.map((movie) => MovieCard(movie: movie)).toList()),
    );
  }
}
