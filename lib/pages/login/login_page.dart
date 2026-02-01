import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/snackbar.dart';
import '../../../utils/keyboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String? _email;
  String? _password;
  User? _user;

  @override
  void initState() {
    super.initState();
  }


  Future<void> _login() async {
    if (_formKey.currentState?.validate() != true) return;
    _formKey.currentState!.save();
    hideKeyboard();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email!,
        password: _password!,
      );

      if (mounted) context.goNamed('home');

    } on FirebaseAuthException catch (e) {
      String message = switch (e.code) {
        'user-not-found' => 'No se encontró el usuario.',
        'wrong-password' => 'Contraseña incorrecta.',
        'invalid-email' => 'Correo inválido.',
        'user-disabled' => 'Usuario deshabilitado.',
        _ => e.message ?? 'Error de autenticación.',
      };

      if (mounted) showSnackBar(context, message);

    } catch (e) {

      if (mounted) {
        showSnackBar(context, 'Error inesperado: $e');
      }
    }
  }


  void _goToRegister() {
    context.pushNamed('register');
  }


  Future<void> _continueAnonymously() async {
    if (_user != null) {
      showSnackBar(context, 'Ya hay usuario autenticado');
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      debugPrint('userCredential: $userCredential');

      if (mounted) context.goNamed('home');

    } on FirebaseAuthException catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error login anónimo: ${e.message}');
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Error inesperado: $e');
      }
    }
  }



  Future<void> _resetPassword() async {
    if (_formKey.currentState?.validate() != true) return;
    _formKey.currentState!.save();
    hideKeyboard();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email!);
      if (mounted) showSnackBar(context, 'Correo enviado para restablecer contraseña.');
    } on FirebaseAuthException catch (e) {
      if (mounted) showSnackBar(context, e.message ?? 'Error al enviar correo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Correo electrónico'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v?.isEmpty ?? true) ? 'Obligatorio' : null,
                    onSaved: (v) => _email = v,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    onSaved: (v) => _password = v,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('Iniciar sesión'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _resetPassword,
                    child: const Text('No recuerdo la contraseña'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _goToRegister,
                    child: const Text('Crear cuenta'),
                  ),
                ],
              ),
            ),
                const SizedBox(height: 16),
                ElevatedButton(
                style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[150],
              ),
                  onPressed: _continueAnonymously,
                  child: const Text('Continuar sin iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
