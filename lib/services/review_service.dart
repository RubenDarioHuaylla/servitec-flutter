import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/service_job.dart';
import '../models/service_review.dart';
import '../models/rating_summary.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createReview({
    required ServiceJob service,
    required int rating,
    required String comment,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No hay una sesión activa');
    }

    if (user.uid != service.clientId) {
      throw Exception('Solo el cliente puede calificar el servicio');
    }

    if (service.status != 'completed') {
      throw Exception('El servicio todavía no está completado');
    }

    if (rating < 1 || rating > 5) {
      throw Exception('La calificación debe estar entre 1 y 5');
    }

    final reviewReference = _firestore.collection('reviews').doc(service.id);

    final existingReview = await reviewReference.get();

    if (existingReview.exists) {
      throw Exception('Ya calificaste este servicio');
    }

    await reviewReference.set({
      'serviceId': service.id,
      'requestId': service.requestId,
      'clientId': service.clientId,
      'technicianId': service.technicianId,
      'rating': rating,
      'comment': comment.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<ServiceReview?> getReviewByServiceId(String serviceId) async {
    final document = await _firestore
        .collection('reviews')
        .doc(serviceId)
        .get();

    if (!document.exists) {
      return null;
    }

    return ServiceReview.fromFirestore(document);
  }

  Stream<List<ServiceReview>> getTechnicianReviews(String technicianId) {
    return _firestore
        .collection('reviews')
        .where('technicianId', isEqualTo: technicianId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(ServiceReview.fromFirestore).toList();
        });
  }

  Stream<RatingSummary> getTechnicianRatingSummary(String technicianId) {
    return _firestore
        .collection('reviews')
        .where('technicianId', isEqualTo: technicianId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return const RatingSummary(average: 0, totalReviews: 0);
          }

          double total = 0;

          for (final document in snapshot.docs) {
            final data = document.data();

            final rating = (data['rating'] as num?)?.toDouble() ?? 0;

            total += rating;
          }

          final average = total / snapshot.docs.length;

          return RatingSummary(
            average: average,
            totalReviews: snapshot.docs.length,
          );
        });
  }
}
