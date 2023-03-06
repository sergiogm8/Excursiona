import 'dart:async';

import 'package:chat_app/constants/assets.dart';
import 'package:chat_app/helper/helper_functions.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/db_service.dart';
import 'package:chat_app/shared/constants.dart';
import 'package:chat_app/shared/keyboard_visibility.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  // control if the keyboard is open or not
  bool keyboardIsOpen = false;
  KeyboardVisibility _keyboardVisibility = KeyboardVisibility();
  StreamSubscription<bool>? _subscription;
  AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    _keyboardVisibility.init(context);
    _subscription = _keyboardVisibility.stream.listen((bool isVisible) {
      setState(() {
        keyboardIsOpen = isVisible;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _keyboardVisibility.dispose();
    tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
        image: AssetImage(Assets.resourceImagesLoginImage2),
        fit: BoxFit.cover,
      )),
      child: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.25, 0.5],
          colors: [Colors.transparent, Color.fromARGB(216, 0, 0, 0)],
        )),
        height: double.infinity,
        child: Scaffold(
          // backgroundColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          body: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                    duration: const Duration(seconds: 2),
                    curve: Curves.bounceInOut,
                    child: SizedBox(
                        height: keyboardIsOpen
                            ? MediaQuery.of(context).size.height * 0.1
                            : MediaQuery.of(context).size.height * 0.31)),
                Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Text(
                      "¡Bienvenido\nde nuevo!",
                      style: GoogleFonts.inter(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )),
                const SizedBox(height: 24),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(240, 255, 255, 255),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50)),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 16.0),
                        TabBar(
                          indicatorColor: Colors.black,
                          indicatorPadding:
                              const EdgeInsets.symmetric(horizontal: 40),
                          unselectedLabelColor: Colors.grey[700],
                          labelColor: Colors.black,
                          splashFactory: NoSplash.splashFactory,
                          enableFeedback: false,
                          splashBorderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(50)),
                          controller: tabController,
                          tabs: [
                            Tab(
                              child: Text(
                                "Accede",
                                style: GoogleFonts.inter(
                                    // color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Tab(
                              child: Text(
                                "Regístrate",
                                style: GoogleFonts.inter(
                                    // color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                              ),
                            )
                          ],
                        ),
                        Flexible(
                            fit: FlexFit.tight,
                            child: TabBarView(
                              controller: tabController,
                              physics: const BouncingScrollPhysics(),
                              children: [
                                LoginTabWidget(authService: authService),
                                RegisterTabWidget(authService: authService),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),

                // height: double.maxFinite)
              ]),
        ),
      ),
    );
  }
}

class LoginTabWidget extends StatefulWidget {
  final AuthService authService;
  const LoginTabWidget({super.key, required this.authService});

  @override
  State<LoginTabWidget> createState() => _LoginTabWidgetState();
}

class _LoginTabWidgetState extends State<LoginTabWidget> {
  final _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoading = false;

  _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await widget.authService
          .signInWithEmailAndPassword(email, password)
          .then((value) async {
        if (value == true) {
          QuerySnapshot snapshot =
              await DBService(uid: FirebaseAuth.instance.currentUser!.uid)
                  .getUserData(email);
          HelperFunctions.saveUserLoggedInStatus(true);
          HelperFunctions.saveUserEmail(email);
          HelperFunctions.saveUserName(snapshot.docs[0].get("name"));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Loader()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 38, right: 38, top: 20, bottom: 5),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                          hintText: 'Correo electrónico',
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
                          hintText: 'Contraseña',
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
                              color: Constants.steelBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.15),
                        child: FormButton(
                            text: "Iniciar sesión", onPressed: _login),
                      ),

                      const Divider(
                        color: Color.fromARGB(255, 194, 194, 194),
                        height: 40,
                        thickness: 1,
                        // indent: 5,
                        // endIndent: 20,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: SignInButton(
                          Buttons.Google,
                          text: "Iniciar sesión con Google",
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          onPressed: () {
                            //TODO implementar login con google
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      )
                      // https://pub.dev/packages/auth_buttons/example
                      //https://pub.dev/packages/flutter_signin_button
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class FormButton extends StatelessWidget {
  final onPressed;
  final String text;
  const FormButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onPressed();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        fixedSize: Size(MediaQuery.of(context).size.width, 50),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class RegisterTabWidget extends StatefulWidget {
  final AuthService authService;
  const RegisterTabWidget({super.key, required this.authService});

  @override
  State<RegisterTabWidget> createState() => _RegisterTabWidgetState();
}

class _RegisterTabWidgetState extends State<RegisterTabWidget> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String email = "";
  String password = "";
  String name = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Loader()
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 38, right: 38, top: 20, bottom: 5),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        decoration: textInputDecoration.copyWith(
                          hintText: 'Nombre completo',
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
                          hintText: 'Correo electrónico',
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
                          hintText: 'Contraseña',
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
                      const SizedBox(height: 15),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.15),
                        child: FormButton(
                            text: "Registrarse", onPressed: _register),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await widget.authService
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
