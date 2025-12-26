import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class UploadService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<String> uploadVideo({
    required String localPath,
    required String sessionId,
  }) async {
    final file = File(localPath);

    final ref = _storage.ref().child(
      'uploads/$sessionId/raw.mp4',
    );

    final uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: 'video/mp4'),
    );

    final snapshot = await uploadTask.whenComplete(() {});

    return await snapshot.ref.getDownloadURL();
  }
}
