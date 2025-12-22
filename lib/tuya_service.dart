import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'secrets.dart';

class TuyaService {
  static String? _accessToken;
  static String? _refreshToken;
  static String? _uid; // ID del usuario logueado
  static String? _deviceId; // Se llenará dinámicamente al detectar el motor
  static String _switchCode = "switch_1"; // Se detectará automáticamente

  // Usamos el endpoint de América
  static const String _endpoint = "https://openapi.tuyaus.com";

  /// ======================================================
  /// 1. CANJEAR CÓDIGO POR TOKEN (LOGIN COMERCIAL)
  /// ======================================================
  static Future<bool> loginWithCode(String code) async {
    final t = DateTime.now().millisecondsSinceEpoch.toString();
    // Para el login inicial, el path es este:
    final path = "/v1.0/token?grant_type=2&code=$code";

    // En el login inicial no hay accessToken en la firma
    final sign = _calculateSign(method: "GET", path: path, t: t);

    try {
      final response = await http.get(
        Uri.parse("$_endpoint$path"),
        headers: {
          "client_id": TuyaSecrets.appKey,
          "sign": sign,
          "t": t,
          "sign_method": "HMAC-SHA256",
        },
      );

      final data = jsonDecode(response.body);
      if (data["success"] == true) {
        _accessToken = data["result"]["access_token"];
        _refreshToken = data["result"]["refresh_token"];
        _uid = data["result"]["uid"];
        
        // Una vez logueados, buscamos el motor automáticamente
        await _discoverMotor();
        return true;
      }
      return false;
    } catch (e) {
      print("Error en login: $e");
      return false;
    }
  }

  /// ======================================================
  /// 2. DESCUBRIMIENTO AUTOMÁTICO DEL MOTOR
  /// ======================================================
  static Future<void> _discoverMotor() async {
    if (_accessToken == null || _uid == null) return;

    final t = DateTime.now().millisecondsSinceEpoch.toString();
    final path = "/v1.0/users/$_uid/devices";
    final sign = _calculateSign(method: "GET", path: path, t: t, token: _accessToken!);

    final response = await http.get(
      Uri.parse("$_endpoint$path"),
      headers: {
        "client_id": TuyaSecrets.appKey,
        "access_token": _accessToken!,
        "sign": sign,
        "t": t,
        "sign_method": "HMAC-SHA256",
      },
    );

    final data = jsonDecode(response.body);
    if (data["success"] == true && (data["result"] as List).isNotEmpty) {
      // Tomamos el primer dispositivo que parezca un motor/switch
      final dispositivo = data["result"][0];
      _deviceId = dispositivo["id"];
      print("✅ Motor detectado: ${dispositivo["name"]} (ID: $_deviceId)");
      
      // Aquí podrías mapear el comando si fuera distinto a switch_1
    }
  }

  /// ======================================================
  /// 3. CONTROL DEL MOTOR (ON / OFF)
  /// ======================================================
  static Future<void> setMotor(bool encender) async {
    if (_accessToken == null || _deviceId == null) {
      throw Exception("No hay motor vinculado o sesión iniciada");
    }

    final t = DateTime.now().millisecondsSinceEpoch.toString();
    final path = "/v1.0/devices/$_deviceId/commands";
    final body = jsonEncode({
      "commands": [
        {"code": _switchCode, "value": encender}
      ]
    });

    final sign = _calculateSign(
      method: "POST",
      path: path,
      t: t,
      body: body,
      token: _accessToken!,
    );

    await http.post(
      Uri.parse("$_endpoint$path"),
      headers: {
        "client_id": TuyaSecrets.appKey,
        "access_token": _accessToken!,
        "sign": sign,
        "t": t,
        "sign_method": "HMAC-SHA256",
        "Content-Type": "application/json",
      },
      body: body,
    );
  }

  /// ======================================================
  /// GENERADOR DE FIRMA (Adaptado para App SDK)
  /// ======================================================
  static String _calculateSign({
    required String method,
    required String path,
    required String t,
    String body = "",
    String token = "",
  }) {
    final bodyHash = sha256.convert(utf8.encode(body)).toString();
    final stringToSign = "$method\n$bodyHash\n\n$path";
    
    // IMPORTANTE: Para el App SDK se usa el appKey y appSecret
    final signStr = TuyaSecrets.appKey + token + t + stringToSign;

    final hmac = Hmac(sha256, utf8.encode(TuyaSecrets.appSecret));
    return hmac.convert(utf8.encode(signStr)).toString().toUpperCase();
  }
}

// Añade esto a tu clase TuyaService en tuya_service.dart

static Future<List<Map<String, dynamic>>> getDeviceList() async {
  if (_accessToken == null || _uid == null) return [];

  final t = DateTime.now().millisecondsSinceEpoch.toString();
  final path = "/v1.0/users/$_uid/devices";
  final sign = _calculateSign(method: "GET", path: path, t: t, token: _accessToken!);

  final response = await http.get(
    Uri.parse("$_endpoint$path"),
    headers: {
      "client_id": TuyaSecrets.appKey,
      "access_token": _accessToken!,
      "sign": sign,
      "t": t,
      "sign_method": "HMAC-SHA256",
    },
  );

  final data = jsonDecode(response.body);
  if (data["success"] == true) {
    List devices = data["result"];
    return devices.map((d) => {
      "id": d["id"],
      "name": d["name"],
      "online": d["online"],
      "category": d["category"] // 'kg' suele ser interruptor
    }).toList();
  }
  return [];
}

// Función para fijar el motor elegido
static void selectMotor(String id) {
  _deviceId = id;
  print("📌 Motor seleccionado para esta sesión: $_deviceId");
}