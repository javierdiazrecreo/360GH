import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'secrets.dart';

class TuyaService {
  static String? _accessToken;
  static String? _refreshToken;
  static String? _uid; // ID del usuario logueado
  static String? _deviceId; // Se llenará dinámicamente
  static const String _switchCode = "switch_1"; 

  // Endpoint de América (Western America)
  static const String _endpoint = "https://openapi.tuyaus.com";

  /// ======================================================
  /// 1. CANJEAR CÓDIGO POR TOKEN (LOGIN COMERCIAL)
  /// ======================================================
  static Future<bool> loginWithCode(String code) async {
    final t = DateTime.now().millisecondsSinceEpoch.toString();
    final path = "/v1.0/token?grant_type=2&code=$code";

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
        return true;
      }
      return false;
    } catch (e) {
      print("Error en login: $e");
      return false;
    }
  }

  /// ======================================================
  /// 2. LISTAR DISPOSITIVOS (PARA EL SELECTOR)
  /// ======================================================
  static Future<List<Map<String, dynamic>>> getDeviceList() async {
    if (_accessToken == null || _uid == null) return [];

    final t = DateTime.now().millisecondsSinceEpoch.toString();
    final path = "/v1.0/users/$_uid/devices";
    final sign = _calculateSign(
      method: "GET", 
      path: path, 
      t: t, 
      token: _accessToken!,
    );

    try {
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
          "category": d["category"]
        }).toList();
      }
    } catch (e) {
      print("Error obteniendo lista: $e");
    }
    return [];
  }

  /// ======================================================
  /// 3. SELECCIÓN Y CONTROL DEL MOTOR
  /// ======================================================
  static void selectMotor(String id) {
    _deviceId = id;
    print("📌 Motor seleccionado: $_deviceId");
  }

  static Future<void> setMotor(bool encender) async {
    if (_accessToken == null || _deviceId == null) {
      print("⚠️ Error: Falta token o deviceId");
      return;
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

    try {
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
    } catch (e) {
      print("Error controlando motor: $e");
    }
  }

  /// ======================================================
  /// GENERADOR DE FIRMA (ALGORITMO OFICIAL TUYA)
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
    
    // El orden para App SDK es: AppKey + Token (si hay) + t + StringToSign
    final signStr = TuyaSecrets.appKey + token + t + stringToSign;

    final hmac = Hmac(sha256, utf8.encode(TuyaSecrets.appSecret));
    return hmac.convert(utf8.encode(signStr)).toString().toUpperCase();
  }

} // <--- ESTA LLAVE DEBE CERRAR TODA LA CLASE