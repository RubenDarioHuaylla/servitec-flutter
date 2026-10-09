import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> registerClient({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String location,
  }) async {
    UserCredential? credential;

    try {
      // 1. Crear la cuenta en Firebase Authentication.
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('Firebase no devolvió el usuario creado');
      }

      // 2. Crear el perfil en Cloud Firestore.
      await _firestore.collection('users').doc(user.uid).set({
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'role': 'client',
        'location': location.trim(),
        'profileImageUrl': null,
        'accountStatus': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': null,
      });

      return credential;
    } catch (error) {
      // Evita dejar una cuenta sin perfil si falla Firestore.
      if (credential?.user != null) {
        await credential!.user!.delete();
      }

      rethrow;
    }
  }

  Future<UserCredential> registerTechnician({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String location,
    required String description,
    required int experienceYears,
    required List<String> categoryIds,
    required double serviceRadiusKm,
    double? latitude,
    double? longitude,
  }) async {
    UserCredential? credential;

    try {
      // 1. Crear la cuenta en Firebase Authentication.
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('Firebase no devolvió el usuario creado');
      }

      // 2. Preparar los documentos que se guardarán.
      final userReference = _firestore.collection('users').doc(user.uid);

      final technicianReference = _firestore
          .collection('technician_profiles')
          .doc(user.uid);

      // 3. Guardar ambos documentos en una sola operación.
      final batch = _firestore.batch();

      batch.set(userReference, {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'role': 'technician',
        'location': location.trim(),
        'profileImageUrl': null,
        'accountStatus': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': null,
      });

      batch.set(technicianReference, {
        'description': description.trim(),
        'experienceYears': experienceYears,
        'categoryIds': categoryIds,
        'latitude': latitude,
        'longitude': longitude,
        'serviceRadiusKm': serviceRadiusKm,
        'available': true,
        'verificationStatus': 'verified', //pending, verified, rejected
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': null,
      });

      await batch.commit();

      return credential;
    } catch (error) {
      // Si falla Firestore, elimina la cuenta creada en Authentication.
      if (credential?.user != null) {
        await credential!.user!.delete();
      }

      rethrow;
    }
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<String> getCurrentUserRole() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No hay una sesión activa');
    }

    final snapshot = await _firestore.collection('users').doc(user.uid).get();

    if (!snapshot.exists) {
      throw Exception('No se encontró el perfil del usuario');
    }

    final data = snapshot.data();

    final role = data?['role'];

    if (role is! String || role.isEmpty) {
      throw Exception('El usuario no tiene un rol válido');
    }

    return role;
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> logout() {
    return _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
