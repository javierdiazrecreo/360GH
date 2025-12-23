import 'package:flutter/services.dart';

class TuyaNativeService {
  // Definimos el canal de comunicación con el nombre de tu paquete
  static const platform = MethodChannel('com.party360.app/tuya');

  static Future<bool> login(String email, String password) async {
    try {
      // Llamamos a la función "login" en el MainActivity.kt
      final bool result = await platform.invokeMethod('login', {
        'email': email,
        'password': password,
      });
      return result;
    } on PlatformException catch (e) {
      print("Error desde el SDK de Tuya: ${e.message}");
      return false;
    }
  }
}