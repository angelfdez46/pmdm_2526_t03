import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../utils/snackbar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      context.goNamed('login');
    } catch (e) {
      showSnackBar(context, 'Error al cerrar sesión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(user != null
                ? 'Bienvenido ${user.isAnonymous ? "Anónimo" : user.email}'
                : 'Bienvenido'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _logout(context),
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
