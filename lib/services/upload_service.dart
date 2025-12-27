import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class UploadService {
  static Future<String> uploadVideo({
    required String localPath,
    required String sessionId,
  }) async {
    final file = File(localPath);

    if (!file.existsSync()) {
      throw Exception('El archivo de video no existe');
    }

    final storage = FirebaseStorage.instanceFor(
      bucket: 'party-5baed.appspot.com', // ✅ ESTE ES EL CORRECTO
    );

    final ref = storage
        .ref()
        .child('sessions')
        .child(sessionId)
        .child('input.mp4');

    await ref.putFile(
      file,
      SettableMetadata(contentType: 'video/mp4'),
    );

    return await ref.getDownloadURL();
  }
}
