import 'dart:math';

class CodeService {
  static const _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static String generate({int length = 8}) {
    final rand = Random.secure();
    return List.generate(
      length,
      (_) => _chars[rand.nextInt(_chars.length)],
    ).join();
  }
}
