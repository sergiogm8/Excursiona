import 'package:chat_app/helper/helper_functions.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/screens/register_screen.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/db_service.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoading = false;
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(250, 250, 250, .98),
      body: _isLoading
          ? const Loader()
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 38, vertical: 80),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Center(
                        child: Text("Iniciar sesión",
                            style: TextStyle(
                                fontSize: 48, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 50),
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
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 38),
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
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _login();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Iniciar sesión",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text.rich(
                        TextSpan(
                          text: "¿No tienes cuenta?",
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: "Regístrate",
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  nextScreen(context, const RegisterScreen());
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

  _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .signInWithEmailAndPassword(email, password)
          .then((value) async {
        if (value == true) {
          QuerySnapshot snapshot =
              await DBService(uid: FirebaseAuth.instance.currentUser!.uid)
                  .getUserData(email);
          HelperFunctions.saveUserLoggedInStatus(true);
          HelperFunctions.saveUserEmail(email);
          HelperFunctions.saveUserName(snapshot.docs[0].get("name"));
          nextScreenReplace(context, const HomePage());
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
