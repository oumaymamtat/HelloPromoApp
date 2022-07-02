import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hello_promo/screens/products.dart';
import 'package:hello_promo/models/category.dart';
import 'package:hello_promo/models/product.dart';
import 'package:hello_promo/screens/custom_widgets/app_bar.dart';

class Home extends StatefulWidget {
  Home({
    Key key,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // App Bar
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(120.0),
            child: MyAppBar(
              text: 'Hello Promo',
            )),
        body: ListView(
          children: [
            Container(
                padding: EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Text(
                      "Categories",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                    ),
                  ],
                )),
            CategoriesGrid(),
          ],
        ));
  }
}

class CategoriesGrid extends StatefulWidget {
  @override
  _CategoriesGridState createState() => _CategoriesGridState();
}

class _CategoriesGridState extends State<CategoriesGrid> {
  Category category = new Category();
  Product p;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('category').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          // Categories Grid View
          return GridView.count(
              physics: ScrollPhysics(),
              crossAxisCount: 2,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: snapshot.data.docs.map((data) {
                return InkWell(
                  // on Tap Navigate to Products with clicked category Name
                  onTap: () {
                    category.name = data.get("name");
                    category.imageUrl = data.get("imageUrl");

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Products(category: category),
                        ));
                  },
                  // Category Card
                  child: Card(
                      margin: const EdgeInsets.fromLTRB(10, 15, 10, 20),
                      elevation: 2.0,
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          // Category Name
                          Padding(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: Center(
                                child: RichText(
                                  text: new TextSpan(
                                    style: new TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: data['name'],
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                          // Category Image
                          Container(
                            height: 100,
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: data["imageUrl"] != null
                                ? Image.network(data["imageUrl"])
                                : null,
                          )
                        ],
                      )),
                );
              }).toList());
        });
  }
}
