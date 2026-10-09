import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/technician_profile.dart';

class TechnicianService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<TechnicianProfile> getCurrentTechnicianProfile() async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception('No hay una sesión activa');
    }

    final userSnapshot = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    final technicianSnapshot = await _firestore
        .collection('technician_profiles')
        .doc(firebaseUser.uid)
        .get();

    final userData = userSnapshot.data();
    final technicianData = technicianSnapshot.data();

    if (!userSnapshot.exists || userData == null) {
      throw Exception('No se encontró el usuario');
    }

    if (!technicianSnapshot.exists || technicianData == null) {
      throw Exception('No se encontró el perfil técnico');
    }

    return TechnicianProfile(
      userId: firebaseUser.uid,
      firstName: userData['firstName'] as String? ?? '',
      lastName: userData['lastName'] as String? ?? '',
      email: userData['email'] as String? ?? '',
      phone: userData['phone'] as String? ?? '',
      location: userData['location'] as String? ?? '',
      profileImageUrl: userData['profileImageUrl'] as String?,
      description: technicianData['description'] as String? ?? '',
      categoryIds: List<String>.from(
        technicianData['categoryIds'] as List? ?? const [],
      ),
      experienceYears:
          (technicianData['experienceYears'] as num?)?.toInt() ?? 0,
      serviceRadiusKm:
          (technicianData['serviceRadiusKm'] as num?)?.toDouble() ?? 0,
      available: technicianData['available'] as bool? ?? false,
      verificationStatus:
          technicianData['verificationStatus'] as String? ??
          'approved', //'pending',
      latitude: (technicianData['latitude'] as num?)?.toDouble(),
      longitude: (technicianData['longitude'] as num?)?.toDouble(),
    );
  }

  Future<void> updateAvailability(bool available) async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception('No hay una sesión activa');
    }

    await _firestore
        .collection('technician_profiles')
        .doc(firebaseUser.uid)
        .update({
          'available': available,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> updateCurrentTechnicianProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String location,
    required String description,
    required int experienceYears,
    required List<String> categoryIds,
    required double serviceRadiusKm,
    required bool available,
    String? profileImageUrl,
    double? latitude,
    double? longitude,
  }) async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception('No hay una sesión activa');
    }

    final batch = _firestore.batch();

    final userReference = _firestore.collection('users').doc(firebaseUser.uid);

    final technicianReference = _firestore
        .collection('technician_profiles')
        .doc(firebaseUser.uid);

    batch.update(userReference, {
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'phone': phone.trim(),
      'location': location.trim(),
      'profileImageUrl': profileImageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.update(technicianReference, {
      'description': description.trim(),
      'experienceYears': experienceYears,
      'categoryIds': categoryIds,
      'serviceRadiusKm': serviceRadiusKm,
      'available': available,
      'latitude': latitude,
      'longitude': longitude,
      'verificationStatus': 'verified', //pending, verified, rejected
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<TechnicianProfile> getTechnicianProfileById(
    String technicianId,
  ) async {
    final userSnapshot = await _firestore
        .collection('users')
        .doc(technicianId)
        .get();

    final technicianSnapshot = await _firestore
        .collection('technician_profiles')
        .doc(technicianId)
        .get();

    final userData = userSnapshot.data();
    final technicianData = technicianSnapshot.data();

    if (!userSnapshot.exists || userData == null) {
      throw Exception('No se encontró el usuario');
    }

    if (!technicianSnapshot.exists || technicianData == null) {
      throw Exception('No se encontró el perfil técnico');
    }

    return TechnicianProfile(
      userId: technicianId,
      firstName: userData['firstName'] as String? ?? '',
      lastName: userData['lastName'] as String? ?? '',
      email: userData['email'] as String? ?? '',
      phone: userData['phone'] as String? ?? '',
      location: userData['location'] as String? ?? '',
      profileImageUrl: userData['profileImageUrl'] as String?,

      description: technicianData['description'] as String? ?? '',

      categoryIds: List<String>.from(
        technicianData['categoryIds'] as List? ?? const [],
      ),

      experienceYears:
          (technicianData['experienceYears'] as num?)?.toInt() ?? 0,

      serviceRadiusKm:
          (technicianData['serviceRadiusKm'] as num?)?.toDouble() ?? 0,

      available: technicianData['available'] as bool? ?? false,

      verificationStatus:
          technicianData['verificationStatus'] as String? ?? 'pending',

      latitude: (technicianData['latitude'] as num?)?.toDouble(),

      longitude: (technicianData['longitude'] as num?)?.toDouble(),
    );
  }

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      throw Exception('No hay una sesión activa');
    }

    await _firestore
        .collection('technician_profiles')
        .doc(firebaseUser.uid)
        .update({
          'latitude': latitude,
          'longitude': longitude,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }
}
