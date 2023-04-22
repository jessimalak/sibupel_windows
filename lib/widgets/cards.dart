import 'dart:io';

import 'package:contextual_menu/contextual_menu.dart';
// import 'package:desktop_context_menu/desktop_context_menu.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:macos_ui/macos_ui.dart';
// import 'package:native_context_menu/native_context_menu.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sibupel/data/provider.dart';
import 'package:sibupel/screens/saga.dart';
import 'package:sibupel/widgets/adaptive/card.dart';
import 'package:sibupel/widgets/adaptive/window.dart';
import 'package:sibupel/widgets/dialogs.dart';

import '../data/movie.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;
  final String extraTag;
  const MovieCard({super.key, required this.movie, this.extraTag = ''});

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  final ContextMenuController _menuController = ContextMenuController();
  Menu? _menu;

  @override
  void dispose() {
    _menuController.remove();
    super.dispose();
  }

  void _show(Offset position) {
    final sagas = context.read<DataProvider>().sagas;
    _menu ??= Menu(items: [
      MenuItem.submenu(
          label: 'Agregar a saga',
          submenu: Menu(items: [
            MenuItem(
              label: 'Crear saga',
              onClick: (menuItem) async {
                var name = await Dialogs.showAddSagaDialog(context);
                if (name == null) return;
                var loading = LoadingDialog(context)
                  ..show('Creando saga $name...');
                await context
                    .read<DataProvider>()
                    .createSaga(name, widget.movie);
                loading.dismiss();
              },
            ),
            MenuItem.separator(),
            ...sagas.keys.map((id) => MenuItem.checkbox(
                  label: sagas[id]?.name,
                  checked: widget.movie.sagas.contains(id),
                  onClick: (menuItem)async {
                    var loading = LoadingDialog(context)..show('Agregando ${widget.movie.title} a ${sagas[id]?.name}');
                    var isSaved = await context.read<DataProvider>().addMovieToSaga(id, widget.movie);
                    switch(isSaved){
                      case true:
                      Dialogs.showSuccesToast('Guardado');
                      break;
                      case false:
                      Dialogs.showErrorToast('No se pudo guardar');
                      break;
                      default:
                      Dialogs.showErrorToast('La peli ya pertenece a la saga');
                      break;
                    }
                    loading.dismiss();
                  },
                ))
          ])),
      MenuItem(
        label: 'Actualizar',
        onClick: (menuItem) {
          Dialogs.showAddMovieDialog(context, movie: widget.movie);
        },
      ),
      MenuItem.separator(),
      MenuItem(
        label: 'Eliminar',
        onClick: (menuItem) {
          Dialogs.showDeleteMovieConfirmation(context, widget.movie);
        },
      )
    ]);
    popUpContextualMenu(_menu!);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            ContextMenuController.removeAny();
            if (Platform.isMacOS) {
              context.read<DataProvider>().selectedMovie = widget.movie;
              if (!MacosWindowScope.of(context).isEndSidebarShown) {
                MacosWindowScope.of(context).toggleEndSidebar();
              }
              return;
            }
            Dialogs.showMovieInfo(context, widget.movie);
          },
          onSecondaryTapUp: (details) {
            _show(details.globalPosition);
          },
          child: AdaptiveCard(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                widget.movie.poster != null
                    ? ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: FastCachedImage(
                          url: widget.movie.poster ?? "",
                          key: ValueKey(widget.movie.poster ?? widget.movie.id),
                          fit: BoxFit.contain,
                          width: double.infinity,
                          errorBuilder: (c, obj, stake) =>
                              Image.asset("assets/poster.jpg"),
                          loadingBuilder: (c, progress) => const SizedBox(
                            width: 200,
                            height: 300,
                            child: Center(
                                child: SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: AdaptiveProgressRing())),
                          ),
                        ))
                    : Image.asset("assets/poster.jpg"),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 4,
                      ),
                      Hero(
                          tag: "${widget.movie.id}-title${widget.extraTag}",
                          child: Text(
                            widget.movie.title,
                            style: const TextStyle(fontSize: 24, height: 1.1),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          )),
                      Text(widget.movie.director,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          )),
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
                  '${widget.movie.launchDate}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          )),
    ]);
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 10),
      child: AdaptiveCard(
        child: Shimmer.fromColors(
            baseColor: Colors.transparent,
            highlightColor: Colors.white.withOpacity(0.1),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                color: Colors.blue,
                height: 300,
                width: 200,
              ),
              const SizedBox(
                height: 8,
              ),
              Container(
                color: Colors.blue,
                height: 24,
                width: 200,
              )
            ])),
      ));
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

class SagaCard extends StatelessWidget {
  final Saga saga;
  const SagaCard(this.saga, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            Platform.isWindows
                ? FluentPageRoute(
                    builder: (c) => AdaptiveWindow(
                        title: const Text('Sibupel'), content: SagaPage(saga)))
                : CupertinoPageRoute(
                    builder: (context) => SagaPage(saga),
                  ));
        // context.push('/saga', extra: saga);
      },
      child: AdaptiveCard(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  for (int i = 0; i < saga.movies.length.clamp(0, 3); i++)
                    Positioned(
                        left: i * 45,
                        top: i * 40,
                        child: Hero(
                          tag: '${saga.movies[i].id}-poster${saga.id}',
                          child: Image.network(
                            saga.movies[i].poster ?? '',
                            width: 300,
                            height: 300,
                            fit: BoxFit.contain,
                            alignment: Alignment.topLeft,
                          ),
                        ))
                ],
              ),
            ),
            Text(
              saga.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
