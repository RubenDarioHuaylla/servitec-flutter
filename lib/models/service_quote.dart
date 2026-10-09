import 'package:cloud_firestore/cloud_firestore.dart';


class ServiceQuote {
  final String id;
  final String requestId;
  final String technicianId;

  final double price;
  final double estimatedDuration;
  final String durationUnit;

  final String message;
  final String status;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ServiceQuote({
    required this.id,
    required this.requestId,
    required this.technicianId,
    required this.price,
    required this.estimatedDuration,
    required this.durationUnit,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceQuote.fromFirestore({
    required String requestId,
    required DocumentSnapshot<Map<String, dynamic>> document,
  }) {
    final data = document.data();

    if (data == null) {
      throw Exception('La cotización ${document.id} no contiene información');
    }

    return ServiceQuote(
      id: document.id,
      requestId: requestId,
      technicianId: data['technicianId'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      estimatedDuration: (data['estimatedDuration'] as num?)?.toDouble() ?? 0,
      durationUnit: data['durationUnit'] as String? ?? 'hours',
      message: data['message'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  String get formattedDuration {
    final duration = estimatedDuration % 1 == 0
        ? estimatedDuration.toInt().toString()
        : estimatedDuration.toStringAsFixed(1);

    final unit = durationUnit == 'days'
        ? estimatedDuration == 1
              ? 'día'
              : 'días'
        : estimatedDuration == 1
        ? 'hora'
        : 'horas';

    return '$duration $unit';
  }

}
