import 'package:flutter/material.dart';
import 'package:pmdm_2526_t03/entities/product.dart';

class ProductItemWidget extends StatelessWidget {
  final Product item;
  final VoidCallback onPressEdit;

  const ProductItemWidget({
    super.key,
    required this.item,
    required this.onPressEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.shopping_cart),
      title: Text(item.name ?? 'Sin nombre'),
      subtitle: Text('${item.price ?? 0} €'),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: onPressEdit,
      ),
      dense: true,
    );
  }
}

