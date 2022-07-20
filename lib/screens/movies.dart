import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:sibupel/data/movie.dart';
import 'package:sibupel/data/provider.dart';
import 'package:sibupel/widgets/cards.dart';
import 'package:sibupel/widgets/dialogs.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MovieScreen();
}

class _MovieScreen extends State<MoviesScreen> {
  Map<String, Map<String, dynamic>> searchOptions = {
    "Titulo": {"field": SearchField.title, "icon": FluentIcons.text_field},
    "Lanzamiento": {"field": SearchField.year, "icon": FluentIcons.calendar},
    "Director": {"field": SearchField.director, "icon": FluentIcons.people}
  };

  Map<String, dynamic>? searchType;
  TextEditingController searchController = TextEditingController();
  List<String> genders_ = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      searchType = searchOptions["Titulo"];
    });
  }

  void search() {
    context.read<DataProvider>().searchByData(searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    var movies = context.watch<DataProvider>().movies;
    var user = context.watch<DataProvider>().user;
    return ScaffoldPage(
      bottomBar: SizedBox(
          height: 48,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: genders.length,
              itemBuilder: (c, i) => genders_.contains(genders[i]["name"])
                  ? Chip.selected(
                      onPressed: () {
                        int index = genders_.indexWhere(
                            (element) => element == genders[i]["name"]);
                        if (index > -1) {
                          genders_.removeAt(index);
                        }
                        context.read<DataProvider>().searchByGender(genders_);
                      },
                      image: Text(genders[i]["emoji"] ?? ""),
                      text: Text(genders[i]["name"] ?? ""))
                  : Chip(
                      onPressed: () {
                        genders_.add(genders[i]["name"] ?? "non");

                        context.read<DataProvider>().searchByGender(genders_);
                      },
                      image: Text(genders[i]["emoji"] ?? ""),
                      text: Text(genders[i]["name"] ?? ""),
                    ))),
      header: PageHeader(
        title: Text("Mis Peliculas (${movies.length})"),
        commandBar: Row(children: [
          ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250),
              child: TextBox(
                controller: searchController,
                placeholder: "Buscar...",
                prefix: const Icon(FluentIcons.search),
                onEditingComplete: () {
                  search();
                },
                suffix: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(FluentIcons.clear),
                        onPressed: () {
                          searchController.text = "";
                          context.read<DataProvider>().resetSearch();
                        }),
              )),
          IconButton(
            icon: const Icon(FluentIcons.add),
            onPressed: () {
              Dialogs.showAddMovieDialog(context);
            },
          )
        ]),
      ),
      content: user == null
          ? Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text("Click en "),
                  Icon(FluentIcons.settings),
                  Text(" para iniciar sesión")
                ],
              ),
            )
          : ResponsiveGridList(
              horizontalGridMargin: 16,
              minItemWidth: 200,
              children:
                  movies.map((movie) => MovieCard(movie: movie)).toList()),
    );
  }
}
