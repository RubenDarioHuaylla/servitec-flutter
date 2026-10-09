import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRequest {
  final String id;
  final String clientId;
  final String categoryId;
  final String title;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final double searchRadiusKm;
  final List<String> imageUrls;
  final String status;
  final DateTime? createdAt;

  const ServiceRequest({
    required this.id,
    required this.clientId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.searchRadiusKm,
    required this.imageUrls,
    required this.status,
    required this.createdAt,
  });

  factory ServiceRequest.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw Exception(
        'La solicitud ${document.id} no contiene información',
      );
    }

    final timestamp = data['createdAt'] as Timestamp?;

    return ServiceRequest(
      id: document.id,
      clientId: data['clientId'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      address: data['address'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      searchRadiusKm:
          (data['searchRadiusKm'] as num?)?.toDouble() ?? 0,
      imageUrls: List<String>.from(
        data['imageUrls'] as List? ?? const [],
      ),
      status: data['status'] as String? ?? 'receiving_quotes',
      createdAt: timestamp?.toDate(),
    );
  }
}