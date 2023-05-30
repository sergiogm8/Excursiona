import 'package:excursiona/controllers/auth_controller.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/form_button.dart';
import 'package:excursiona/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  String email = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Recuperar contraseña",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Restablezca su contraseña",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "Por favor, ingrese su correo electrónico. Recibirá un enlace para restablecer su contraseña a través de su correo electrónico.",
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 15,
                // fontWeight: FontWeight.w300,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            TextFormField(
              decoration: textInputDecoration.copyWith(
                hintText: 'Correo electrónico',
                prefixIcon:
                    Icon(Icons.email, color: Theme.of(context).primaryColor),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                setState(() => email = value);
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                return RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value!)
                    ? null
                    : "Por favor ingrese un correo válido";
              },
            ),
            const SizedBox(
              height: 30,
            ),
            FormButton(
                text: "Enviar",
                onPressed: () {
                  //close keyboard
                  FocusScope.of(context).unfocus();
                  _resetPassword(email.trim());
                }),
          ],
        ),
      ),
    );
  }

  void _resetPassword(String email) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Loader());
    var emailSent = await AuthController().resetPassword(email);
    if (emailSent) {
      Navigator.pop(context);
      showSnackBar(context, Colors.green, "Correo enviado");
    } else {
      showSnackBar(context, Colors.red, "Error al enviar el correo");
    }
  }
}
