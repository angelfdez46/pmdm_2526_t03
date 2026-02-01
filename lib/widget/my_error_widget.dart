import 'package:flutter/material.dart';

class MyErrorWidget extends StatelessWidget {
  final Object? error;

  const MyErrorWidget(this.error, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Error: $error',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}