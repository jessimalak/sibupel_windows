import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:sibupel/data/provider.dart';
import 'package:sibupel/widgets/adaptive/button.dart';
import 'package:sibupel/widgets/adaptive/scaffold.dart';
import 'package:sibupel/widgets/adaptive/textfield.dart';
import 'package:sibupel/widgets/dialogs.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController mailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    mailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    LoadingDialog loadingDialog = LoadingDialog(context);
    loadingDialog.show('Ingresando...');
    await context.read<DataProvider>().login(mailController.text, passwordController.text, false);
    loadingDialog.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<DataProvider>().user;
    return AdaptiveScaffold(
      title: const Text("Ajustes"),
      content: user == null
          ? SizedBox(
              width: 300,
              height: 300,
              child: Container(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AdaptiveTextFormField(
                        controller: mailController,
                        placeholder: "Correo electrónico",
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingresa el email';
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      AdaptiveTextFormField(
                          controller: passwordController,
                          placeholder: "Contraseña",
                          obscureText: true,
                          onFieldSubmitted: (val) {
                            login();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Ingresa la contraseña';
                            return null;
                          }),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AdaptiveButton(
                              label: "Iniciar Sesión",
                              onPressed: () async {
                                login();
                              })
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          : Container(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                  AdaptiveButton(
                      label: "Cerrar sesión",
                      onPressed: () {
                        context.read<DataProvider>().signOut();
                      })
                ])
              ]),
            ),
    );
  }
}
