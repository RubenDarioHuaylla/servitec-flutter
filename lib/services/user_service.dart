import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AppUser> getCurrentUserProfile() async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception('No hay una sesión activa');
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (!snapshot.exists || snapshot.data() == null) {
      throw Exception('No se encontró el perfil del usuario');
    }

    return AppUser.fromFirestore(snapshot.id, snapshot.data()!);
  }

  Future<void> updateCurrentUserProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String location,
    String? profileImageUrl,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No hay una sesión activa');
    }

    await _firestore.collection('users').doc(user.uid).update({
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'phone': phone.trim(),
      'location': location.trim(),
      'profileImageUrl': profileImageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> getUserName(String userId) async {
    final document = await _firestore.collection('users').doc(userId).get();

    if (!document.exists) {
      return 'Usuario';
    }

    final data = document.data();

    if (data == null) {
      return 'Usuario';
    }

    final firstName = data['firstName'] as String? ?? '';
    final lastName = data['lastName'] as String? ?? '';

    return '$firstName $lastName'.trim();
  }
}
