import 'package:chat_app/helper/helper_functions.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  AuthService authService = AuthService();
  bool _isLoading = false;
  String email = "";
  String password = "";
  String name = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 250, 250, .98),
      body: _isLoading
          ? const Loader()
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 38, vertical: 200),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Center(
                        child: Text("Registro",
                            style: TextStyle(
                                fontSize: 48, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 50),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                          labelText: 'Nombre completo',
                          prefixIcon: Icon(Icons.person,
                              color: Theme.of(context).primaryColor),
                        ),
                        onChanged: (value) {
                          setState(() => name = value);
                        },
                        validator: (value) {
                          if (value!.isNotEmpty) {
                            return null;
                          } else {
                            return "Por favor ingrese su nombre completo";
                          }
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email,
                              color: Theme.of(context).primaryColor),
                        ),
                        onChanged: (value) {
                          setState(() => email = value);
                        },
                        validator: (value) {
                          return RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value!)
                              ? null
                              : "Por favor ingrese un correo válido";
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        obscureText: true,
                        decoration: textInputDecoration.copyWith(
                          labelText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock,
                              color: Theme.of(context).primaryColor),
                        ),
                        onChanged: (value) {
                          setState(() => password = value);
                        },
                        validator: (value) {
                          return value!.length < 6
                              ? "La contraseña debe tener al menos 6 caracteres"
                              : null;
                        },
                      ),
                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'No recuerdo mi contraseña',
                            style: TextStyle(
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          register();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Registrarse",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          text: "¿Ya tienes una cuenta? ",
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: " Inicia sesión",
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  nextScreenReplace(
                                      context,
                                      const LoginScreen(),
                                      PageTransitionType.fade);
                                },
                              style: const TextStyle(
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .registerWithEmailAndPassword(name, email, password)
          .then((value) async {
        if (value == true) {
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserName(name);
          await HelperFunctions.saveUserEmail(email);
          await HelperFunctions.saveUserProfilePic("");
          nextScreenReplace(context, const HomePage(), PageTransitionType.fade);
        } else {
          showSnackBar(
            context,
            Colors.red,
            value,
          );
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}
