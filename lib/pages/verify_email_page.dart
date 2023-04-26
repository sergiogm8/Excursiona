import 'dart:async';

import 'package:excursiona/controllers/auth_controller.dart';
import 'package:excursiona/pages/home_page.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/form_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:page_transition/page_transition.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  Timer? timer;
  AuthController authController = AuthController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isEmailVerified = authController.isEmailVerified();
    if (!isEmailVerified) {
      _sendEmailVerification();

      timer = Timer.periodic(
          const Duration(seconds: 4), (_) => _checkEmailVerification());
    }
    print(isEmailVerified);
  }

  @override
  void dispose() {
    timer?.cancel;
    super.dispose();
  }

  _checkEmailVerification() async {
    await authController.reloadAuthInstance();
    setState(() {
      isEmailVerified = authController.isEmailVerified();
    });
    if (isEmailVerified) {
      timer?.cancel();
      await authController.setUserLoggedIn();
      nextScreenReplace(context, const HomePage(), PageTransitionType.fade);
    }
  }

  _sendEmailVerification() async {
    var result = await authController.sendEmailVerification();
    if (result != true) {
      showSnackBar(context, Colors.red, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          "Verificar email",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Verifique su correo electrónico",
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
              "Para continuar usando excursiona, debe verificar su correo electrónico. Por favor, revise su correo electrónico y haga clic en el enlace de verificación que le hemos enviado.",
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 15,
                // fontWeight: FontWeight.w300,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            FormButton(
                text: "Reenviar correo de verificación",
                onPressed: _sendEmailVerification),
          ],
        ),
      ),
    );
  }
}
