import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String? id;
  String? name;
  double? price;

  Product({this.id, this.name, this.price});

  factory Product.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options
      ) {
    final map = snapshot.data();
    return Product(
      id: snapshot.id,
      name: map?['name'] as String?,
      price: map?['price'] != null
          ? (map!['price'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
    };
  }
}
