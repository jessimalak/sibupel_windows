import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';
import 'package:sibupel/data/movie.dart';
import 'package:sibupel/data/provider.dart';
import 'package:sibupel/widgets/adaptive/card.dart';
import 'package:sibupel/widgets/adaptive/scaffold.dart';
import 'package:sibupel/widgets/adaptive/toolbar_item.dart';
import 'package:sibupel/widgets/cards.dart';
import 'package:sibupel/widgets/dialogs.dart';
import 'package:sibupel/widgets/selector.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MovieScreen();
}

class _MovieScreen extends State<MoviesScreen>
    with AutomaticKeepAliveClientMixin {
  List<String> genders_ = [];
  OrderBy _orderBy = OrderBy.random;

  @override
  void initState() {
    print('inited movie');
    super.initState();
  }

  // void search() {
  //   context.read<DataProvider>().searchByData(searchController.text);
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var movies = context.watch<DataProvider>().movies;
    var isAuth = context.watch<DataProvider>().isAuth;
    var isLoading = context.watch<DataProvider>().isLoading;
    var selected = context.watch<DataProvider>().selectedMovie;
    return AdaptiveScaffold(
      key: const ValueKey('movies'),
      actions: [
        AdaptiveToolBarItem(
          type: ToolBaItemType.dropdown,
          label: 'Ordenar por: ',
          macIcon: CupertinoIcons.sort_down,
          value: _orderBy,
          dropdownItems: OrderBy.values
              .map((e) => AdaptiveDropdownItem(Text(e.label), e))
              .toList(),
          onChanged: (value) {
            context.read<DataProvider>().orderMovies(value);
            setState(() {
              _orderBy = value;
            });
          },
        ),
        AdaptiveToolBarItem(
          type: ToolBaItemType.button,
          macIcon: CupertinoIcons.add,
          windowsIcon: FluentIcons.add,
          onPressed: () {
            Dialogs.showAddMovieDialog(context);
          },
        ),
        AdaptiveToolBarItem(
                type: selected != null
                    ? ToolBaItemType.button
                    : ToolBaItemType.empty,
                macIcon: CupertinoIcons.sidebar_right,
                windowsIcon: CupertinoIcons.add,
                onPressed: () {
                  setState(() {
                    MacosWindowScope.of(context).toggleEndSidebar();
                    Future.delayed(const Duration(milliseconds: 200),(){
                      context.read<DataProvider>().selectedMovie = null;
                    });
                  });
                },
              )
            
      ],
      content: !isAuth
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
          : isLoading
              ? SingleChildScrollView(
                  child: Wrap(
                  children: const [
                    ShimmerCard(),
                    ShimmerCard(),
                    ShimmerCard(),
                    ShimmerCard(),
                    ShimmerCard(),
                    ShimmerCard(),
                    ShimmerCard(),
                    ShimmerCard(),
                  ],
                ))
              : movies.isEmpty
                  ? const Center(
                      child: Text("Sin peliculas"),
                    )
                  : GridView.builder(
                      itemCount: movies.length,
                      padding: Platform.isMacOS
                          ? const EdgeInsets.all(16)
                          : const EdgeInsets.symmetric(horizontal: 8),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                              mainAxisExtent: 432,
                              maxCrossAxisExtent: 256,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.55),
                      itemBuilder: (c, i) => MovieCard(movie: movies[i])),
      title: Platform.isMacOS
          ? Text('Mis Peliculas (${movies.length})')
          : RichText(
              text: TextSpan(children: [
                const TextSpan(
                    text: "Mis Peliculas ",
                    style:
                        TextStyle(fontSize: 32, fontWeight: FontWeight.w600)),
                TextSpan(text: "(${movies.length})")
              ]),
            ),
      bottomBar: SizedBox(
          height: 48,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: genders.length,
              itemBuilder: (c, i) => AdaptiveChip(
                    selected: genders_.contains(genders[i]["name"]),
                    onPressed: () {
                      if (genders_.contains(genders[i]["name"])) {
                        int index = genders_.indexWhere(
                            (element) => element == genders[i]["name"]);
                        if (index > -1) {
                          genders_.removeAt(index);
                        }
                      } else {
                        genders_.add(genders[i]["name"] ?? "non");
                      }
                      context.read<DataProvider>().searchByGender(genders_);
                    },
                    leading: Text(genders[i]["emoji"] ?? ""),
                    child: Text(genders[i]["name"] ?? ""),
                  ))),
    );
    // ScaffoldPage(
    //     bottomBar: SizedBox(
    //         height: 48,
    //         child: ListView.builder(
    //             scrollDirection: Axis.horizontal,
    //             itemCount: genders.length,
    //             itemBuilder: (c, i) => genders_.contains(genders[i]["name"])
    //                 ? Chip.selected(
    //                     onPressed: () {
    //                       int index = genders_.indexWhere((element) => element == genders[i]["name"]);
    //                       if (index > -1) {
    //                         genders_.removeAt(index);
    //                       }
    //                       context.read<DataProvider>().searchByGender(genders_);
    //                     },
    //                     image: Text(genders[i]["emoji"] ?? ""),
    //                     text: Text(genders[i]["name"] ?? ""))
    //                 : Chip(
    //                     onPressed: () {
    //                       genders_.add(genders[i]["name"] ?? "non");

    //                       context.read<DataProvider>().searchByGender(genders_);
    //                     },
    //                     image: Text(genders[i]["emoji"] ?? ""),
    //                     text: Text(genders[i]["name"] ?? ""),
    //                   ))),
    //     header: PageHeader(
    //       title: RichText(
    //         text: TextSpan(children: [
    //           const TextSpan(text: "Mis Peliculas ", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600)),
    //           TextSpan(text: "(${movies.length})")
    //         ]),
    //       ),
    //       commandBar: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
    //         OrderBySelector(
    //             value: _orderBy,
    //             onChanged: (value) {
    //               _orderBy = value;
    //               context.read<DataProvider>().orderMovies(_orderBy);
    //             }),
    //         const SizedBox(
    //           width: 16,
    //         ),
    //         IconButton(
    //           icon: const Icon(FluentIcons.add),
    //           onPressed: () {
    //             if (context.read<DataProvider>().isAuth) {
    //               Dialogs.showAddMovieDialog(context);
    //             }
    //           },
    //         )
    //       ]),
    //     ),
    //     content: !isAuth
    //         ? Center(
    //             child: Row(
    //               mainAxisSize: MainAxisSize.min,
    //               children: const [Text("Click en "), Icon(FluentIcons.settings), Text(" para iniciar sesión")],
    //             ),
    //           )
    //         : isLoading
    //             ? SingleChildScrollView(
    //                 child: Wrap(
    //                 children: const [
    //                   ShimmerCard(),
    //                   ShimmerCard(),
    //                   ShimmerCard(),
    //                   ShimmerCard(),
    //                   ShimmerCard(),
    //                   ShimmerCard(),
    //                   ShimmerCard(),
    //                   ShimmerCard(),
    //                 ],
    //               ))
    //             : movies.isEmpty
    //                 ? const Center(
    //                     child: Text("Sin peliculas"),
    //                   )
    //                 : GridView.builder(
    //                     itemCount: movies.length,
    //                     padding: const EdgeInsets.symmetric(horizontal: 8),
    //                     gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
    //                         mainAxisExtent: 432,
    //                         maxCrossAxisExtent: 256,
    //                         crossAxisSpacing: 8,
    //                         mainAxisSpacing: 8,
    //                         childAspectRatio: 0.55),
    //                     itemBuilder: (c, i) => MovieCard(movie: movies[i]))

    //     // ResponsiveGridList(
    //     //     horizontalGridMargin: 16, minItemWidth: 200, children: movies.map((movie) => MovieCard(movie: movie)).toList()

    //     //     ),
    //     );
  }

  @override
  bool get wantKeepAlive => true;
}
