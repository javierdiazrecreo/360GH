import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class UploadService {
  static Future<void> upload({
    required String path,
    required String code,
  }) async {
    final ref = FirebaseStorage.instance.ref('raw/$code.mp4');
    await ref.putFile(File(path));
  }
}
