import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:pmdm_2526_t03/entities/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/snackbar.dart';
import '../../utils/keyboard.dart';

class ProductEditPage extends StatefulWidget {
  final Product? product;

  const ProductEditPage({super.key, this.product});

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  bool _isLoading = false;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //
  // Form
  //
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  String? _name;
  String? _priceText;

  //
  // Actions
  //
  Future<void> _apply() async {
    if (_formKey.currentState?.validate() != true) {
      setState(() {
        _autoValidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    _formKey.currentState!.save();

    try {
      hideKeyboard();

      setState(() => _isLoading = true);


      Product product = Product(
        id: widget.product?.id,
        name: _name,
        price: double.tryParse(_priceText ?? '0') ?? 0,
      );


      CollectionReference<Product> collectionRef = _db
          .collection('products')
          .withConverter(
        fromFirestore: Product.fromFirestore,
        toFirestore: (Product p, options) => p.toFirestore(),
      );

      if (widget.product == null) {

        DocumentReference docRef = await collectionRef.add(product);
        product.id = docRef.id;
      } else {

        await collectionRef.doc(product.id).set(product);
      }

      if (mounted) {
        showSnackBar(
          context,
          widget.product != null ? 'Producto actualizado' : 'Producto añadido',
        );
        Navigator.pop(context, product);
      }
    } on Exception catch (e) {
      if (mounted) showSnackBar(context, e.toString(), error: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    if (widget.product == null) return;

    setState(() => _isLoading = true);
    try {
      CollectionReference<Product> collectionRef = _db
          .collection('products')
          .withConverter(
        fromFirestore: Product.fromFirestore,
        toFirestore: (Product p, options) => p.toFirestore(),
      );

      await collectionRef.doc(widget.product!.id).delete();

      if (mounted) {
        showSnackBar(context, 'Producto borrado');
        Navigator.pop(context, 1);
      }
    } catch (e) {
      if (mounted) showSnackBar(context, e.toString(), error: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  //
  // Build fields
  //
  Widget _buildNameField() {
    return TextFormField(
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Introduzca el nombre',
        labelText: 'Nombre',
      ),
      initialValue: widget.product?.name,
      keyboardType: TextInputType.text,
      maxLength: 50,
      textInputAction: TextInputAction.next,
      validator: (value) =>
      value == null || value.isEmpty ? 'Obligatorio' : null,
      onSaved: (value) => _name = value,
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      decoration: const InputDecoration(
        hintText: 'Introduzca el precio',
        labelText: 'Precio',
      ),
      initialValue:
      widget.product?.price != null ? widget.product!.price.toString() : '',
      keyboardType: TextInputType.number,
      validator: (value) =>
      value == null || value.isEmpty ? 'Obligatorio' : null,
      onSaved: (value) => _priceText = value,
    );
  }

  //
  // Build
  //
  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.product?.name ?? 'Añadir producto'),
          actions: widget.product != null
              ? [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _delete,
            )
          ]
              : null,
        ),
        body: Form(
          autovalidateMode: _autoValidateMode,
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                _buildNameField(),
                const SizedBox(height: 16),
                _buildPriceField(),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _apply,
          tooltip: 'Guardar',
          child: const Icon(Icons.save),
        ),
      ),
    );
  }
}
