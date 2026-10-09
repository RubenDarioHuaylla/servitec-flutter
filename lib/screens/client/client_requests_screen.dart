import 'package:flutter/material.dart';

import '../../models/service_request.dart';
import '../../services/request_service.dart';
import '../quotes/received_quotes_screen.dart';

import '../../services/service_job_service.dart';
import '../services/service_in_progress_screen.dart';

import '../../utils/status_utils.dart';
import '../../widgets/request_card.dart';

import '../requests/request_detail_screen.dart';

class ClientRequestsScreen extends StatefulWidget {
  const ClientRequestsScreen({super.key});

  @override
  State<ClientRequestsScreen> createState() => _ClientRequestsScreenState();
}

class _ClientRequestsScreenState extends State<ClientRequestsScreen> {
  final RequestService _requestService = RequestService();
  final ServiceJobService _serviceJobService = ServiceJobService();

  Future<void> _openRequest(ServiceRequest request) async {
    if (request.status == 'receiving_quotes') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReceivedQuotesScreen(
            requestId: request.id,
            requestTitle: request.title,
          ),
        ),
      );

      return;
    }

    if (request.status == 'accepted' ||
        request.status == 'in_progress' ||
        request.status == 'awaiting_client_confirmation' ||
        request.status == 'completed') {
      try {
        final service = await _serviceJobService.getServiceByRequestId(
          request.id,
        );

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ServiceInProgressScreen(service: service, request: request),
          ),
        );
      } catch (error) {
        if (!mounted) return;

        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el servicio: $error')),
        );
      }

      return;
    }

    if (request.status == 'cancelled') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esta solicitud fue cancelada')),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Estado no reconocido: ${request.status}')),
    );
  } // open request

  bool _canDeleteRequest(ServiceRequest request) {
    return request.status == 'pending' || request.status == 'receiving_quotes';
  }

  Future<void> _confirmDeleteRequest(ServiceRequest request) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar solicitud'),
          content: const Text(
            '¿Seguro que deseas eliminar esta solicitud? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await _requestService.deleteRequest(request.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud eliminada correctamente')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar la solicitud: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis solicitudes'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<ServiceRequest>>(
        stream: _requestService.getCurrentClientRequests(),
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

                showStatus: true,

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RequestDetailScreen(request: request),
                    ),
                  );
                },

                buttonText: StatusUtils.getRequestButtonText(request.status),

                onViewDetails: () {
                  _openRequest(request);
                },

                onDelete: _canDeleteRequest(request)
                    ? () => _confirmDeleteRequest(request)
                    : null,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_outlined, size: 70, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Todavía no tienes solicitudes.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 6),
          Text(
            'Crea una solicitud para recibir cotizaciones.',
            textAlign: TextAlign.center,
          ),
        ],
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
