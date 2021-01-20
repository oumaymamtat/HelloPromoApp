import 'package:flutter/material.dart';
import 'package:hello_promo/models/product.dart';
import 'package:hello_promo/models/category.dart';
import 'custom_widgets/app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hello_promo/screens/home.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hello_promo/models/magazine.dart';

class AddProduct extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(120.0),
            child: MyAppBar(text: 'Add Product')),
        body: AddProductForm(),
      ),
    );
  }
}

class AddProductForm extends StatefulWidget {
  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  PickedFile pickedImage;
  File _image;
  final _formKey = GlobalKey<FormState>();
  Product product = new Product();
  Magazine productMagazine = new Magazine();
  List<String> _categoriesNames = [];
  String _categoryName;
  List<String> _magazinesNames = [
    "Aziza",
    "Magasin Général",
    "Carrefour",
    "Monoprix",
    "Mini-Market",
    "Géant",
    "Others"
  ];
  String _magazineName;
  String _magazineAddress;

  List<String> _magazinesAddresses = [
    "Ariana (Aryanah)",
    "Beja (Bajah)",
    "Ben Arous (Bin 'Arus)",
    "Bizerte (Banzart)",
    "Gabes (Qabis)",
    "Gafsa (Qafsah)",
    "Jendouba (Jundubah)",
    "Kairouan (Al Qayrawan)",
    "Kasserine (Al Qasrayn)",
    "Kebili (Qibili)",
    "Kef (Al Kaf)",
    "Mahdia (Al Mahdiyah)",
    "Manouba (Manubah)",
    "Medenine (Madanin)",
    "Monastir (Al Munastir)",
    "Nabeul (Nabul)",
    "Sfax (Safaqis)",
    "Sidi Bou Zid (Sidi Bu Zayd)",
    "Siliana (Silyanah)",
    "Sousse (Susah)",
    "Tataouine (Tatawin)",
    "Tozeur (Tawzar)",
    "Tunis",
    "Zaghouan (Zaghwan)"
  ];

  String userId;
  SharedPreferences logindata;
  String selectedSalutation;
  String productMagazineLocalization = '';
  var productID;
  String selectedMagazineAddress = '';

