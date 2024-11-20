import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final FirebaseStorage _instance = FirebaseStorage.instanceFor(
      bucket: 'findyourpet-b0280.firebasestorage.app');

  static Reference get root => _instance.ref();

  static Reference child(String path) => root.child(path);

  static Future<String> uploadFile({
    required String path,
    required dynamic data,
    String contentType = 'application/octet-stream',
    Map<String, String>? metadata,
  }) async {
    final ref = child(path);
    final SettableMetadata settableMetadata = SettableMetadata(
      contentType: contentType,
      customMetadata: metadata,
    );

    late final UploadTask task;
    if (data is String) {
      task = ref.putString(data, metadata: settableMetadata);
    } else {
      task = ref.putData(data, settableMetadata);
    }

    final snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }
}
