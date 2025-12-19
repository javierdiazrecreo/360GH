import 'package:http/http.dart' as http;

class MotorService {
  Future<void> startMotor(String url) async {
    await http.get(Uri.parse(url));
  }
}
