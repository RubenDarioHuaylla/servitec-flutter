import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceJob {
  final String id;
  final String requestId;
  final String clientId;
  final String technicianId;
  final String requestTitle;
  final String acceptedQuoteId;

  final double agreedPrice;
  final double agreedDuration;
  final String durationUnit;
  final String status;

  final DateTime? createdAt;
  final DateTime? startedAt;
  final DateTime? technicianFinishedAt;
  final DateTime? clientConfirmedAt;

  const ServiceJob({
    required this.id,
    required this.requestId,
    required this.clientId,
    required this.technicianId,
    required this.requestTitle,
    required this.acceptedQuoteId,
    required this.agreedPrice,
    required this.agreedDuration,
    required this.durationUnit,
    required this.status,
    required this.createdAt,
    required this.startedAt,
    required this.technicianFinishedAt,
    required this.clientConfirmedAt,
  });

  factory ServiceJob.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw Exception('El servicio no contiene información');
    }

    return ServiceJob(
      id: document.id,
      requestId: data['requestId'] as String? ?? '',
      requestTitle: data['requestTitle'] as String? ?? 'Servicio',
      clientId: data['clientId'] as String? ?? '',
      technicianId: data['technicianId'] as String? ?? '',
      acceptedQuoteId: data['acceptedQuoteId'] as String? ?? '',
      agreedPrice: (data['agreedPrice'] as num?)?.toDouble() ?? 0,
      agreedDuration:
          (data['agreedDuration'] as num?)?.toDouble() ?? 0,
      durationUnit: data['durationUnit'] as String? ?? 'hours',
      status: data['status'] as String? ?? 'pending_start',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      technicianFinishedAt:
          (data['technicianFinishedAt'] as Timestamp?)?.toDate(),
      clientConfirmedAt:
          (data['clientConfirmedAt'] as Timestamp?)?.toDate(),
    );
  }

  String get formattedDuration {
    final value = agreedDuration % 1 == 0
        ? agreedDuration.toInt().toString()
        : agreedDuration.toStringAsFixed(1);

    final unit = durationUnit == 'days'
        ? agreedDuration == 1
            ? 'día'
            : 'días'
        : agreedDuration == 1
            ? 'hora'
            : 'horas';

    return '$value $unit';
  }
}