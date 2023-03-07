import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:sibupel/data/movie.dart';
import 'package:sibupel/data/provider.dart';
import 'package:sibupel/widgets/adaptive/scaffold.dart';
import 'package:sibupel/widgets/adaptive/window.dart';
import 'package:sibupel/widgets/cards.dart';
import 'package:sibupel/widgets/selector.dart';
import 'package:sibupel/widgets/window.dart';
import 'package:window_manager/window_manager.dart';

class SagaPage extends StatefulWidget {
  final Saga saga;
  const SagaPage(this.saga, {super.key});

  @override
  State<SagaPage> createState() => _SagaPageState();
}

class _SagaPageState extends State<SagaPage> {
  List<Movie> movies = [];
  OrderBy _orderBy = OrderBy.random;
  final GlobalKey<AnimatedGridState> _listKey = GlobalKey();

  @override
  void initState() {
    movies = widget.saga.movies;
    super.initState();
  }

  void orderBy() {
    switch (_orderBy) {
      case OrderBy.random:
        movies.sort((a, b) => a.id.compareTo(b.id));
        break;
      case OrderBy.year:
        movies.sort((a, b) => a.launchDate.compareTo(b.launchDate));
        break;
      case OrderBy.originalTitle:
        movies.sort((a, b) => a.originalTitle.compareTo(b.originalTitle));
        break;
      case OrderBy.title:
        movies.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
    // _listKey.currentState!.setState(() {});
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
        // macosButtonsSpace: true,
        title: Platform.isMacOS
            ? Text('${widget.saga.name} (${widget.saga.movies.length})')
            : RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: '${widget.saga.name} ',
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.w600)),
                  TextSpan(text: "(${widget.saga.movies.length})")
                ]),
              ),
        // header: PageHeader(

        //   commandBar: Row(
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: [
        //       OrderBySelector(
        //           value: _orderBy,
        //           onChanged: (value) {
        //             _orderBy = value;
        //             orderBy();
        //           })
        //     ],
        //   ),
        // ),
        content: GridView.builder(
            key: _listKey,
            itemCount: movies.length,
            padding: Platform.isMacOS
                ? const EdgeInsets.all(16)
                : const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (
              c,              i,
            ) =>
                MovieCard(
                  movie: widget.saga.movies[i],
                  extraTag: widget.saga.id,
                ),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                mainAxisExtent: 432,
                maxCrossAxisExtent: 256,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.55)),
      );
  }
}
