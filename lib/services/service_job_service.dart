import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/service_job.dart';

class ServiceJobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ServiceJob> getServiceByRequestId(String requestId) async {
    final snapshot = await _firestore
        .collection('services')
        .where('requestId', isEqualTo: requestId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('No se encontró el servicio asociado a esta solicitud');
    }

    return ServiceJob.fromFirestore(snapshot.docs.first);
  }

  Stream<List<ServiceJob>> getCurrentTechnicianJobs() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No hay una sesión activa');
    }

    return _firestore
        .collection('services')
        .where('technicianId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(ServiceJob.fromFirestore).toList();
        });
  }

  Future<ServiceJob> getServiceById(String serviceId) async {
    final document = await _firestore
        .collection('services')
        .doc(serviceId)
        .get();

    if (!document.exists) {
      throw Exception('No se encontró el servicio');
    }

    return ServiceJob.fromFirestore(document);
  }

  Future<void> startService({
    required String serviceId,
    required String requestId,
  }) async {
    final batch = _firestore.batch();

    final serviceReference = _firestore.collection('services').doc(serviceId);

    final requestReference = _firestore.collection('requests').doc(requestId);

    batch.update(serviceReference, {
      'status': 'in_progress',
      'startedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.update(requestReference, {
      'status': 'in_progress',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> finishServiceByTechnician({
    required String serviceId,
    required String requestId,
  }) async {
    final batch = _firestore.batch();

    final serviceReference = _firestore.collection('services').doc(serviceId);

    final requestReference = _firestore.collection('requests').doc(requestId);

    batch.update(serviceReference, {
      'status': 'awaiting_client_confirmation',
      'technicianFinishedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.update(requestReference, {
      'status': 'awaiting_client_confirmation',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> confirmServiceCompletion({
    required String serviceId,
    required String requestId,
  }) async {
    final batch = _firestore.batch();

    final serviceReference = _firestore.collection('services').doc(serviceId);

    final requestReference = _firestore.collection('requests').doc(requestId);

    batch.update(serviceReference, {
      'status': 'completed',
      'clientConfirmedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.update(requestReference, {
      'status': 'completed',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
