import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!; // siempre hay usuario

    final providerData = user.providerData.isNotEmpty ? user.providerData.first : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.goNamed('home');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _info('Proveedor', providerData?.providerId ?? 'Anónimo'),
            _info('ID proveedor', providerData?.uid ?? '—'),
            _info('ID usuario', user.uid),
            _info('Usuario anónimo', user.isAnonymous ? 'Sí' : 'No'),
            _info('Correo electrónico', user.email ?? '—'),
            _info('Correo verificado', user.emailVerified ? 'Sí' : 'No'),
            _info('Fecha de creación', user.metadata.creationTime?.toLocal().toString() ?? '—'),
            const Spacer(),

            // Botón borrar cuenta
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () async {
                try {
                  await user.delete();
                  context.goNamed('login');
                } on FirebaseAuthException catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.code == 'requires-recent-login'
                            ? 'Debes volver a iniciar sesión para borrar la cuenta'
                            : e.message ?? 'Error al borrar la cuenta',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Borrar cuenta'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}

