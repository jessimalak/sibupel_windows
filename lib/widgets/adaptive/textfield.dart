import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:macos_ui/macos_ui.dart';

class AdaptiveTextField extends StatelessWidget{
  final TextEditingController? controller;
  final String? placeholder;
  final bool obscureText;
  final void Function(String value)? onFieldSubmitted;
  const AdaptiveTextField({super.key, this.controller, this.placeholder, this.obscureText = false, this.onFieldSubmitted});

  @override
  Widget build(BuildContext context) {
    if(Platform.isMacOS){
      return MacosTextField(controller: controller,placeholder: placeholder,obscureText: obscureText, onSubmitted: onFieldSubmitted,);
    }
    return TextBox(controller: controller, placeholder: placeholder,obscureText: obscureText, onSubmitted: onFieldSubmitted,);
  }
}

class AdaptiveTextFormField extends AdaptiveTextField{
  final String? Function(String? value)? validator;
  const AdaptiveTextFormField({super.key, super.controller, super.obscureText, super.onFieldSubmitted, super.placeholder,this.validator});

  @override
  Widget build(BuildContext context) {
    if(Platform.isMacOS){
      return MacosTextField(controller: controller,placeholder: placeholder,obscureText: obscureText, onSubmitted: onFieldSubmitted,);
    }
    return TextFormBox(controller: controller, placeholder: placeholder,obscureText: obscureText, validator: validator, onFieldSubmitted: onFieldSubmitted,);
  }
}