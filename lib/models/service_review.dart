import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceReview {
  final String id;
  final String serviceId;
  final String requestId;
  final String clientId;
  final String technicianId;
  final int rating;
  final String comment;
  final DateTime? createdAt;

  const ServiceReview({
    required this.id,
    required this.serviceId,
    required this.requestId,
    required this.clientId,
    required this.technicianId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ServiceReview.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw Exception(
        'La reseña ${document.id} no contiene información',
      );
    }

    return ServiceReview(
      id: document.id,
      serviceId: data['serviceId'] as String? ?? '',
      requestId: data['requestId'] as String? ?? '',
      clientId: data['clientId'] as String? ?? '',
      technicianId: data['technicianId'] as String? ?? '',
      rating: (data['rating'] as num?)?.toInt() ?? 0,
      comment: data['comment'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}