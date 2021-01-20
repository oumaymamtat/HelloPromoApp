import 'package:flutter/material.dart';
import 'package:hello_promo/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hello_promo/screens/home.dart';
import 'package:hello_promo/screens/register.dart';
import 'package:hello_promo/screens/custom_widgets/app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _loginForm = GlobalKey<FormState>();
  User user = User();
  SharedPreferences logindata;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(120.0),
            child: MyAppBar(
              //  currentUser: currentUser,
              text: "Login",
            )),
        body: Container(
            margin: EdgeInsets.only(top: 50),
            child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Form(
                    key: _loginForm,
                    child: Column(children: [
                      // Name field
                      TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'You should enter your name';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.blue,
                            ),
                            labelText: 'Name',
                            hintText: 'Please enter your name',
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                          onSaved: (value) {
                            user.name = value;
                          }),
                      Divider(),
                      // password field
                      TextFormField(
                          validator: (value) {
                            if (value.length < 1) {
                              return 'Password should be minimum 1 character';
                            }
                            return null;
                          },
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.blue,
                            ),
                            labelText: 'Password',
                            hintText: 'Please enter your password',
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                          onSaved: (value) {
                            user.password = value;
                          }),
                      Divider(),
                      // if not registered text
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Register()));
                        },
                        child: Text(
                          "You are not registered yet?",
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 15.0,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                      Divider(),
                      // login button
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0, 0),
                          child: ButtonTheme(
                              minWidth: 300.0,
                              height: 45.0,
                              child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20.0)),
                                  color: Colors.blue,
                                  child: Text(
                                    "login",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () async {
                                    // save form
                                    if (_loginForm.currentState.validate()) {
                                      _loginForm.currentState.save();
                                      // verify that user with entered details exist
                                      final QuerySnapshot result =
                                          await Future.value(FirebaseFirestore
                                              .instance
                                              .collection("user")
                                              .where("name",
                                                  isEqualTo: user.name)
                                              .where("password",
                                                  isEqualTo: user.password)
                                              .get());
                                      final List<DocumentSnapshot> documents =
                                          result.docs;
                                      print(documents.toList());
                                      // if user exist
                                      if (documents.length == 1) {
                                        print("username exist");

                                        // update user state
                                        FirebaseFirestore.instance
                                            .collection("user")
                                            .doc(documents.elementAt(0).id)
                                            .update({
                                          'state': true,
                                        });
                                        // inform user by successful login
                                        return showDialog<void>(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                  'You are logged in successfully !'),
                                              actions: <Widget>[
                                                TextButton(
                                                    child: Text('Go to home'),
                                                    // navigate to home screen
                                                    onPressed: () async {
                                                      SharedPreferences
                                                          logindata =
                                                          await SharedPreferences
                                                              .getInstance();

                                                      logindata.setString(
                                                          'id',
                                                          documents
                                                              .elementAt(0)
                                                              .id);

                                                      logindata.setBool(
                                                          'state',
                                                          documents
                                                              .elementAt(0)
                                                              .get('state'));
                                                      logindata.setString(
                                                          'name',
                                                          documents
                                                              .elementAt(0)
                                                              .get('name'));

                                                      logindata.setString(
                                                          'imageUrl',
                                                          documents
                                                              .elementAt(0)
                                                              .get('imageUrl'));

                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      Home()));
                                                    })
                                              ],
                                            );
                                          },
                                        );
                                      } // if user does not exist
                                      else {
                                        print("username doesn't exist");
                                        // show message error verify your details
                                        return showDialog<void>(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Login error !!'),
                                              content: SingleChildScrollView(
                                                child: ListBody(
                                                  children: <Widget>[
                                                    Text(
                                                        'Please check you name and password !'),
                                                  ],
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text(
                                                      'Check you contact details'),
                                                  // Return to login screen
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    Login()));
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    }
                                  })))
                    ])))));
  }
}
