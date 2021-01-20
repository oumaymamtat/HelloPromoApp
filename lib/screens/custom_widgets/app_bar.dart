import 'package:flutter/material.dart';
import 'package:hello_promo/screens/home.dart';
import 'package:hello_promo/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAppBar extends StatefulWidget {
  final String text;

  MyAppBar({Key key, this.text}) : super(key: key);
  @override
  _MyAppBarState createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  SharedPreferences logindata;
  String username;
  String imageUrl;
  bool state;
  @override
  void initState() {
    super.initState();
    initial();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      username = logindata.getString('name');
      state = logindata.getBool('state');
      imageUrl = logindata.getString('imageUrl');
    });
  }

  logout() async {
    print("logout");
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log out'),
          actions: <Widget>[
            RaisedButton(
                color: Colors.red,
                child: Text('Confirm'),

                // navigate to home screen
                onPressed: () async {
                  logindata.setBool('state', false);

                  setState(() {
                    state = false;
                  });

                  return showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('You are logged out successfully !'),
                        actions: <Widget>[
                          TextButton(
                              child: Text('Go to home'),
                              // navigate to home screen
                              onPressed: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Home()));
                              })
                        ],
                      );
                    },
                  );
                })
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return AppBar(
        elevation: 0.0,
        title: Container(
          margin: const EdgeInsets.only(top: 20),
          child: Text(widget.text,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 25.0)),
        ),
        flexibleSpace: Image(
          image: AssetImage('images/login.jpeg'),
          fit: BoxFit.cover,
        ),
        backgroundColor: Colors.transparent,
        actions: [
          Container(
              margin: EdgeInsets.fromLTRB(0, 20, 10, 0),
              child: InkWell(
                  onTap: () {
                    state == false
                        ? Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Login()))
                        : logout();
                  },
                  child:
                      // if not connected
                      state == false
                          ? CircleAvatar(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue,
                              child: Icon(
                                Icons.person,
                                color: Colors.blue,
                              ))
                          :
                          // if connected

                          CircleAvatar(
                              backgroundImage: imageUrl != null
                                  ? Image.network(imageUrl).image
                                  : null,
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue,
                              child: imageUrl == null
                                  ? Text(
                                      "$username",
                                      style: TextStyle(fontSize: 7.0),
                                    )
                                  : null)))
        ]);
  }
}
