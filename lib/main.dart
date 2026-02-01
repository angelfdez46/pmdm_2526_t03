import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pmdm_2526_t03/my_app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

