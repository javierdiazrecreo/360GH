import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class UploadService {
  static Future<String> uploadVideo({
    required String localPath,
    required String code,
  }) async {
    final file = File(localPath);
    if (!file.existsSync()) {
      throw Exception('El archivo de video no existe');
    }

    final ref = FirebaseStorage.instance
        .ref()
        .child('raw')
        .child('$code.mp4');

    final task = await ref.putFile(
      file,
      SettableMetadata(contentType: 'video/mp4'),
    );

    if (task.state != TaskState.success) {
      throw Exception('Upload fallido: ${task.state}');
    }

    return await ref.getDownloadURL();
  }
}
