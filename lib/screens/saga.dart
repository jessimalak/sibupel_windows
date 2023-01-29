import 'package:fluent_ui/fluent_ui.dart';
import 'package:sibupel/data/movie.dart';
import 'package:sibupel/widgets/cards.dart';
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
  final GlobalKey<AnimatedGridState> _listKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Future future = Future(() => null);
    for (var i = 0; i < widget.saga.movies.length; i++) {
      future = future.then((value) => Future.delayed(const Duration(milliseconds: 100), () {
            movies.add(widget.saga.movies[i]);
            _listKey.currentState!.insertItem(i);
          }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
          title: const DragToMoveArea(child: Align(alignment: AlignmentDirectional.centerStart, child: Text("Sibupel"))),
          actions: Row(
            children: const [Spacer(), WindowButtons()],
          )),
      content: ScaffoldPage(
        header: PageHeader(
          title: RichText(
            text: TextSpan(children: [
              TextSpan(text: '${widget.saga.name} ', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600)),
              TextSpan(text: "(${widget.saga.movies.length})")
            ]),
          ),
        ),
        content: AnimatedGrid(
            key: _listKey,
            initialItemCount: 0,
            itemBuilder: (c, i, a) => ScaleTransition(
                  scale: a,
                  child: MovieCard(
                    movie: widget.saga.movies[i],
                    extraTag: widget.saga.id,
                  ),
                ),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                mainAxisExtent: 432, maxCrossAxisExtent: 256, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.55)),
      ),
    );
  }
}
