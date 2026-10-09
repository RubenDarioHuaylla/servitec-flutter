import 'package:flutter/material.dart';

import '../../models/service_quote.dart';
import '../../services/quote_service.dart';
import '../../widgets/quote_card.dart';

import '../profile/public_technician_profile_screen.dart';

import '../../models/technician_profile.dart';
import '../../models/rating_summary.dart';

import '../../services/technician_service.dart';
import '../../services/review_service.dart';

class ReceivedQuotesScreen extends StatefulWidget {
  final String requestId;
  final String requestTitle;

  const ReceivedQuotesScreen({
    super.key,
    required this.requestId,
    required this.requestTitle,
  });

  @override
  State<ReceivedQuotesScreen> createState() => _ReceivedQuotesScreenState();
}

class _ReceivedQuotesScreenState extends State<ReceivedQuotesScreen> {
  final QuoteService _quoteService = QuoteService();

  final TechnicianService _technicianService = TechnicianService();

  final ReviewService _reviewService = ReviewService();

  late final Stream<List<ServiceQuote>> _quotesStream;

  String? _acceptingQuoteId;

  @override
  void initState() {
    super.initState();

    _quotesStream = _quoteService.getReceivedQuotes(
      requestId: widget.requestId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cotizaciones recibidas')),
      body: Column(
        children: [
          _buildRequestHeader(),
          Expanded(
            child: StreamBuilder<List<ServiceQuote>>(
              stream: _quotesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final quotes = snapshot.data ?? [];

                if (quotes.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  itemCount: quotes.length,
                  itemBuilder: (context, index) {
                    final quote = quotes[index];

                    return _buildQuoteCard(quote);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(ServiceQuote quote) {
    return FutureBuilder<TechnicianProfile>(
      future: _technicianService.getTechnicianProfileById(quote.technicianId),
      builder: (context, technicianSnapshot) {
        if (technicianSnapshot.hasError) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No se pudo cargar la información del técnico: '
                '${technicianSnapshot.error}',
              ),
            ),
          );
        }

        if (technicianSnapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final technician = technicianSnapshot.data;

        if (technician == null) {
          return const Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No se encontró el técnico'),
            ),
          );
        }

        return StreamBuilder<RatingSummary>(
          stream: _reviewService.getTechnicianRatingSummary(quote.technicianId),
          builder: (context, ratingSnapshot) {
            final rating =
                ratingSnapshot.data ??
                const RatingSummary(average: 0, totalReviews: 0);

            return QuoteCard(
              quote: quote,

              technicianName: technician.fullName,

              ratingAverage: rating.average,

              totalReviews: rating.totalReviews,

              onViewProfile: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PublicTechnicianProfileScreen(
                      technicianId: quote.technicianId,
                    ),
                  ),
                );
              },

              onAccept: quote.status == 'pending' && _acceptingQuoteId == null
                  ? () {
                      _acceptQuote(quote);
                    }
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _buildRequestHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Solicitud',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            widget.requestTitle,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.request_quote_outlined, size: 72, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Todavía no recibiste cotizaciones',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Las cotizaciones enviadas por los técnicos '
              'aparecerán automáticamente aquí.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'No se pudieron cargar las cotizaciones',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptQuote(ServiceQuote quote) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Aceptar cotización'),
          content: Text(
            '¿Deseas aceptar esta cotización por '
            'S/ ${quote.price.toStringAsFixed(2)}?\n\n'
            'Las demás cotizaciones serán rechazadas.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      final serviceId = await _quoteService.acceptQuote(quote: quote);

      if (!mounted) return;

      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text('Cotización aceptada correctamente')),
      );

      Navigator.pop(this.context, serviceId);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('No se pudo aceptar la cotización: $error')),
      );
    }
  }
}
