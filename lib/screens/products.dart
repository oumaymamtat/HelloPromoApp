import 'package:flutter/material.dart';
import 'package:hello_promo/models/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hello_promo/models/product.dart';
import 'package:hello_promo/models/magazine.dart';
import 'package:hello_promo/screens/add_product.dart';
import 'package:hello_promo/screens/login.dart';
import 'package:hello_promo/screens/custom_widgets/app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Products extends StatefulWidget {
  final Category category;
  Products({Key key, this.category}) : super(key: key);
  @override
  _ProductsState createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  List<Product> finalProductsList = [];
  List<Product> filteredProductsList = [];
  bool isSearching = false;

  SharedPreferences logindata;
  bool state;

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      state = logindata.getBool('state');
    });
  }

  usersList() async {
    List usersList = await FirebaseFirestore.instance
        .collection("user")
        .get()
        .then((val) => val.docs);
    for (int i = 0; i < usersList.length; i++) {
      FirebaseFirestore.instance
          .collection("user")
          .doc(usersList[i].documentID.toString())
          .collection("product")
          .where("categoryName", isEqualTo: widget.category.name)
          .snapshots()
          .forEach((snapshot) async {
        Product p;
        List<Product> l = [];
        var docs = snapshot.docs;
        for (var Doc in docs) {
          FirebaseFirestore.instance
              .collection("user")
              .doc(usersList[i].documentID.toString())
              .collection("product")
              .doc(Doc.id)
              .collection("magazine")
              .snapshots()
              .forEach((snapshot) {
            snapshot.docs.forEach((magazine) {
              Magazine mag = Magazine(
                name: magazine.data()["name"],
                address: magazine.data()["address"],
                //     localization: magazine.data()["localization"]
              );
              p = Product(
                  name: Doc.data()["name"],
                  categoryName: Doc.data()["categoryName"],
                  promoPrice: double.parse(Doc.data()["promoPrice"].toString()),
                  originalPrice:
                      double.parse(Doc.data()["originalPrice"].toString()),
                  imageUrl: Doc.data()["imageUrl"],
                  magazine: mag);
              l.add(p);
              setState(() {
                finalProductsList = filteredProductsList = l;
              });
            });
          });
        }
      });
    }
  }

  void _filterProducts(value) {
    setState(() {
      filteredProductsList = finalProductsList
          .where((product) =>
              product.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    initial();
    usersList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // App Bar
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(120.0),
            child: MyAppBar(text: widget.category.name)),
        body: ListView(
          children: [
            Row(
              textDirection: TextDirection.rtl,
              children: <Widget>[
                // Search filter
                isSearching
                    ? IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: () {
                          setState(() {
                            this.isSearching = false;
                            filteredProductsList = finalProductsList;
                          });
                        },
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.search,
                          size: 30.0,
                        ),
                        onPressed: () {
                          setState(() {
                            this.isSearching = true;
                          });
                        },
                      ),
                // Add Button
                IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 30.0,
                    ),
                    onPressed: () {
                      if (state == true)
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddProduct()));
                      else {
                        showDialog<void>(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Please Login First !!'),
                              actions: <Widget>[
                                TextButton(
                                    child: Text('Login'),
                                    // navigate to login screen
                                    onPressed: () async {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Login()));
                                    })
                              ],
                            );
                          },
                        );
                      }
                    }),

                Expanded(
                    child: Container(
                  padding: EdgeInsets.only(left: 40),
                  child: !isSearching
                      ? Text(
                          'All Products',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0),
                        )
                      : TextField(
                          onChanged: (value) {
                            _filterProducts(value);
                          },
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              hintText: "Search...",
                              hintStyle: TextStyle(color: Colors.black)),
                        ),
                )),
              ],
            ),
            // Products GridView
            GridView.builder(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemCount: filteredProductsList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                childAspectRatio: 1.6,
              ),
              itemBuilder: (BuildContext context, int index) {
                // Product Card
                return Card(
                    margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                    elevation: 2.0,
                    clipBehavior: Clip.antiAlias,
                    child: Column(children: [
                      // Product Name
                      Container(
                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                          alignment: Alignment.topLeft,
                          child: Text(
                            filteredProductsList[index].name,
                            style: new TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                          )),

                      Stack(children: <Widget>[
                        // Product Image
                        Container(
                          height: 100,
                          alignment: Alignment.center,
                          //     margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Image.network(
                              filteredProductsList[index].imageUrl),
                        ),
                        // Product Prices
                        Container(
                            alignment: Alignment.centerRight,
                            margin: EdgeInsets.fromLTRB(0, 20, 20, 0),
                            child: Column(
                              children: [
                                Visibility(
                                  visible:
                                      filteredProductsList[index].promoPrice !=
                                              0
                                          ? true
                                          : false,
                                  child: Text(
                                    filteredProductsList[index]
                                            .promoPrice
                                            .toString() +
                                        ' DT',
                                    style: TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22.0),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    filteredProductsList[index]
                                            .originalPrice
                                            .toString() +
                                        ' DT',
                                    style: TextStyle(
                                        decoration: filteredProductsList[index]
                                                    .promoPrice !=
                                                0
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                        color: Colors.black,
                                        fontWeight: filteredProductsList[index]
                                                    .promoPrice ==
                                                0
                                            ? FontWeight.w500
                                            : FontWeight.bold,
                                        fontSize: filteredProductsList[index]
                                                    .promoPrice ==
                                                0
                                            ? 18.0
                                            : 14.0),
                                  ),
                                )
                              ],
                            )),
                      ]),
                      // Magazine Name
                      Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                        child: Text(
                          filteredProductsList[index].magazine.name,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Stack(
                        children: <Widget>[
                          // Magazine Address
                          Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.fromLTRB(10, 5, 0, 0),
                            child: Text(
                              filteredProductsList[index].magazine.address,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          // Magazine localization
                          /*  Container(
                            margin: EdgeInsets.fromLTRB(0, 3, 5, 0),
                            alignment: Alignment.topRight,
                            child: InkWell(
                              child: Icon(
                                Icons.room,
                                color: Colors.grey,
                              ),
                              onTap: () async {
                                var url = filteredProductsList[index]
                                    .magazine.address
                                 //   .localization
                                    ;
                                if (await canLaunch(url))
                                  await launch(url);
                                else
                                  throw "Could not launch $url";
                              },
                            ),
                          )*/
                        ],
                      )
                    ]));
              },
            ),
          ],
        ));
  }
}
