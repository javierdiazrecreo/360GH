import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'secrets.dart';

class TuyaService {
  static String? _accessToken;
  static int _expireTime = 0;

  static const String _endpoint = "https://openapi.tuyaeu.com";

  /// =========================
  /// SIGN GENERATOR (OFICIAL)
  /// =========================
  static String _sign({
    required String method,
    required String path,
    required String t,
    String body = "",
    String accessToken = "",
  }) {
    final bodyHash = sha256.convert(utf8.encode(body)).toString();

    final stringToSign = [
      method,
      bodyHash,
      "",
      path,
    ].join("\n");

    final signStr =
        TuyaSecrets.accessId + accessToken + t + stringToSign;

    final hmac =
        Hmac(sha256, utf8.encode(TuyaSecrets.accessSecret));
    return hmac
        .convert(utf8.encode(signStr))
        .toString()
        .toUpperCase();
  }

  /// =========================
  /// ACCESS TOKEN
  /// =========================
  static Future<String> _getAccessToken() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    if (_accessToken != null && now < _expireTime) {
      return _accessToken!;
    }

    final t = now.toString();
    const method = "GET";
    const path = "/v1.0/token?grant_type=1";

    final sign = _sign(
      method: method,
      path: path,
      t: t,
    );

    final response = await http.get(
      Uri.parse("$_endpoint$path"),
      headers: {
        "client_id": TuyaSecrets.accessId,
        "sign": sign,
        "t": t,
        "sign_method": "HMAC-SHA256",
      },
    );

    print("🔑 TUYA TOKEN RESPONSE → ${response.body}");

    final data = jsonDecode(response.body);

    if (data["success"] != true) {
      throw Exception("TUYA TOKEN ERROR: ${response.body}");
    }

    _accessToken = data["result"]["access_token"];
    _expireTime =
        now + ((data["result"]["expire_time"] as num).toInt() * 1000);

    return _accessToken!;
  }

  /// =========================
  /// MOTOR ON / OFF
  /// =========================
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

    final sign = _sign(
      method: method,
      path: path,
      t: t,
      body: body,
      accessToken: token,
    );

    print("⚡ TUYA CMD → ${encender ? "ON" : "OFF"}");
    print("📦 BODY → $body");

    final response = await http.post(
      Uri.parse("$_endpoint$path"),
      headers: {
        "client_id": TuyaSecrets.accessId,
        "access_token": token,
        "sign": sign,
        "t": t,
        "sign_method": "HMAC-SHA256",
        "Content-Type": "application/json",
      },
      body: body,
    );

    print("📥 TUYA RESPONSE → ${response.body}");
  }
}
