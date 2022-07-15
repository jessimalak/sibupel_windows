import 'package:fluent_ui/fluent_ui.dart';
import 'package:ribbon_widget/ribbon_widget.dart';

import '../data/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) => Stack(children: [
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              movie.poster != null
                  ? Image.network(movie.poster ?? "")
                  : Text("sin poster"),
              Text(
                movie.title,
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              Text(movie.director),
            ],
          ),
        ),
        Positioned(
            top: 0,
            right: 0,
            child: ClipPath(
              clipper: TriangleClipper(),
              child: Container(padding: EdgeInsets.only(top: 10, left: 10),
                color: Colors.teal,
                width: 56,
                height: 56,
                child: Transform.rotate(angle: 44.8, child: Text(movie.launchDate.toString(), style: TextStyle(fontSize: 16),),) ,
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
