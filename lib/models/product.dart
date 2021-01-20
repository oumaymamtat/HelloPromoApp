import 'package:hello_promo/models/magazine.dart';

class Product {
  String name;
  String imageUrl;
  double originalPrice;
  double promoPrice;
  String categoryName;
  Magazine magazine;
  Product(
      {this.name,
      this.imageUrl,
      this.originalPrice,
      this.promoPrice,
      this.categoryName,
      this.magazine});
}
