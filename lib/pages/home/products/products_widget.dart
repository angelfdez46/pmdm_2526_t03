import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pmdm_2526_t03/pages/home/products/product_item_widget.dart';
import '../../../entities/product.dart';
import 'package:pmdm_2526_t03/pages/product_edit/product_edit_page.dart';




class ProductsWidget extends StatefulWidget {
  const ProductsWidget({super.key});

  @override
  State<ProductsWidget> createState() => _ProductsWidgetState();
}

class _ProductsWidgetState extends State<ProductsWidget> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late CollectionReference<Product> _collectionRef;
  late Query<Product> _query;
  Stream<QuerySnapshot<Product>>? _querySnapshotStreams;

  @override
  void initState() {
    super.initState();

    _collectionRef = _db
        .collection('products')
        .withConverter(
      fromFirestore: Product.fromFirestore,
      toFirestore: (Product p, _) => p.toFirestore(),
    );

    _query = _collectionRef.orderBy('name');

    _querySnapshotStreams = _query.snapshots();
  }

  // Editar producto
  void _edit(Product item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductEditPage(product: item)),
    );
  }

  // Construye la lista de ProductItemWidget
  Widget _buildItems(List<Product>? data) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: data?.length ?? 0,
      itemBuilder: (context, index) {
        final item = data![index];
        return ProductItemWidget(
          item: item,
          onPressEdit: () => _edit(item),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Product>>(
      stream: _querySnapshotStreams,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text("No hay productos"));
        }

        final products = docs.map((doc) => doc.data()).toList();

        return _buildItems(products);
      },
    );
  }
}
