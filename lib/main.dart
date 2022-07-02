import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hello_promo/screens/home.dart';
import 'package:splashscreen/splashscreen.dart';

void main() async {
  // To initialize FlutterFire
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: new SplashScreen(
        seconds: 5,
        navigateAfterSeconds: new Home(),
        title: new Text(
          'Welcome',
          style: new TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
              color: Colors.grey[700]),
        ),
        image: new Image.asset("images/welcome.png"),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 150.0,
        loaderColor: Colors.lightBlue),
  ));
}
