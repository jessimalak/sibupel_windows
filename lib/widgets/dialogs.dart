import 'dart:convert';

import 'package:firedart/auth/user_gateway.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:sibupel/data/movie.dart';
import 'package:sibupel/data/provider.dart';

class Dialogs {
  static showAddMovieDialog(BuildContext context) async {
    await showDialog(
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
          final formkey = GlobalKey<FormState>();
          List<String> genders_ = [];
          bool hasSubtitles = false;
          int? year;
          String? poster;
          return StatefulBuilder(
              builder: (c, setState) => ContentDialog(
                    title: const Text("Agregar Pelicula"),
                    constraints: const BoxConstraints(maxWidth: 400),
                    content: Stack(children: [
                      SingleChildScrollView(child:Form(
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
                                FilledButton(
                                    child: Text("Buscar poster"),
                                    onPressed: () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      String title = originalTitleController.text
                                          .trim()
                                          .replaceAll(" ", "+").toLowerCase();
                                      String? poster_;
                                      var response = await get(Uri.parse(
                                          "http://www.omdbapi.com/?i=${dotenv.env["POSTERi"] ?? ""}&apikey=${dotenv.env["POSTERKEY"] ?? ""}&t=$title&y=${year ?? 0}"));
                                      print(response.body);
                                      if (response.statusCode == 200) {
                                        var body = jsonDecode(response.body);
                                        if (body["Error"] == null) {
                                          poster_ = body["Poster"];
                                        }
                                      }
                                      setState(() {
                                        isLoading = false;
                                        poster = poster_;
                                      });
                                    }),
                                poster == null ? SizedBox() : Image.network(poster ??"",)
                              ],
                            )
                          ],
                        ),
                      )),
                      isLoading
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Center(child: ProgressRing())],
                            )
                          : SizedBox()
                    ]),
                    actions: [
                      FilledButton(
                          child: const Text("Guardar"),
                          onPressed: () async {
                            if (formkey.currentState!.validate()) {
                              setState(() {
                                isLoading = true;
                              });
                              for (String gender
                                  in genderController.text.split(",")) {
                                genders_.add(gender);
                              }
                              Movie movie = Movie(
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
                                  poster);
                              bool isSaved = await context
                                  .read<DataProvider>()
                                  .saveMovie(movie);
                              if (isSaved) {
                                Navigator.pop(context);
                              } else {
                                setState(() {
                                  isLoading = false;
                                });
                              }
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

  static showSettingsDialog(BuildContext context) async {
    return await showDialog(
        context: context,
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
}
