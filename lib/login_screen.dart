import 'package:flutter/material.dart';
// Importaremos el servicio nativo en el siguiente paso

class LoginTuyaScreen extends StatefulWidget {
  const LoginTuyaScreen({super.key});

  @override
  State<LoginTuyaScreen> createState() => _LoginTuyaScreenState();
}

class _LoginTuyaScreenState extends State<LoginTuyaScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    
    // Aquí llamaremos al puente nativo que conecta con el SDK de Tuya
    // Por ahora simulamos la espera. 
    // El SDK usará automáticamente tu AppKey crjtnxhcsjxwvpv5jhku
    await Future.delayed(const Duration(seconds: 2)); 
    
    setState(() => _isLoading = false);
    
    // Una vez configurado el servicio nativo, aquí recibiremos el éxito/error
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Conectando con Smart Life SDK...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cuenta Smart Life"), backgroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Correo electrónico", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Contraseña", border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  onPressed: _handleLogin,
                  child: const Text("Iniciar Sesión"),
                ),
          ],
        ),
      ),
    );
  }
}