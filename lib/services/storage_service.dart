import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<String>> uploadRequestImages({
    required String requestId,
    required List<File> images,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No hay una sesión activa');
    }

    final List<String> imageUrls = [];

    for (int i = 0; i < images.length; i++) {
      final file = images[i];

      final reference = _storage
          .ref()
          .child('requests')
          .child(user.uid)
          .child(requestId)
          .child('image_$i.jpg');

      final uploadTask = await reference.putFile(file);

      final downloadUrl = await uploadTask.ref.getDownloadURL();

      imageUrls.add(downloadUrl);
    }

    return imageUrls;
  }

  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No hay una sesión activa');
    }

    final reference = _storage
        .ref()
        .child('profile_images')
        .child(userId)
        .child('profile.jpg');

    final uploadTask = await reference.putFile(imageFile);

    return await uploadTask.ref.getDownloadURL();
  }
}
