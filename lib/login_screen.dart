import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'secrets.dart';

class LoginTuyaScreen extends StatefulWidget {
  const LoginTuyaScreen({super.key});

  @override
  State<LoginTuyaScreen> createState() => _LoginTuyaScreenState();
}

class _LoginTuyaScreenState extends State<LoginTuyaScreen> {
  // Esta es la URL oficial de Tuya para autorizar apps de terceros
  final String authUrl = 
    "https://api.tuya.com/v1.0/gateway/oauth2/auth?client_id=${TuyaSecrets.appKey}&response_type=code&redirect_uri=com.javierdiazrecreo.app360://auth&scope=ay,0";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Iniciar Sesión Smart Life"),
        backgroundColor: Colors.black,
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(authUrl)),
        onLoadStop: (controller, url) async {
          final urlString = url.toString();
          
          // Detectamos cuando Tuya nos devuelve el código de autorización
          if (urlString.contains("code=")) {
            final uri = Uri.parse(urlString);
            final code = uri.queryParameters['code'];
            
            if (code != null) {
              // Cerramos la pantalla devolviendo el código al main.dart
              Navigator.pop(context, code);
            }
          }
        },
      ),
    );
  }
}