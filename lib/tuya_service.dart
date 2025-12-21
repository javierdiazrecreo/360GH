import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'secrets.dart';

class TuyaService {
  static String? _accessToken;
  static int _expireTime = 0;

  static Future<String> _getAccessToken() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_accessToken != null && now < _expireTime) {
      return _accessToken!;
    }

    final t = now.toString();
    const method = "GET";
    const path = "/v1.0/token?grant_type=1";

    final stringToSign = "$method\n\n\n$path";
    final signStr = TuyaSecrets.accessId + t + stringToSign;

    final hmac = Hmac(sha256, utf8.encode(TuyaSecrets.accessSecret));
    final sign = hmac.convert(utf8.encode(signStr)).toString().toUpperCase();

    final response = await http.get(
      Uri.parse("https://openapi.tuyaus.com$path"),
      headers: {
        "client_id": TuyaSecrets.accessId,
        "sign": sign,
        "t": t,
        "sign_method": "HMAC-SHA256",
      },
    );

    final data = jsonDecode(response.body);
    if (!data["success"]) {
      throw Exception("Error token Tuya: ${response.body}");
    }

    _accessToken = data["result"]["access_token"];
    _expireTime = now + (data["result"]["expire_time"] * 1000);

    return _accessToken!;
  }

  static Future<void> setMotor(bool encender) async {
    final token = await _getAccessToken();
    final t = DateTime.now().millisecondsSinceEpoch.toString();
    const method = "POST";
    final path = "/v1.0/devices/${TuyaSecrets.deviceId}/commands";

    final body = jsonEncode({
      "commands": [
        {"code": "switch_1", "value": encender}
      ]
    });

    final bodyHash = sha256.convert(utf8.encode(body)).toString();
    final stringToSign = "$method\n$bodyHash\n\n$path";
    final signStr = TuyaSecrets.accessId + t + stringToSign;

    final hmac = Hmac(sha256, utf8.encode(TuyaSecrets.accessSecret));
    final sign = hmac.convert(utf8.encode(signStr)).toString().toUpperCase();

    final response = await http.post(
      Uri.parse("https://openapi.tuyaus.com$path"),
      headers: {
        "client_id": TuyaSecrets.accessId,
        "access_token": token, // 🔥 ESTO FALTABA
        "sign": sign,
        "t": t,
        "sign_method": "HMAC-SHA256",
        "Content-Type": "application/json",
      },
      body: body,
    );

    print("Tuya motor ${encender ? "ON" : "OFF"} → ${response.body}");
  }
}
