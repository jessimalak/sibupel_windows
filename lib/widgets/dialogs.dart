import 'dart:convert';

import 'package:firedart/auth/user_gateway.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sibupel/data/movie.dart';
import 'package:sibupel/data/provider.dart';

class Dialogs {
  static showAddMovieDialog(BuildContext context, {Movie? movie}) async {
    final Map<String, Saga> sagas = context.read<DataProvider>().sagas;
    await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (c) {
          bool isLoading = false;
          TextEditingController titleController = TextEditingController();
          TextEditingController originalTitleController = TextEditingController();
          TextEditingController directorController = TextEditingController();
          TextEditingController folderController = TextEditingController();
          TextEditingController durationController = TextEditingController();
          TextEditingController languageController = TextEditingController();
          TextEditingController formatController = TextEditingController();
          TextEditingController genderController = TextEditingController();
          TextEditingController idController = TextEditingController();
          final formkey = GlobalKey<FormState>();
          List<dynamic> genders_ = movie?.genders ?? [];
          bool hasSubtitles = movie?.subtitles ?? false;
          int? year = movie?.launchDate;
          String? poster = movie?.poster;
          List<String> selectedSagas = [];
          if (movie != null) {
            titleController.text = movie.title;
            originalTitleController.text = movie.originalTitle;
            directorController.text = movie.director;
            folderController.text = movie.folder;
            durationController.text = movie.duration;
            languageController.text = movie.language;
            formatController.text = movie.format;
          }

          return StatefulBuilder(
              builder: (c, setState) => ContentDialog(
                    title: Text("${movie == null ? "Agregar" : "Editar"} Pelicula"),
                    constraints: const BoxConstraints(maxWidth: 400),
                    content: Stack(children: [
                      SingleChildScrollView(
                          child: Form(
                        key: formkey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormBox(
                              validator: (val) {
                                if (val!.trim().isEmpty) {
                                  return "¿y el titulo en español?";
                                }
                                return null;
                              },
                              controller: titleController,
                              placeholder: "Título",
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            TextFormBox(
                              validator: (val) {
                                if (val!.trim().isEmpty) {
                                  return "¿Título original?";
                                }
                                return null;
                              },
                              controller: originalTitleController,
                              placeholder: "Título Original",
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            TextFormBox(
                              validator: (val) {
                                if (val!.trim().isEmpty) {
                                  return "¿Quien la dirigió?";
                                }
                                return null;
                              },
                              controller: directorController,
                              placeholder: "Director(es)",
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: ComboBox<int>(
                                  value: year,
                                  placeholder: const Text("Estreno"),
                                  items: context
                                      .read<DataProvider>()
                                      .years
                                      .map((e) => ComboBoxItem<int>(value: e, child: Text(e.toString())))
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      year = val;
                                    });
                                  },
                                )),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                    child: AutoSuggestBox(
                                        controller: genderController,
                                        placeholder: "Género",
                                        onSelected: (val) {
                                          setState(() {
                                            genders_.add(val.value);
                                            // genderController.text = "";
                                          });
                                        },
                                        items:
                                            genders.map((e) => AutoSuggestBoxItem(value: e["name"], label: e["name"] ?? "")).toList()))
                              ],
                            ),
                            Wrap(
                              children: genders_
                                  .map((e) => Chip(
                                        onPressed: () {
                                          int index = genders_.indexWhere((element) => element == e);
                                          setState(() {
                                            genders_.removeAt(index);
                                          });
                                        },
                                        text: Text(e),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Divider(),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(children: [
                              SizedBox(
                                width: 132,
                                child: TextFormBox(
                                  validator: (val) {
                                    if (val!.trim().isEmpty) {
                                      return "¿En que carpeta está guardada?";
                                    }
                                    return null;
                                  },
                                  controller: folderController,
                                  placeholder: "Carpeta",
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              ComboBox(
                                placeholder: const Text("Saga(s)"),
                                onChanged: (String? value) {
                                  if (value == null) return;
                                  if (selectedSagas.contains(value)) {
                                    setState(
                                      () {
                                        selectedSagas.remove(value);
                                      },
                                    );
                                  } else {
                                    setState(() {
                                      selectedSagas.add(value);
                                    });
                                  }
                                },
                                items: sagas.values
                                    .map((e) => ComboBoxItem(
                                        value: e.id,
                                        child: Row(
                                          children: [
                                            Visibility(
                                                visible: selectedSagas.contains(e.id), child: const Icon(FluentIcons.check_mark)),
                                            Text(e.name)
                                          ],
                                        )))
                                    .toList(),
                              )
                            ]),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: AutoSuggestBox(
                                        controller: formatController,
                                        clearButtonEnabled: false,
                                        placeholder: "Formato",
                                        items: formats.map((e) => AutoSuggestBoxItem(value: e, label: e)).toList())),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                    child: TextFormBox(
                                  validator: (val) {
                                    if (val!.trim().isEmpty) {
                                      return "¿Cuanto dura?";
                                    }
                                    return null;
                                  },
                                  controller: durationController,
                                  placeholder: "Duración",
                                ))
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: TextFormBox(
                                  validator: (val) {
                                    if (val!.trim().isEmpty) {
                                      return "¿En que idioma está?";
                                    }
                                    return null;
                                  },
                                  controller: languageController,
                                  placeholder: "Idioma",
                                )),
                                Checkbox(
                                    content: const Text("Subtitulos"),
                                    checked: hasSubtitles,
                                    onChanged: (v) {
                                      setState(() {
                                        hasSubtitles = v ?? false;
                                      });
                                    })
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Column(
                              children: [
                                Row(children: [
                                  FilledButton(
                                      child: const Text("Buscar poster"),
                                      onPressed: () async {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        String? poster_;
                                        String id = idController.text.trim();
                                        if (id.isEmpty) {
                                          poster_ = await searchPosterByTitle(originalTitleController.text, year ?? 0);
                                        } else {
                                          if (id.contains("https://")) {
                                            poster_ = id;
                                          } else {
                                            poster_ = await searchPosterById(idController.text.trim());
                                          }
                                        }

                                        setState(() {
                                          isLoading = false;
                                          poster = poster_;
                                        });
                                      }),
                                  poster == null
                                      ? ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 150),
                                          child: TextBox(
                                            placeholder: "IMDB id / img Url",
                                            controller: idController,
                                            onEditingComplete: () async {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              String id = idController.text.trim();
                                              String? poster_;
                                              if (id.contains("https://")) {
                                                poster_ = id;
                                              } else {
                                                poster_ = await searchPosterById(id);
                                              }
                                              setState(() {
                                                isLoading = false;
                                                poster = poster_;
                                              });
                                            },
                                          ))
                                      : FilledButton(
                                          style: ButtonStyle(backgroundColor: ButtonState.resolveWith((states) {
                                            if (states.contains(ButtonStates.pressing)) {
                                              return const Color(0xFF770606);
                                            }
                                            if (states.contains(ButtonStates.hovering)) {
                                              return const Color(0xFFE43737);
                                            }
                                            return const Color(0xFFBD1717);
                                          })),
                                          child: const Text("Eliminar poster"),
                                          onPressed: () {
                                            setState(() {
                                              poster = null;
                                            });
                                          })
                                ]),
                                poster == null
                                    ? const SizedBox()
                                    : Image.network(
                                        poster ?? "",
                                      )
                              ],
                            )
                          ],
                        ),
                      )),
                      isLoading
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [Center(child: ProgressRing())],
                            )
                          : const SizedBox()
                    ]),
                    actions: [
                      FilledButton(
                          child: Text(movie == null ? "Guardar" : "Actualizar"),
                          onPressed: () async {
                            if (formkey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              if (genderController.text.trim().isNotEmpty) {
                                for (String gender in genderController.text.split(",")) {
                                  if (!genders_.contains(gender.trim())) {
                                    genders_.add(gender);
                                  }
                                }
                              }
                              Movie movie_ = Movie(
                                  titleController.text,
                                  originalTitleController.text,
                                  directorController.text,
                                  genders_,
                                  year ?? 0,
                                  durationController.text,
                                  hasSubtitles,
                                  folderController.text,
                                  formatController.text,
                                  languageController.text,
                                  poster,
                                  selectedSagas,
                                  movie?.id ?? "");
                              bool isSaved = movie != null
                                  ? await context.read<DataProvider>().updateMovie(movie_)
                                  : await context.read<DataProvider>().saveMovie(movie_);
                              if (isSaved) {
                                Navigator.pop(context);
                              } else {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            }
                          }),
                    ],
                  ));
        });
  }

  static showSettingsDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (c) {
          bool isLoading = false;
          TextEditingController mailController = TextEditingController();
          TextEditingController passwordController = TextEditingController();
          GlobalKey formKey = GlobalKey<FormState>();
          User? user = context.read<DataProvider>().user;
          return StatefulBuilder(
              builder: (c, setState_) => ContentDialog(
                    title: const Text("Ajustes"),
                    content: user == null
                        ? isLoading
                            ? const ProgressRing()
                            : Form(
                                key: formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormBox(
                                      controller: mailController,
                                      placeholder: "Correo electrónico",
                                    ),
                                    TextFormBox(
                                      controller: passwordController,
                                      placeholder: "Contraseña",
                                      obscureText: true,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        FilledButton(
                                            child: const Text("Iniciar Sesión"),
                                            onPressed: () async {
                                              setState_(() {
                                                isLoading = true;
                                              });
                                              var user_ = await context
                                                  .read<DataProvider>()
                                                  .login(mailController.text, passwordController.text, false);
                                              setState_(() {
                                                isLoading = false;
                                              });
                                              if (user_ != null) {
                                                Navigator.pop(context);
                                              }
                                            })
                                      ],
                                    )
                                  ],
                                ),
                              )
                        : Column(mainAxisSize: MainAxisSize.min, children: [
                            Text(user.email ?? ""),
                            Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: context.read<DataProvider>().movies.length.toString(),
                                          style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const TextSpan(text: " películas")
                                    ])),
                                    RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: context.read<DataProvider>().waitList.length.toString(),
                                          style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const TextSpan(text: " en espera")
                                    ]))
                                  ],
                                )),
                            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                              FilledButton(
                                  child: const Text("Cerrar sesión"),
                                  onPressed: () async {
                                    await context.read<DataProvider>().signOut();
                                    Navigator.pop(context);
                                  })
                            ])
                          ]),
                    actions: [
                      Button(
                        child: const Text("Cerrar"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ));
        });
  }

  static showMovieInfo(BuildContext context, Movie movie) {
    Navigator.push(
        context,
        PageRouteBuilder(
            opaque: false,
            barrierDismissible: true,
            fullscreenDialog: true,
            barrierLabel: "label",
            barrierColor: Colors.black.withOpacity(0.5),
            transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
            pageBuilder: (c, _, __) => ContentDialog(
                  constraints: const BoxConstraints(minWidth: 450, maxWidth: 600),
                  title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Hero(tag: "${movie.id}-title", child: Text(movie.title)),
                    Text(
                      movie.originalTitle,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w100),
                    )
                  ]),
                  content: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 225, maxWidth: 300),
                      child: Hero(
                          tag: "${movie.id}-poster",
                          child: movie.poster != null
                              ? Image.network(
                                  movie.poster ?? "",
                                  key: ValueKey(movie.id),
                                  errorBuilder: (c, obj, stake) => Image.asset("assets/poster.jpg"),
                                )
                              : Image.asset("assets/poster.jpg")),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                            width: 220,
                            child: RichText(
                                text: TextSpan(children: [
                              const TextSpan(text: "Director(es): ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              TextSpan(text: movie.director, style: const TextStyle(fontSize: 16))
                            ]))),
                        RichText(
                            text: TextSpan(children: [
                          const TextSpan(text: "Lanzamiento: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          TextSpan(text: movie.launchDate.toString(), style: const TextStyle(fontSize: 16)),
                        ])),
                        RichText(
                            text: TextSpan(children: [
                          const TextSpan(text: "Duración: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          TextSpan(text: "${movie.duration} min", style: const TextStyle(fontSize: 16)),
                        ])),
                        Wrap(
                            children: movie.genders
                                .map((gender) => Padding(
                                    padding: const EdgeInsets.only(right: 5, top: 5),
                                    child: Chip(
                                      text: Text(gender),
                                    )))
                                .toList()),
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(
                              size: 220,
                            )),
                        RichText(
                            text: TextSpan(children: [
                          const TextSpan(text: "Carpeta: \n", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          TextSpan(text: movie.folder, style: const TextStyle(fontSize: 16)),
                        ])),
                        RichText(
                            text: TextSpan(children: [
                          const TextSpan(text: "Formato: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          TextSpan(text: movie.format, style: const TextStyle(fontSize: 16)),
                        ])),
                        SizedBox(
                            width: 220,
                            child: Row(
                              // mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: RichText(
                                        text: TextSpan(children: [
                                  const TextSpan(text: "Idioma: \n", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  TextSpan(text: movie.language, style: const TextStyle(fontSize: 16)),
                                ]))),
                                Checkbox(
                                  checked: movie.subtitles,
                                  onChanged: (v) {},
                                  content: const Text("Subtitulos"),
                                ),
                              ],
                            ))
                      ],
                    )
                  ]),
                  actions: [
                    Button(
                        child: const Text("Cerrar"),
                        onPressed: () {
                          Navigator.pop(context);
                        })
                  ],
                )));
  }

  static showWaitList(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (c) {
          var movies = context.watch<DataProvider>().waitList;
          String isLoadingId = "";
          return StatefulBuilder(
              builder: (context, setState) => ContentDialog(
                    title: Text("Lista de espera (${movies.length})"),
                    constraints: const BoxConstraints(maxWidth: 368, maxHeight: 600),
                    content: movies.isEmpty
                        ? const Text("Sin peliculas en lista de espera")
                        : ListView.builder(
                            itemCount: movies.length,
                            itemBuilder: (c, i) => ListTile(
                                  title: Text(
                                    movies[i].name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: isLoadingId == movies[i].id
                                      ? const ProgressRing()
                                      : IconButton(
                                          icon: const Icon(FluentIcons.delete),
                                          onPressed: () async {
                                            String id = movies[i].id;
                                            setState(() {
                                              isLoadingId = id;
                                            });
                                            await context.read<DataProvider>().deleteWaitMovie(id);
                                            setState(() {
                                              isLoadingId = "";
                                            });
                                          },
                                        ),
                                )),
                    actions: [
                      FilledButton(
                          child: const Text("Agregar"),
                          onPressed: () async {
                            var result = await showDialog<String?>(
                                context: context,
                                builder: (c) {
                                  TextEditingController controller = TextEditingController();
                                  return ContentDialog(
                                    title: const Text("Agregar pelicula"),
                                    content: TextBox(
                                      placeholder: "Título",
                                      controller: controller,
                                    ),
                                    actions: [
                                      FilledButton(
                                          child: const Text("Guardar"),
                                          onPressed: () {
                                            Navigator.pop(context, controller.text);
                                          }),
                                      Button(
                                          child: const Text("Cancelar"),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          })
                                    ],
                                  );
                                });
                            if (result != null) {
                              await context.read<DataProvider>().saveMovieToWait(result);
                              setState(() {});
                            }
                          }),
                      Button(
                          child: const Text("Cerrar"),
                          onPressed: () {
                            Navigator.pop(context);
                          })
                    ],
                  ));
        });
  }

  static showSagasDialog(BuildContext context, Movie movie) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (c) {
          var sagas = context.watch<DataProvider>().sagas;
          bool isLoading = false;
          return StatefulBuilder(
              builder: (context, setState) => ContentDialog(
                    title: const Text("Sagas"),
                    constraints: const BoxConstraints(maxWidth: 368, maxHeight: 600),
                    content: sagas.isEmpty
                        ? const Text("Sin sagas creadas")
                        : ListView.builder(
                            itemCount: sagas.length,
                            itemBuilder: (c, i) {
                              var id = sagas.keys.toList()[i];
                              return ListTile(
                                onPressed: () async {
                                  setState(
                                    () {
                                      isLoading = true;
                                    },
                                  );
                                  if (!movie.sagas.contains(id)) {
                                    movie.sagas.add(id);
                                    bool isSaved = await context.read<DataProvider>().updateMovie(movie);
                                    context.read<DataProvider>().addMovieToSaga(id, movie);
                                    if (isSaved) {
                                      Navigator.pop(context);
                                    } else {
                                      setState(
                                        () {
                                          isLoading = false;
                                        },
                                      );
                                      showToast("No se ha guardado");
                                    }
                                  } else {
                                    setState(
                                      () {
                                        isLoading = false;
                                      },
                                    );
                                    showToast("Ya está en la saga");
                                  }
                                },
                                leading: movie.sagas.contains(id) ? const Icon(FluentIcons.check_mark) : null,
                                title: Text(
                                  sagas[id]?.name ?? '',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                    actions: [
                      isLoading
                          ? const ProgressBar()
                          : FilledButton(
                              child: const Text("Agregar"),
                              onPressed: () async {
                                var result = await showDialog<String?>(
                                    context: context,
                                    builder: (c) {
                                      TextEditingController controller = TextEditingController();
                                      return ContentDialog(
                                        title: const Text("Agregar Saga"),
                                        content: TextBox(
                                          placeholder: "Nombre",
                                          controller: controller,
                                        ),
                                        actions: [
                                          FilledButton(
                                              child: const Text("Guardar"),
                                              onPressed: () {
                                                Navigator.pop(context, controller.text);
                                              }),
                                          Button(
                                              child: const Text("Cancelar"),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              })
                                        ],
                                      );
                                    });
                                if (result != null) {
                                  await context.read<DataProvider>().createSaga(result, movie);
                                  setState(() {});
                                }
                              }),
                      Button(
                          child: const Text("Cerrar"),
                          onPressed: () {
                            Navigator.pop(context);
                          })
                    ],
                  ));
        });
  }

  static showDeleteMovieConfirmation(BuildContext context, Movie movie) {
    showDialog(
        context: context,
        builder: (c) => ContentDialog(
              title: Text("¿Quieres eliminar ${movie.title}?"),
              content: Text("Estás a punto de eliminar ${movie.title} del ${movie.launchDate}"),
              actions: [
                FilledButton(
                    child: const Text("Eliminar"),
                    onPressed: () async {
                      await context.read<DataProvider>().deleteMovie(movie.id);
                      Navigator.pop(context);
                    }),
                Button(
                    child: const Text("No"),
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ],
            ));
  }
}

class LoadingDialog {
  final GlobalKey _loadingKey = GlobalKey();
  final BuildContext _context;
  bool isShowing = false;

  LoadingDialog(this._context);

  void show(String message) {
    if (isShowing) return;
    isShowing = true;
    showDialog(
        context: _context,
        builder: (context) => ContentDialog(
              key: _loadingKey,
              title: Text(message),
              content: const ProgressBar(),
            ));
  }

  void dismiss() {
    if (!isShowing) return;
    Navigator.pop(_loadingKey.currentContext ?? _context);
  }
}

Future<String?> searchPosterById(String id) async {
  String? poster_;
  var response = await get(Uri.parse("http://www.omdbapi.com/?i=$id&apikey=${dotenv.env["POSTERKEY"] ?? ""}"));
  print(response.body);
  if (response.statusCode == 200) {
    var body = jsonDecode(response.body);
    if (body["Error"] == null) {
      poster_ = body["Poster"];
    }
  }
  return poster_;
}

Future<String?> searchPosterByTitle(String title, int launchDate) async {
  String title_ = title.trim().replaceAll(" ", "+").toLowerCase();
  String? poster_;
  var response = await get(Uri.parse(
      "http://www.omdbapi.com/?i=${dotenv.env["POSTERi"] ?? ""}&apikey=${dotenv.env["POSTERKEY"] ?? ""}&t=$title_&y=$launchDate"));
  print(response.body);
  if (response.statusCode == 200) {
    var body = jsonDecode(response.body);
    if (body["Error"] == null) {
      poster_ = body["Poster"];
    }
  }
  return poster_;
}
