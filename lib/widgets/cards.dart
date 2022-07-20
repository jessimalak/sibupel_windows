import 'package:fluent_ui/fluent_ui.dart' hide MenuItem;
import 'package:native_context_menu/native_context_menu.dart' as cm;
import 'package:sibupel/widgets/dialogs.dart';

import '../data/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) => Stack(children: [
        GestureDetector(
            onTap: () {
              Dialogs.showMovieInfo(context, movie);
            },
            child: cm.ContextMenuRegion(onItemSelected: (item){
              switch(item.title){
                case "Actualizar":
                  Dialogs.showAddMovieDialog(context, movie: movie);
                  break;
                case "Eliminar":
                  Dialogs.showDeleteMovieConfirmation(context, movie);
                  break;
              }
            },menuItems: [cm.MenuItem(title: "Actualizar"), cm.MenuItem(title: "Eliminar")],
            child: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                      tag: "${movie.id}-poster",
                      child: movie.poster != null
                          ? Image.network(
                              movie.poster ?? "", errorBuilder: (c, obj, stake)=> Image.asset("assets/poster.jpg"),
                              loadingBuilder: (c, child, progress) =>
                                  progress == null
                                      ? child
                                      : const SizedBox(
                                          width: 200,
                                          height: 300,
                                          child: Center(
                                              child: SizedBox(
                                                  width: 80,
                                                  height: 80,
                                                  child: ProgressRing())),
                                        ),
                            )
                          : Image.asset("assets/poster.jpg")),
                  Hero(
                      tag: "${movie.id}-title",
                      child: Text(
                        movie.title,
                        style: const TextStyle(fontSize: 24),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      )),
                  Text(movie.director, textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ))),
        Positioned(
            top: 0,
            right: 0,
            child: ClipPath(
              clipper: TriangleClipper(),
              child: Container(
                padding: const EdgeInsets.only(top: 10, left: 10),
                color: Colors.teal,
                width: 56,
                height: 56,
                child: Transform.rotate(
                  angle: 44.8,
                  child: Text(
                    movie.launchDate.toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )),
      ]);
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, 0.0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
