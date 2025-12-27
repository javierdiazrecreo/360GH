import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadService {
  static bool _initialized = false;

  static Future<void> _ensureFirebase() async {
    if (_initialized) return;
    await Firebase.initializeApp();
    _initialized = true;
  }

  static Future<String> uploadVideo({
    required String localPath,
    required String sessionId,
  }) async {
    await _ensureFirebase();

    final file = File(localPath);
    if (!file.existsSync()) {
      throw Exception('El archivo de video no existe');
    }

    final storage = FirebaseStorage.instanceFor(
      bucket: 'party-5baed.appspot.com',
    );

    final ref = storage
        .ref()
        .child('sessions')
        .child(sessionId)
        .child('input.mp4');

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
