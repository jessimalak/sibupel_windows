import 'dart:convert';
import 'dart:io';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:macos_ui/macos_ui.dart' as mac;
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sibupel/data/movie.dart';
import 'package:sibupel/data/provider.dart';
import 'package:sibupel/widgets/adaptive/button.dart';
import 'package:sibupel/widgets/adaptive/card.dart';
import 'package:sibupel/widgets/adaptive/dialogs.dart';
import 'package:sibupel/widgets/adaptive/dropdown.dart';
import 'package:sibupel/widgets/adaptive/textfield.dart';
import 'package:sibupel/widgets/selector.dart';

class Dialogs {
  static showAddMovieDialog(BuildContext context, {Movie? movie}) async {
    final Map<String, Saga> sagas = context.read<DataProvider>().sagas;
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
    final content = StatefulBuilder(
        builder: (c, setState) => AdaptiveDialog(
              title: "${movie == null ? "Agregar" : "Editar"} Pelicula",
              constraints: const BoxConstraints(maxWidth: 400),
              content: Stack(children: [
                SingleChildScrollView(
                    child: Form(
                  key: formkey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AdaptiveTextFormField(
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
                      AdaptiveTextFormField(
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
                      AdaptiveTextFormField(
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
                              child: AdaptiveDropdown<int>(
                            value: year,
                            placeholder: "Estreno",
                            items: context
                                .read<DataProvider>()
                                .years
                                .map((e) => AdaptiveDropdownItem<int>(
                                    Text(e.toString()), e))
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
                              child: AdaptiveAutoSuggest(
                                  controller: genderController,
                                  placeholder: "Género",
                                  onSelected: (val) {
                                    setState(() {
                                      genders_.add(val);
                                      // genderController.text = "";
                                    });
                                  },
                                  items: genders
                                      .map((e) => AdaptiveDropdownItem(
                                          Text(e["name"] ?? ''),
                                          e["name"] ?? ""))
                                      .toList()))
                        ],
                      ),
                      Wrap(
                        children: genders_
                            .map((e) => AdaptiveChip(
                                  onPressed: () {
                                    int index = genders_
                                        .indexWhere((element) => element == e);
                                    setState(() {
                                      genders_.removeAt(index);
                                    });
                                  },
                                  child: Text(e),
                                ))
                            .toList(),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const AdaptiveDivider(),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(children: [
                        SizedBox(
                          width: 132,
                          child: AdaptiveTextFormField(
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
                        AdaptiveDropdown(
                          placeholder: "Saga(s)",
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
                              .map((e) => AdaptiveDropdownItem(
                                  Row(
                                    children: [
                                      Visibility(
                                          visible: selectedSagas.contains(e.id),
                                          child: const Icon(
                                              FluentIcons.check_mark)),
                                      Text(e.name)
                                    ],
                                  ),
                                  e.id))
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
                              child: AdaptiveAutoSuggest(
                                  controller: formatController,
                                  // clearButtonEnabled: false,
                                  placeholder: "Formato",
                                  items: formats
                                      .map((e) =>
                                          AdaptiveDropdownItem(Text(e), e))
                                      .toList())),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                              child: AdaptiveTextFormField(
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
                              child: AdaptiveTextFormField(
                            validator: (val) {
                              if (val!.trim().isEmpty) {
                                return "¿En que idioma está?";
                              }
                              return null;
                            },
                            controller: languageController,
                            placeholder: "Idioma",
                          )),
                          AdaptiveCheckbox(
                              content: const Text("Subtitulos"),
                              isChecked: hasSubtitles,
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
                            AdaptiveButton(
                                label: "Buscar poster",
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
                                    constraints:
                                        const BoxConstraints(maxWidth: 150),
                                    child: AdaptiveTextField(
                                      placeholder: "IMDB id / img Url",
                                      controller: idController,
                                      onFieldSubmitted: (s) async {
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
                                : AdaptiveButton(
                                    stateColors: const [
                                        Color(0xFF770606),
                                        Color(0xFFE43737),
                                        Color(0xFFBD1717)
                                      ],
                                    label: "Eliminar poster",
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
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset('assets/poster.jpg'),
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
                        children: const [Center(child: AdaptiveProgressRing())],
                      )
                    : const SizedBox()
              ]),
              onPrimaryButtonPress: () async {
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
              },
              primaryButtonText: movie == null ? "Guardar" : "Actualizar",
            ));
    if (Platform.isMacOS) {
      return await mac.showMacosSheet(
          barrierDismissible: true, context: context, builder: (c) => content);
    }
    return await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (c) {
          return content;
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
          var user = context.read<DataProvider>().user;
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
                                    AdaptiveTextFormField(
                                      controller: mailController,
                                      placeholder: "Correo electrónico",
                                    ),
                                    AdaptiveTextFormField(
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
    final content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 225, maxWidth: 300),
            child: Hero(
                tag: "${movie.id}-poster",
                child: movie.poster != null
                    ? Image.network(
                        movie.poster ?? "",
                        key: ValueKey(movie.id),
                        errorBuilder: (c, obj, stake) =>
                            Image.asset("assets/poster.jpg"),
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
                  width: Platform.isMacOS ? null : 220,
                  child: RichText(
                      text: TextSpan(children: [
                    const TextSpan(
                        text: "Director(es): ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    TextSpan(
                        text: movie.director,
                        style: const TextStyle(fontSize: 16))
                  ]))),
              RichText(
                  text: TextSpan(children: [
                const TextSpan(
                    text: "Lanzamiento: ",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextSpan(
                    text: movie.launchDate.toString(),
                    style: const TextStyle(fontSize: 16)),
              ])),
              RichText(
                  text: TextSpan(children: [
                const TextSpan(
                    text: "Duración: ",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextSpan(
                    text: "${movie.duration} min",
                    style: const TextStyle(fontSize: 16)),
              ])),
              Wrap(
                  children: movie.genders
                      .map((gender) => Padding(
                          padding: const EdgeInsets.only(right: 5, top: 5),
                          child: AdaptiveChip(
                            child: Text(gender),
                          )))
                      .toList()),
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: AdaptiveDivider(
                    size: 220,
                  )),
              RichText(
                  text: TextSpan(children: [
                const TextSpan(
                    text: "Carpeta: \n",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextSpan(
                    text: movie.folder, style: const TextStyle(fontSize: 16)),
              ])),
              RichText(
                  text: TextSpan(children: [
                const TextSpan(
                    text: "Formato: ",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextSpan(
                    text: movie.format, style: const TextStyle(fontSize: 16)),
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
                        const TextSpan(
                            text: "Idioma: \n",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        TextSpan(
                            text: movie.language,
                            style: const TextStyle(fontSize: 16)),
                      ]))),
                      AdaptiveCheckbox(
                        isChecked: movie.subtitles,
                        onChanged: (v) {},
                        content: const Text("Subtitulos"),
                      ),
                    ],
                  ))
            ],
          )
        ]);

    final windowsBuilder = PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        fullscreenDialog: true,
        barrierLabel: "label",
        barrierColor: Colors.black.withOpacity(0.5),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: animation,
              child: child,
            ),
        pageBuilder: (c, _, __) => ContentDialog(
              constraints: const BoxConstraints(minWidth: 450, maxWidth: 600),
              title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(tag: "${movie.id}-title", child: Text(movie.title)),
                    Text(
                      movie.originalTitle,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w100),
                    )
                  ]),
              content: content,
              actions: [
                Button(
                    child: const Text("Cerrar"),
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ],
            ));

    final macosBuilder = CupertinoPageRoute(
        builder: (c) => mac.MacosScaffold(
              toolBar: mac.ToolBar(
                // padding: const EdgeInsets.fromLTRB(96, 4, 8, 4) ,
                title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                          tag: "${movie.id}-title",
                          child: Text(
                            movie.title,
                            style:
                                mac.MacosTheme.of(context).typography.headline,
                          )),
                      Text(
                        movie.originalTitle,
                        style: mac.MacosTheme.of(context)
                            .typography
                            .subheadline
                            .copyWith(color: mac.MacosColors.systemGrayColor),
                      ),
                    ]),
                titleWidth: 400,
              ),
              children: [
                mac.ContentArea(
                  builder: (context, scrollController) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: content,
                  ),
                )
              ],
            ));
    Navigator.push(context, Platform.isMacOS ? macosBuilder : windowsBuilder);
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
                                          child: const Text("Cancelar"),
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
                    constraints:
                        const BoxConstraints(maxWidth: 368, maxHeight: 600),
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
                                    bool isSaved = await context
                                        .read<DataProvider>()
                                        .updateMovie(movie);
                                    context
                                        .read<DataProvider>()
                                        .addMovieToSaga(id, movie);
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
                                leading: movie.sagas.contains(id)
                                    ? const Icon(FluentIcons.check_mark)
                                    : null,
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
                                var result = await showAddSagaDialog(context);
                                if (result != null) {
                                  await context
                                      .read<DataProvider>()
                                      .createSaga(result, movie);
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
    if (Platform.isMacOS) {
      return mac.showMacosAlertDialog(
        context: context,
        builder: (c) => mac.MacosAlertDialog(
          appIcon: const mac.MacosIcon(CupertinoIcons.delete),
          primaryButton: mac.PushButton(
            onPressed: () async {
              await context.read<DataProvider>().deleteMovie(movie.id);
              Navigator.pop(context);
            },
            buttonSize: mac.ButtonSize.large,
            child: const Text("Eliminar"),
          ),
          secondaryButton: mac.PushButton(
            buttonSize: mac.ButtonSize.large,
            isSecondary: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("No"),
          ),
          message: Text(
              "Estás a punto de eliminar ${movie.title} del ${movie.launchDate}"),
          title: Text("¿Quieres eliminar ${movie.title}?"),
        ),
      );
    }
    return showDialog(
        context: context,
        builder: (c) => ContentDialog(
              title: Text("¿Quieres eliminar ${movie.title}?"),
              content: Text(
                  "Estás a punto de eliminar ${movie.title} del ${movie.launchDate}"),
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

  static Future<String?> showAddSagaDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    if (Platform.isMacOS) {
      return await mac.showMacosAlertDialog(
        barrierDismissible: true,
          context: context,
          builder: (context) => mac.MacosAlertDialog(
            appIcon: const mac.MacosIcon(CupertinoIcons.collections_solid),
                title: const Text('Agregar Saga'),
                message: mac.MacosTextField(placeholder: 'Nombre',controller: controller,),
                primaryButton: mac.PushButton(
                    onPressed: () {
                      if(controller.text.trim().isEmpty)return;
                      Navigator.pop(context, controller.text);
                    },
                    buttonSize: mac.ButtonSize.large,
                    child: const Text('Guardar'),
                  ),
                  secondaryButton: mac.PushButton(
                    isSecondary: true,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    buttonSize: mac.ButtonSize.large,
                    child: const Text('Cancelar'),
                  ),
              ));
    }
    return await showDialog<String?>(
        context: context,
        builder: (c) {
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
    if (Platform.isMacOS) {
      mac.showMacosSheet(
          context: _context,
          builder: (context) =>
              const mac.MacosSheet(child: mac.ProgressCircle()));
    } else {
      showDialog(
          context: _context,
          builder: (context) => ContentDialog(
                key: _loadingKey,
                title: Text(message),
                content: const ProgressBar(),
              ));
    }
  }

  void dismiss() {
    if (!isShowing) return;
    Navigator.pop(_loadingKey.currentContext ?? _context);
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

class SidebarMovieInfo extends StatelessWidget {
  const SidebarMovieInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final movie = context.watch<DataProvider>().selectedMovie;
    final typography = mac.MacosTheme.of(context).typography;
    return movie == null
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.title,
                style: mac.MacosTheme.of(context).typography.title1,
              ),
              Text(movie.originalTitle,
                  style:
                      mac.MacosTheme.of(context).typography.headline.copyWith(
                            color: mac.MacosColors.systemGrayColor,
                          )),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: FastCachedImage(
                    url: movie.poster ?? '',
                    key: ValueKey(movie.id),
                    errorBuilder: (c, obj, stake) =>
                        Image.asset("assets/poster.jpg"),
                    loadingBuilder: (c, progress) => const SizedBox(
                        width: 200,
                        height: 300,
                        child: Center(
                            child: SizedBox(
                                width: 80,
                                height: 80,
                                child: AdaptiveProgressRing())))),
              ),
              Text(
                'Director(es)',
                style: typography.title2,
              ),
              Text(movie.director, style: typography.headline),
              const SizedBox(
                height: 4,
              ),
              Text(
                'Generos',
                style: typography.title2,
              ),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: movie.genders
                    .map((e) => AdaptiveChip(child: Text(e)))
                    .toList(),
              ),
              const AdaptiveDivider(),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Carpeta',
                        style: typography.title2,
                      ),
                      Text(movie.folder, style: typography.headline),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Formato',
                        style: typography.title2,
                      ),
                      Text(movie.format, style: typography.headline),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duracion',
                        style: typography.title2,
                      ),
                      Text("${movie.duration}'", style: typography.headline),
                    ],
                  ),
                  AdaptiveCheckbox(
                      isChecked: movie.subtitles,
                      onChanged: (_) {},
                      content: const Text('Subtitulos'))
                ],
              )
            ],
          );
  }
}