  Future getImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        // _controller.text =  = productMagazineLocalization =
        selectedMagazineAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
        _magazinesAddresses.insert(0, selectedMagazineAddress);
      });
    } catch (e) {
      print(e);
    }
  }

  _getCategoriesList() {
    FirebaseFirestore.instance
        .collection('category')
        .snapshots()
        .forEach((element) {
      var docs = element.docs;
      List<String> l = [];

      Category c;
      for (var Doc in docs) {
        c = Category(
            name: Doc.data()['name'], imageUrl: Doc.data()['imageUrl']);
        l.add(c.name);
        setState(() {
          _categoriesNames = l;
        });
      }
      _categoriesNames.add('others');
    });
  }

  _getUserId() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      userId = logindata.getString('id');
    });
  }

  String numberValidator(String value) {
    final n = num.tryParse(value);
    if (n == null) {
      return 'please enter valid price';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _getCategoriesList();
    _getUserId();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: new ListView(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
          children: <Widget>[
            // Product image
            Container(
              margin: const EdgeInsets.only(bottom: 15.0),
              alignment: Alignment.center,
              child: InkWell(
                onTap: getImage,
                child: CircleAvatar(
                  child: (_image == null)
                      ? Icon(
                          Icons.add_a_photo,
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
            // Product Name
            new TextFormField(
              decoration: const InputDecoration(
                icon: const Icon(Icons.add_shopping_cart),
                hintText: 'Product Name',
                contentPadding: EdgeInsets.only(left: 15),
              ),
              validator: (String value) {
                if (value.isEmpty) {
                  return 'Please enter product name';
                }
                return null;
              },
              onSaved: (String value) {
                product.name = value;
              },
            ),
            // Product Category
            new FormField(
              builder: (FormFieldState state) {
                return DropdownButtonFormField<String>(
                  onSaved: (String value) {
                    product.categoryName = value;
                  },
                  decoration: InputDecoration(
                    icon: const Icon(Icons.color_lens),
                    labelText: '',
                    contentPadding: EdgeInsets.fromLTRB(15, 0, 0, 15),
                  ),
                  value: _categoryName,
                  hint: Text(
                    'Category',
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      _categoryName = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please choose category' : null,
                  items: _categoriesNames.map((String value) {
                    return new DropdownMenuItem(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                );
              },
            ),
            // Product original Price
            new TextFormField(
              decoration: const InputDecoration(
                icon: const Icon(Icons.attach_money),
                hintText: 'Original Price',
                contentPadding: EdgeInsets.only(left: 15),
              ),
              validator: numberValidator,
              onSaved: (String value) {
                product.originalPrice = num.tryParse(value)?.toDouble();
              },
            ),
            // Product promoprice
            new TextFormField(
              decoration: const InputDecoration(
                icon: const Icon(Icons.card_giftcard),
                hintText: 'Promo Price',
                contentPadding: EdgeInsets.only(left: 15),
              ),
              //  validator: numberValidator,
              onSaved: (String value) {
                product.promoPrice = num.tryParse(value)?.toDouble();
              },
            ),
            // Product Magazine name
            new FormField(
              builder: (FormFieldState state) {
                return DropdownButtonFormField<String>(
                  onSaved: (String value) {
                    productMagazine.name = value;
                  },
                  decoration: InputDecoration(
                    icon: const Icon(Icons.business_center),
                    labelText: '',
                    contentPadding: EdgeInsets.fromLTRB(15, 0, 0, 15),
                  ),
                  value: _magazineName,
                  hint: Text(
                    'Magazine Name',
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      _magazineName = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please choose magazine name' : null,
                  items: _magazinesNames.map((String value) {
                    return new DropdownMenuItem(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                );
              },
            ),
            // Product Magazine address
            new FormField(
              builder: (FormFieldState state) {
                return DropdownButtonFormField<String>(
                  onSaved: (String value) {
                    productMagazine.address = value;
                  },
                  decoration: InputDecoration(
                    icon: const Icon(Icons.room),
                    labelText: '',
                    contentPadding: EdgeInsets.fromLTRB(15, 0, 0, 5),
                  ),
                  hint: Text(
                    'Magazine Address',
                  ),
                  validator: (value) =>
                      value == null ? 'Please choose Magazine Address' : null,
                  value: _magazinesAddresses.elementAt(0),
                  onChanged: (String newValue) {
                    setState(() {
                      _magazineAddress = newValue;
                    });
                  },
                  items: _magazinesAddresses.map((String value) {
                    return new DropdownMenuItem(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                );
              },
            ),
            // Add Product Button
            Padding(
                padding: const EdgeInsets.fromLTRB(30, 15, 5, 0),
                child: ButtonTheme(
                    minWidth: 20.0,
                    height: 45.0,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                      color: Colors.blue,
                      child: Text(
                        "Add Product",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          // save image to storage
                          if (_image != null) {
                            // give random numver as image location
                            int randomNumber = Random().nextInt(100000);
                            var imageLocation = 'image$randomNumber.jpg';
                            // create firebase storage instance
                            final Reference storageReference =
                                FirebaseStorage.instanceFor()
                                    .ref()
                                    .child(imageLocation);
                            // add image to firebase storage
                            final UploadTask uploadTask =
                                storageReference.putFile(File(_image.path));
                            await uploadTask;
                            final ref = FirebaseStorage.instanceFor()
                                .ref()
                                .child(imageLocation);
                            product.imageUrl = await ref.getDownloadURL();

                            // save product to DB
                            print("add produdt to user id :");
                            print(userId);
                            final collRef = FirebaseFirestore.instance
                                .collection("user")
                                .doc(userId)
                                .collection("product");
                            var docReferance = collRef.doc();
                            docReferance.set({
                              'name': product.name,
                              'imageUrl': product.imageUrl,
                              'originalPrice': product.originalPrice,
                              'promoPrice': product.promoPrice,
                              'categoryName': product.categoryName,
                            }).then((doc) {
                              // save product magazine to DB
                              FirebaseFirestore.instance
                                  .collection("user")
                                  .doc(userId)
                                  .collection("product")
                                  .doc(docReferance.id)
                                  .collection("magazine")
                                  .doc()
                                  .set({
                                'name': productMagazine.name,
                                'address': productMagazine.address,
                                //    'localization': productMagazineLocalization
                              });
                            }).catchError((error) {
                              print(error);
                            });
                            // show successful add messgae
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: new Text("Thank you"),
                                    content: new Text(
                                        "Product Added Successfully !"),
                                    actions: <Widget>[
                                      new FlatButton(
                                        child: new Text("Go to home"),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Home()));
                                        },
                                      ),
                                    ],
                                  );
                                });
                          }
                          // if image not selected
                          else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: new Text("Something Wrong"),
                                    content:
                                        new Text("Please select product image"),
                                    actions: <Widget>[
                                      new FlatButton(
                                          child: new Text("Ok"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          }),
                                    ],
                                  );
                                });
                          }
                        }
                      },
                    )))
          ],
        ));
  }
}
