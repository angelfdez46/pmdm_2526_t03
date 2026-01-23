import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../utils/snackbar.dart';
import '../../utils/keyboard.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;

  /// Crear cuenta
  Future<void> _createAccount() async {
    if (_formKey.currentState?.validate() != true) return;
    _formKey.currentState!.save();
    hideKeyboard();

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email!, password: _password!);

      final user = userCredential.user;
      if (user != null) {
        // Enviar email de verificación
        await user.sendEmailVerification();

        // Redirigir a home (el usuario puede estar logueado aunque no verifique)
        context.goNamed('home');

        showSnackBar(context, 'Cuenta creada. Se ha enviado un correo de verificación.',
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = switch (e.code) {
        'email-already-in-use' => 'La cuenta ya existe para ese correo.',
        'weak-password' => 'La contraseña es demasiado débil.',
        'invalid-email' => 'Correo inválido.',
        _ => e.message ?? 'Error al registrar',
      };
      if (mounted) showSnackBar(context, message);
    } catch (e) {
      if (mounted) showSnackBar(context, 'Error inesperado: $e');
    }
  }

  /// Ir a LoginPage
  void _goToLogin() {
    context.goNamed('login');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Mostrar diálogo de confirmación
          final shouldLeave = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Salir'),
              content: const Text('¿Estás seguro de que quieres salir?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // No salir
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true), // Salir
                  child: const Text('Salir'),
                ),
              ],
            ),
          );

          return shouldLeave ?? false;
        },
        child: Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Correo electrónico
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Correo electrónico'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v?.isEmpty ?? true) ? 'Obligatorio' : null,
                    onSaved: (v) => _email = v,
                  ),
                  const SizedBox(height: 8),
                  // Contraseña
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    onSaved: (v) => _password = v,
                  ),
                  const SizedBox(height: 16),
                  // Botón Crear
                  ElevatedButton(
                    onPressed: _createAccount,
                    child: const Text('Crear'),
                  ),
                  // Botón ir a Login
                  ElevatedButton(
                    onPressed: _goToLogin,
                    child: const Text('Iniciar sesión'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
    );
  }
}
