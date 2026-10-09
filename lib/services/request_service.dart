import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/service_request.dart';
import 'package:geolocator/geolocator.dart';

class RequestService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createRequest({
    required String categoryId,
    required String title,
    required String description,
    required String address,
    required double latitude,
    required double longitude,
    required double searchRadiusKm,
    List<String> imageUrls = const [],
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No hay una sesión activa');
    }

    final document = await _firestore.collection('requests').add({
      'clientId': user.uid,
      'categoryId': categoryId,
      'title': title.trim(),
      'description': description.trim(),
      'address': address.trim(),
      'latitude': latitude,
      'longitude': longitude,
      'searchRadiusKm': searchRadiusKm,
      'imageUrls': imageUrls,
      'status': 'receiving_quotes',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': null,
    });

    return document.id;
  }

  Future<void> updateRequestImages({
    required String requestId,
    required List<String> imageUrls,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No hay una sesión activa');
    }

    await _firestore.collection('requests').doc(requestId).update({
      'imageUrls': imageUrls,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ServiceRequest>> getCurrentClientRequests() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No hay una sesión activa');
    }

    return _firestore
        .collection('requests')
        .where('clientId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((document) {
            return ServiceRequest.fromFirestore(document);
          }).toList();
        });
  }

  Stream<List<ServiceRequest>> getRequestsForCurrentTechnician() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No hay una sesión activa');
    }

    return _firestore
        .collection('technician_profiles')
        .doc(user.uid)
        .snapshots()
        .asyncExpand((technicianSnapshot) {
          final technicianData = technicianSnapshot.data();

          if (technicianData == null) {
            throw Exception('No se encontró el perfil técnico');
          }

          final available = technicianData['available'] as bool? ?? false;

          final categoryIds = List<String>.from(
            technicianData['categoryIds'] as List? ?? const [],
          );

          final latitude = (technicianData['latitude'] as num?)?.toDouble();

          final longitude = (technicianData['longitude'] as num?)?.toDouble();

          final serviceRadiusKm =
              (technicianData['serviceRadiusKm'] as num?)?.toDouble() ?? 0;

          if (!available ||
              categoryIds.isEmpty ||
              latitude == null ||
              longitude == null) {
            return Stream.value(<ServiceRequest>[]);
          }

          return _firestore
              .collection('requests')
              .where('categoryId', whereIn: categoryIds)
              .where('status', isEqualTo: 'receiving_quotes')
              .orderBy('createdAt', descending: true)
              .snapshots()
              .map((snapshot) {
                final requests = snapshot.docs
                    .map(ServiceRequest.fromFirestore)
                    .where((request) {
                      final distanceInMeters = Geolocator.distanceBetween(
                        latitude,
                        longitude,
                        request.latitude,
                        request.longitude,
                      );

                      final distanceKm = distanceInMeters / 1000;

                      final withinTechnicianRadius =
                          distanceKm <= serviceRadiusKm;

                      final withinClientRadius =
                          distanceKm <= request.searchRadiusKm;

                      return withinTechnicianRadius && withinClientRadius;
                    })
                    .toList();

                return requests;
              });
        });
  }

  Future<ServiceRequest> getRequestById(String requestId) async {
    final document = await _firestore
        .collection('requests')
        .doc(requestId)
        .get();

    if (!document.exists) {
      throw Exception('No se encontró la solicitud');
    }

    return ServiceRequest.fromFirestore(document);
  }

  Future<void> deleteRequest(String requestId) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No hay una sesión activa');
    }

    await _firestore.collection('requests').doc(requestId).delete();
  }
}
