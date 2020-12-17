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
      appBar: AppBar(
        title: Text(
          "Create Account",
          style: TextStyle(fontSize: 28.0),
        ),
      ),
      body: RegisterForm(),
    );
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
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
            key: _registerForm,
            child: Column(children: [
              // avatar to pick image
              Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: getImage,
                  child: CircleAvatar(
                    child: (_image == null)
                        ? Icon(
                            Icons.person,
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
              TextFormField(
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'You should enter your name';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: 'Name',
                    hintText: 'Please enter your name',
                  ),
                  onSaved: (value) {
                    user.name = value;
                  }),
              // email field
              TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.email),
                    labelText: 'Email',
                    hintText: 'Please enter your email',
                  ),
                  validator: (value) => EmailValidator.validate(value)
                      ? null
                      : 'You should enter a valid email',
                  onSaved: (value) {
                    user.email = value;
                  }),
              // phone field
              TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.phone),
                    labelText: 'Phone',
                    hintText: 'Please enter your phone',
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
              // password field
              TextFormField(
                  validator: (value) {
                    if (value.length < 1) {
                      return 'Password should be minimum 1 character';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.lock),
                    labelText: 'Password',
                    hintText: 'Please enter your password',
                  ),
                  onSaved: (value) {
                    user.password = value;
                  }),
              // register button
              Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 10.0, 0, 0),
                  child:
                      // We use buttonTheme to add height and width to register button
                      ButtonTheme(
                          minWidth: 250.0,
                          height: 45.0,
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
                                    user.imageLocation =
                                        'image$randomNumber.jpg';
                                    // create firebase storage instance
                                    final Reference storageReference =
                                        FirebaseStorage.instanceFor()
                                            .ref()
                                            .child(user.imageLocation);
                                    // add image to firebase storage
                                    final UploadTask uploadTask =
                                        storageReference
                                            .putFile(File(_image.path));
                                    await uploadTask;
                                    final ref = FirebaseStorage.instanceFor()
                                        .ref()
                                        .child(user.imageLocation);
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
                                    'imageLocation': user.imageLocation,
                                    'state': 'false',
                                  });
                                  // inform user of successful register
                                  return showDialog<void>(
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
                                  );
                                }
                              })))
            ])));
  }
}
