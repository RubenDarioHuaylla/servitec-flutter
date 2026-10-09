import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/service_quote.dart';

class QuoteService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createQuote({
    required String requestId,
    required double price,
    required double estimatedDuration,
    required String durationUnit,
    required String message,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No hay una sesión activa');
    }

    final technicianSnapshot = await _firestore
        .collection('technician_profiles')
        .doc(user.uid)
        .get();

    if (!technicianSnapshot.exists) {
      throw Exception('No se encontró el perfil técnico');
    }

    final requestReference = _firestore.collection('requests').doc(requestId);

    final requestSnapshot = await requestReference.get();

    if (!requestSnapshot.exists) {
      throw Exception('La solicitud ya no existe');
    }

    final requestData = requestSnapshot.data();

    if (requestData?['status'] != 'receiving_quotes') {
      throw Exception('Esta solicitud ya no acepta cotizaciones');
    }

    final quoteReference = requestReference.collection('quotes').doc(user.uid);

    final existingQuote = await quoteReference.get();

    if (existingQuote.exists) {
      throw Exception('Ya enviaste una cotización para esta solicitud');
    }

    await quoteReference.set({
      'technicianId': user.uid,
      'price': price,
      'estimatedDuration': estimatedDuration,
      'durationUnit': durationUnit,
      'message': message.trim(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': null,
    });

    return quoteReference.id;
  }

  Stream<List<ServiceQuote>> getReceivedQuotes({required String requestId}) {
    return _firestore
        .collection('requests')
        .doc(requestId)
        .collection('quotes')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((document) {
            return ServiceQuote.fromFirestore(
              requestId: requestId,
              document: document,
            );
          }).toList();
        });
  }

  Future<String> acceptQuote({required ServiceQuote quote}) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('No hay una sesión activa');
    }

    final requestReference = _firestore
        .collection('requests')
        .doc(quote.requestId);

    final acceptedQuoteReference = requestReference
        .collection('quotes')
        .doc(quote.id);

    final serviceReference = _firestore.collection('services').doc();

    final conversationReference = _firestore.collection('conversations').doc();

    // Primero obtenemos todas las cotizaciones para conocer
    // cuáles deben rechazarse.
    final quotesSnapshot = await requestReference.collection('quotes').get();

    await _firestore.runTransaction((transaction) async {
      final requestSnapshot = await transaction.get(requestReference);

      final selectedQuoteSnapshot = await transaction.get(
        acceptedQuoteReference,
      );

      if (!requestSnapshot.exists) {
        throw Exception('La solicitud ya no existe');
      }

      if (!selectedQuoteSnapshot.exists) {
        throw Exception('La cotización ya no existe');
      }

      final requestData = requestSnapshot.data();
      final selectedQuoteData = selectedQuoteSnapshot.data();

      if (requestData == null || selectedQuoteData == null) {
        throw Exception('No se pudo obtener la información necesaria');
      }

      if (requestData['clientId'] != user.uid) {
        throw Exception('No tienes permiso para aceptar esta cotización');
      }

      if (requestData['status'] != 'receiving_quotes') {
        throw Exception('Esta solicitud ya no acepta cotizaciones');
      }

      if (selectedQuoteData['status'] != 'pending') {
        throw Exception('Esta cotización ya no está pendiente');
      }

      final technicianId = selectedQuoteData['technicianId'] as String?;

      if (technicianId == null || technicianId.isEmpty) {
        throw Exception('La cotización no tiene un técnico válido');
      }

      final price = (selectedQuoteData['price'] as num?)?.toDouble() ?? 0;

      final duration =
          (selectedQuoteData['estimatedDuration'] as num?)?.toDouble() ?? 0;

      final durationUnit =
          selectedQuoteData['durationUnit'] as String? ?? 'hours';

      final requestTitle = requestData['title'] as String? ?? 'Servicio';

      // Actualizar la solicitud.
      transaction.update(requestReference, {
        'status': 'accepted',
        'acceptedQuoteId': quote.id,
        'acceptedTechnicianId': technicianId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Aceptar la cotización elegida y rechazar las demás.
      for (final quoteDocument in quotesSnapshot.docs) {
        transaction.update(quoteDocument.reference, {
          'status': quoteDocument.id == quote.id ? 'accepted' : 'rejected',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Crear el servicio.
      transaction.set(serviceReference, {
        'requestId': quote.requestId,
        'clientId': user.uid,
        'technicianId': technicianId,
        'requestTitle': requestTitle,
        'acceptedQuoteId': quote.id,
        'agreedPrice': price,
        'agreedDuration': duration,
        'durationUnit': durationUnit,
        'status': 'pending_start',
        'startedAt': null,
        'technicianFinishedAt': null,
        'clientConfirmedAt': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': null,
      });

      // Crear la conversación.
      transaction.set(conversationReference, {
        'serviceId': serviceReference.id,
        'requestId': quote.requestId,
        'clientId': user.uid,
        'technicianId': technicianId,
        'participantIds': [user.uid, technicianId],
        'lastMessage': null,
        'lastMessageAt': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    return serviceReference.id;
  }
}
