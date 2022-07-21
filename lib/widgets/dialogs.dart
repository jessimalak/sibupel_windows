import 'dart:convert';

import 'package:firedart/auth/user_gateway.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:sibupel/data/movie.dart';
import 'package:sibupel/data/provider.dart';

class Dialogs {
  static showAddMovieDialog(BuildContext context, {Movie? movie}) async {
    await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (c) {
          bool isLoading = false;
          TextEditingController titleController = TextEditingController();
          TextEditingController originalTitleController =
              TextEditingController();
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
                    title: Text(
                        "${movie == null ? "Agregar" : "Editar"} Pelicula"),
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
                              },
                              controller: titleController,
                              placeholder: "Título",
                            ),
                            TextFormBox(
                              validator: (val) {
                                if (val!.trim().isEmpty) {
                                  return "¿Título original?";
                                }
                              },
                              controller: originalTitleController,
                              placeholder: "Título Original",
                            ),
                            TextFormBox(
                              validator: (val) {
                                if (val!.trim().isEmpty) {
                                  return "¿Quien la dirigió?";
                                }
                              },
                              controller: directorController,
                              placeholder: "Director(es)",
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: Combobox<int>(
                                  value: year,
                                  placeholder: const Text("Estreno"),
                                  items: context
                                      .read<DataProvider>()
                                      .years
                                      .map((e) => ComboboxItem<int>(
                                          value: e, child: Text(e.toString())))
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      year = val;
                                    });
                                  },
                                )),
                                Expanded(
                                    child: AutoSuggestBox(
                                        controller: genderController,
                                        placeholder: "Género",
                                        onSelected: (val) {
                                          setState(() {
                                            genders_.add(val);
                                            genderController.text = "";
                                          });
                                        },
                                        items: genders
                                            .map((e) => e["name"] ?? "")
                                            .toList()))
                              ],
                            ),
                            Wrap(
                              children: genders_
                                  .map((e) => Chip(
                                        onPressed: () {},
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
                            TextFormBox(
                              validator: (val) {
                                if (val!.trim().isEmpty) {
                                  return "¿En que carpeta está guardada?";
                                }
                              },
                              controller: folderController,
                              placeholder: "Carpeta",
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: AutoSuggestBox(
                                        controller: formatController,
                                        clearButtonEnabled: false,
                                        placeholder: "Formato",
                                        items: formats.map((e) => e).toList())),
                                const SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                    child: TextFormBox(
                                  validator: (val) {
                                    if (val!.trim().isEmpty) {
                                      return "¿Cuanto dura?";
                                    }
                                  },
                                  controller: durationController,
                                  placeholder: "Duración",
                                ))
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: TextFormBox(
                                  validator: (val) {
                                    if (val!.trim().isEmpty) {
                                      return "¿En que idioma está?";
                                    }
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
                                          poster_ = await searchPosterByTitle(
                                              originalTitleController.text,
                                              year ?? 0);
                                        } else {
                                          if (id.contains("https://")) {
                                            poster_ = id;
                                          } else {
                                            poster_ = await searchPosterById(
                                                idController.text.trim());
                                          }
                                        }

                                        setState(() {
                                          isLoading = false;
                                          poster = poster_;
                                        });
                                      }),
                                  poster == null
                                      ? ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              maxWidth: 150),
                                          child: TextBox(
                                            placeholder: "IMDB id / img Url",
                                            controller: idController,
                                            onEditingComplete: () async {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              String id =
                                                  idController.text.trim();
                                              String? poster_;
                                              if (id.contains("https://")) {
                                                poster_ = id;
                                              } else {
                                                poster_ =
                                                    await searchPosterById(id);
                                              }
                                              setState(() {
                                                isLoading = false;
                                                poster = poster_;
                                              });
                                            },
                                          ))
                                      : FilledButton(
                                          style: ButtonStyle(backgroundColor:
                                              ButtonState.resolveWith((states) {
                                            if (states.contains(
                                                ButtonStates.pressing)) {
                                              return const Color(0xFF770606);
                                            }
                                            if (states.contains(
                                                ButtonStates.hovering)) {
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
                                for (String gender
                                    in genderController.text.split(",")) {
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
                                  movie?.id ?? "");
                              bool isSaved = movie != null
                                  ? await context
                                      .read<DataProvider>()
                                      .updateMovie(movie_)
                                  : await context
                                      .read<DataProvider>()
                                      .saveMovie(movie_);
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
                                                  .login(
                                                      mailController.text,
                                                      passwordController.text,
                                                      false);
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
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: context
                                              .read<DataProvider>()
                                              .movies
                                              .length
                                              .toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const TextSpan(text: " películas")
                                    ])),
                                    RichText(
                                        text: TextSpan(children: [
                                      TextSpan(
                                          text: context
                                              .read<DataProvider>()
                                              .waitList
                                              .length
                                              .toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      const TextSpan(text: " en espera")
                                    ]))
                                  ],
                                )),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  FilledButton(
                                      child: const Text("Cerrar sesión"),
                                      onPressed: () async {
                                        await context
                                            .read<DataProvider>()
                                            .signOut();
                                        Navigator.pop(context);
                                      })
                                ])
                          ]),
                    actions: [
                      Button(
                        child: Text("Cerrar"),
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
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
            pageBuilder: (c, _, __) => Container(
                color: Colors.black.withOpacity(0.5),
                child: ContentDialog(
                  constraints:
                      const BoxConstraints(minWidth: 450, maxWidth: 600),
                  title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                            tag: "${movie.id}-title", child: Text(movie.title)),
                        Text(
                          movie.originalTitle,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w100),
                        )
                      ]),
                  content: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Hero(
                            tag: "${movie.id}-poster",
                            child: movie.poster != null
                                ? Image.network(movie.poster ?? "")
                                : Image.asset("assets/poster.jpg")),
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
                                  const TextSpan(
                                      text: "Director(es): ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  TextSpan(
                                      text: movie.director,
                                      style: const TextStyle(fontSize: 16))
                                ]))),
                            RichText(
                                text: TextSpan(children: [
                              const TextSpan(
                                  text: "Lanzamiento: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              TextSpan(
                                  text: movie.launchDate.toString(),
                                  style: const TextStyle(fontSize: 16)),
                            ])),
                            RichText(
                                text: TextSpan(children: [
                              const TextSpan(
                                  text: "Duración: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              TextSpan(
                                  text: "${movie.duration} min",
                                  style: const TextStyle(fontSize: 16)),
                            ])),
                            Wrap(
                                children: movie.genders
                                    .map((gender) => Padding(
                                        padding: const EdgeInsets.only(
                                            right: 5, top: 5),
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
                              const TextSpan(
                                  text: "Carpeta: \n",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              TextSpan(
                                  text: movie.folder,
                                  style: const TextStyle(fontSize: 16)),
                            ])),
                            RichText(
                                text: TextSpan(children: [
                              const TextSpan(
                                  text: "Formato: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              TextSpan(
                                  text: movie.format,
                                  style: const TextStyle(fontSize: 16)),
                            ])),
                            SizedBox(
                                width: 220,
                                child: Row(
                                  // mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: RichText(
                                            text: TextSpan(children: [
                                      const TextSpan(
                                          text: "Idioma: \n",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      TextSpan(
                                          text: movie.language,
                                          style: const TextStyle(fontSize: 16)),
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
                ))));
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
                    constraints:
                        const BoxConstraints(maxWidth: 368, maxHeight: 600),
                    content: movies.isEmpty
                        ? const Text("Sin peliculas en lista de espera")
                        : ListView.builder(
                            itemCount: movies.length,
                            itemBuilder: (c, i) => ListTile(
                                  title: Text(movies[i].name),
                                  trailing: isLoadingId == movies[i].id
                                      ? const ProgressRing()
                                      : IconButton(
                                          icon: const Icon(FluentIcons.delete),
                                          onPressed: () async {
                                            String id = movies[i].id;
                                            setState(() {
                                              isLoadingId = id;
                                            });
                                            await context
                                                .read<DataProvider>()
                                                .deleteWaitMovie(id);
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
                                  TextEditingController controller =
                                      TextEditingController();
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
                                            Navigator.pop(
                                                context, controller.text);
                                          }),
                                      Button(
                                          child: Text("Cancelar"),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          })
                                    ],
                                  );
                                });
                            if (result != null) {
                              await context
                                  .read<DataProvider>()
                                  .saveMovieToWait(result);
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
              content: Text(
                  "Estás a punto de eliminar ${movie.title} del ${movie.launchDate}"),
              actions: [
                FilledButton(
                    child: Text("Eliminar"),
                    onPressed: () async {
                      await context.read<DataProvider>().deleteMovie(movie.id);
                      Navigator.pop(context);
                    }),
                Button(
                    child: Text("No"),
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ],
            ));
  }
}

Future<String?> searchPosterById(String id) async {
  String? poster_;
  var response = await get(Uri.parse(
      "http://www.omdbapi.com/?i=$id&apikey=${dotenv.env["POSTERKEY"] ?? ""}"));
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
