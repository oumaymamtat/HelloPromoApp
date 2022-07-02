import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:hello_promo/models/user.dart';
import 'package:hello_promo/screens/login.dart';
import 'package:image_picker/image_picker.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            height: 600,
            padding: EdgeInsets.fromLTRB(0, 60, 0, 0),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("images/register.jpeg"),
                    fit: BoxFit.cover)),
            child: SingleChildScrollView(
                child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              elevation: 12,
              child: RegisterForm(),
            ))));
  }
}

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  // form key
  final _registerForm = GlobalKey<FormState>();
  // User instance
  User user = User();
  PickedFile pickedImage;
  File _image;
  // Function to get picked image
  Future getImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Form(
            key: _registerForm,
            child: Column(children: [
              // avatar to pick image
              Container(
                margin: const EdgeInsets.only(bottom: 15.0),
                alignment: Alignment.center,
                child: InkWell(
                  onTap: getImage,
                  child: CircleAvatar(
                    child: (_image == null)
                        ? Icon(
                            Icons.image,
                            color: Colors.white,
                          )
                        : null,
                    backgroundColor: Colors.blue,
                    radius: 30.0,
                    backgroundImage:
                        (_image != null) ? Image.file(_image).image : null,
                  ),
                ),
              ),
              // Name field
              Container(
                margin: const EdgeInsets.only(top: 10.0),
                height: 40.0,
                child: TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'You should enter your name';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                      labelText: 'Name',
                      hintText: 'Please enter your name',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    onSaved: (value) {
                      user.name = value;
                    }),
              ),
              Divider(
                height: 10.0,
              ),
              // email field
              Container(
                margin: const EdgeInsets.only(top: 10.0),
                height: 40.0,
                child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.email,
                        color: Colors.blue,
                      ),
                      labelText: 'Email',
                      hintText: 'Please enter your email',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    validator: (value) => EmailValidator.validate(value)
                        ? null
                        : 'You should enter a valid email',
                    onSaved: (value) {
                      user.email = value;
                    }),
              ),
              Divider(
                height: 10.0,
              ),
              // phone field
              Container(
                margin: const EdgeInsets.only(top: 10.0),
                height: 40.0,
                child: TextFormField(
                    //     keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.phone,
                        color: Colors.blue,
                      ),
                      labelText: 'Phone',
                      hintText: 'Please enter your phone',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'You should enter your phone';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      user.phone = value;
                    }),
              ),
              Divider(
                height: 10.0,
              ),
              // password field
              Container(
                margin: const EdgeInsets.only(top: 10.0),
                height: 40.0,
                child: TextFormField(
                    validator: (value) {
                      if (value.length < 1) {
                        return 'Password should be minimum 1 character';
                      }
                      return null;
                    },
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock,
                        color: Colors.blue,
                      ),
                      labelText: 'Password',
                      hintText: 'Please enter your password',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    onSaved: (value) {
                      user.password = value;
                    }),
              ),
              Divider(
                height: 3.0,
              ),
              // register button
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15.0, 0, 0),
                  child:
                      // We use buttonTheme to add height and width to register button
                      ButtonTheme(
                          minWidth: 150.0,
                          height: 40.0,
                          child: RaisedButton(
                              // We use shape to give circular form to register button
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                              color: Colors.blue,
                              child: Text(
                                "Register",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () async {
                                // save form state
                                if (_registerForm.currentState.validate()) {
                                  _registerForm.currentState.save();
                                  if (_image != null) {
                                    // give random numver as image location
                                    int randomNumber = Random().nextInt(100000);
                                    var imageLocation =
                                        'image$randomNumber.jpg';
                                    // create firebase storage instance
                                    final Reference storageReference =
                                        FirebaseStorage.instanceFor()
                                            .ref()
                                            .child(imageLocation);
                                    // add image to firebase storage
                                    final UploadTask uploadTask =
                                        storageReference
                                            .putFile(File(_image.path));
                                    await uploadTask;
                                    final ref = FirebaseStorage.instanceFor()
                                        .ref()
                                        .child(imageLocation);
                                    user.imageUrl = await ref.getDownloadURL();
                                  }
                                  //  add form fields to firebase firestore (cloud firestore)
                                  FirebaseFirestore.instance
                                      .collection("user")
                                      .doc()
                                      .set({
                                    'name': user.name,
                                    'email': user.email,
                                    'phone': user.phone,
                                    'password': user.password,
                                    'imageUrl': user.imageUrl,
                                    // 'imageLocation': imageLocation,
                                    'state': false,
                                  });
                                  // inform user of successful register

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Login()));
                                  /*   return showDialog<void>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Welcome to our app!'),
                                        content: SingleChildScrollView(
                                          child: ListBody(
                                            children: <Widget>[
                                              Text(
                                                  'Enjoy sharing your favourite products with us!'),
                                            ],
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('Log In'),
                                            // navigate to login screen
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Login()));
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );*/
                                }
                              })))
            ])));
  }
}
