import 'package:flutter/material.dart';

import '../../models/service_request.dart';
import '../../services/request_service.dart';
import '../../widgets/request_card.dart';

import '../requests/request_detail_screen.dart';

class NearbyRequestsScreen extends StatefulWidget {
  const NearbyRequestsScreen({super.key});

  @override
  State<NearbyRequestsScreen> createState() => _NearbyRequestsScreenState();
}

class _NearbyRequestsScreenState extends State<NearbyRequestsScreen> {
  final RequestService _requestService = RequestService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes disponibles'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<ServiceRequest>>(
        stream: _requestService.getRequestsForCurrentTechnician(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 100),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];

              return RequestCard(
                request: request,
                onViewDetails: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RequestDetailScreen(request: request, canQuote: true),
                    ),
                  );
                },
              );
            },
          );
        },
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
            Icon(Icons.assignment_outlined, size: 70, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No hay solicitudes disponibles.',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'Aquí aparecerán las solicitudes compatibles '
              'con tus especialidades.',
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
              'No se pudieron cargar las solicitudes',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
