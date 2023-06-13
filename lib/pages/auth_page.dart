import 'dart:async';

import 'package:excursiona/shared/assets.dart';
import 'package:excursiona/controllers/auth_controller.dart';
import 'package:excursiona/pages/forgot_password.dart';
import 'package:excursiona/pages/home_page.dart';
import 'package:excursiona/pages/verify_email_page.dart';
import 'package:excursiona/services/auth_service.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/form_button.dart';
import 'package:excursiona/widgets/loader.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  // KeyboardVisibility _keyboardVisibility = KeyboardVisibility();
  // StreamSubscription<bool>? _subscription;
  AuthService authService = AuthService();

  // control if the keyboard is open or not
  bool keyboardIsOpen = false;

  late StreamSubscription<bool> keyboardSubscription;
  TabController? tabController;
  double topBoxFactor = 0.31;

  @override
  void dispose() {
    // _subscription?.cancel();
    // _keyboardVisibility.dispose();
    tabController!.dispose();
    keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      setState(() {
        topBoxFactor = visible ? 0.1 : 0.31;
      });
    });
  }

  // void _googleSignIn() {
  //   AuthController().signInWithGoogle().then((value) {
  //     if (value != true) {
  //       showSnackBar(context, Colors.red, value);
  //     } else {
  //       nextScreenReplace(context, const HomePage(), PageTransitionType.fade);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
        image: AssetImage(Assets.resourceImagesLoginImage),
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
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              const Positioned(
                  top: 80,
                  right: 0,
                  child: Image(
                    image: AssetImage(Assets.resourceImagesLogoRecortado),
                    height: 30,
                  )),
              Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height:
                            MediaQuery.of(context).size.height * topBoxFactor),
                    Padding(
                        padding: const EdgeInsets.only(left: 25),
                        child: tabController!.index == 0
                            ? Text(
                                "¡Bienvenido\nde nuevo!",
                                style: GoogleFonts.inter(
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              )
                            : Text(
                                "¡Comienza tu aventura ahora!",
                                style: GoogleFonts.inter(
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              )),
                    const SizedBox(height: 24),
                    Flexible(
                      fit: FlexFit.loose,
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
                              onTap: (index) {
                                setState(() {
                                  tabController!.index = index;
                                });
                              },
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
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // height: double.maxFinite)
                  ])
            ],
          ),
        ),
      ),
    );
  }
}

class LoginTabWidget extends StatefulWidget {
  const LoginTabWidget({super.key, required this.authService});

  final AuthService authService;

  @override
  State<LoginTabWidget> createState() => _LoginTabWidgetState();
}

class _LoginTabWidgetState extends State<LoginTabWidget> {
  String email = "";
  String password = "";

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  _login() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      AuthController()
          .signInWithEmailAndPassword(email, password)
          .then((value) {
        if (value == true) {
          nextScreenReplace(context, const HomePage(), PageTransitionType.fade);
        } else if (value == false) {
          nextScreenReplace(
              context, const VerifyEmailPage(), PageTransitionType.fade);
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

  void _googleSignIn() {
    AuthController().signInWithGoogle().then((value) {
      if (value != true) {
        showSnackBar(context, Colors.red, value);
      } else {
        nextScreenReplace(context, const HomePage(), PageTransitionType.fade);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: textInputDecoration.copyWith(
                          hintText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email,
                              color: Theme.of(context).primaryColor),
                        ),
                        onChanged: (value) {
                          setState(() => email = value.trim());
                        },
                        validator: (email) =>
                            email != null && !EmailValidator.validate(email)
                                ? "Por favor ingrese un correo válido"
                                : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        obscureText: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: textInputDecoration.copyWith(
                          hintText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock,
                              color: Theme.of(context).primaryColor),
                        ),
                        onChanged: (value) {
                          setState(() => password = value.trimRight());
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
                          onPressed: () {
                            nextScreen(context, const ForgotPasswordPage(),
                                PageTransitionType.bottomToTop);
                          },
                          child: const Text(
                            'No recuerdo mi contraseña',
                            style: TextStyle(
                              fontSize: 13,
                              color: Constants.steelBlue,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
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
                      const SizedBox(height: 5),
                      Text("o",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.bold,
                          )),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 5,
                          right: 30,
                          left: 30,
                        ),
                        child: SignInButton(
                          Buttons.Google,
                          text: "Inicia sesión con Google",
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          onPressed: () {
                            _googleSignIn();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class RegisterTabWidget extends StatefulWidget {
  const RegisterTabWidget({super.key, required this.authService});

  final AuthService authService;

  @override
  State<RegisterTabWidget> createState() => _RegisterTabWidgetState();
}

class _RegisterTabWidgetState extends State<RegisterTabWidget> {
  String email = "";
  String name = "";
  String password = "";

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      var result = await AuthController()
          .registerWithEmailAndPassword(name, email, password);
      if (result == true) {
        var isVerified = AuthController().isEmailVerified();
        if (!isVerified) {
          nextScreenReplace(
              context, const VerifyEmailPage(), PageTransitionType.fade);
        }
        // nextScreenReplace(context, const HomePage(), PageTransitionType.fade);
      } else {
        showSnackBar(
          context,
          Colors.red,
          result,
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                          setState(() => name = value.trimLeft());
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
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: textInputDecoration.copyWith(
                          hintText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email,
                              color: Theme.of(context).primaryColor),
                        ),
                        onChanged: (value) {
                          setState(() => email = value.trim());
                        },
                        validator: (email) =>
                            email != null && !EmailValidator.validate(email)
                                ? "Por favor ingrese un correo válido"
                                : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        obscureText: true,
                        decoration: textInputDecoration.copyWith(
                          hintText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock,
                              color: Theme.of(context).primaryColor),
                        ),
                        onChanged: (value) {
                          setState(() => password = value.trimRight());
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
}
