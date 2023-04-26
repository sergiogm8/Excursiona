import 'package:excursiona/helper/helper_functions.dart';
import 'package:excursiona/pages/auth_page.dart';
import 'package:excursiona/pages/home_page.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    initializeFirebaseMessaging();
    getIsUserLoggedIn();
  }

  initializeFirebaseMessaging() async {
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  void getIsUserLoggedIn() async {
    await HelperFunctions.getUserLoggedInStatus().then((value) {
      if (value != null) {
        setState(() {
          _isUserLoggedIn = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Excursiona',
          theme: ThemeData(
            primaryColor: Constants.indigoDye,
            textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
          ),
          home: _isUserLoggedIn ? const HomePage() : const AuthPage(),
        ));
  }
}
