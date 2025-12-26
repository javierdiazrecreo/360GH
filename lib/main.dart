import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'camara_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    debugPrint('🔥 Firebase inicializado');
  } catch (e, st) {
    debugPrint('❌ Error inicializando Firebase: $e');
    debugPrint('$st');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CamaraScreen(),
    );
  }
}
