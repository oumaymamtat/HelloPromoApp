import 'package:flutter/material.dart';
import 'package:hello_promo/screens/register.dart';
import 'package:hello_promo/screens/login.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: ListView(
          children: [
            // Welcome Text
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 250, 20, 50),
              child: Center(
                child: Text(
                  "Welcome to home page ",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 20.0,
                      decoration: TextDecoration.none),
                ),
              ),
            ),
            // Register Button
            FlatButton(
              child: Text("Register"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Register()));
              },
            ),
            // Login Button
            FlatButton(
              child: Text("Login"),
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Login()));
              },
            ),
          ],
        ));
  }
}
