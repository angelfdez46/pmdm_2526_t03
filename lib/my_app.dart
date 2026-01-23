import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/login_page.dart';
import 'pages/register/register_page.dart';
import 'pages/home_page.dart';




class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
      initialLocation: '/login',
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          name: 'home',
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          name: 'login',
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          name: 'register',
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: _router,
    );
  }
}
