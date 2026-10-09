import 'package:flutter/material.dart';

import '../../models/service_request.dart';
import '../../models/service_job.dart';

import '../../services/request_service.dart';
import '../../services/service_job_service.dart';
import '../../widgets/service_job_card.dart';
import '../services/service_in_progress_screen.dart';

class TechnicianHomeContent extends StatefulWidget {
  const TechnicianHomeContent({super.key});

  @override
  State<TechnicianHomeContent> createState() => _TechnicianHomeContentState();
}

class _TechnicianHomeContentState extends State<TechnicianHomeContent> {
  final RequestService _requestService = RequestService();

  final ServiceJobService _serviceJobService = ServiceJobService();

  late final Stream<List<ServiceRequest>> _requestsStream;

  late final Stream<List<ServiceJob>> _jobsStream;

  @override
  void initState() {
    super.initState();

    _requestsStream = _requestService.getRequestsForCurrentTechnician();

    _jobsStream = _serviceJobService.getCurrentTechnicianJobs();
  }

  Future<void> _openJob(ServiceJob job) async {
    try {
      final request = await _requestService.getRequestById(job.requestId);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ServiceInProgressScreen(service: job, request: request),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el servicio: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ServiTec'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hola', style: TextStyle(fontSize: 16)),

            const SizedBox(height: 4),

            Text(
              'Resumen de tu actividad',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            _buildRequestsAndJobsSummary(),

            const SizedBox(height: 30),

            Text(
              'Trabajo actual',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _buildCurrentJob(),

            const SizedBox(height: 30),

            Text(
              'Solicitudes cercanas',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _buildNearbyRequestsSummary(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsAndJobsSummary() {
    return Row(
      children: [
        Expanded(
          child: StreamBuilder<List<ServiceRequest>>(
            stream: _requestsStream,
            builder: (context, snapshot) {
              final requests = snapshot.data ?? [];

              return _buildSummaryCard(
                icon: Icons.assignment_outlined,
                value: '${requests.length}',
                label: 'Solicitudes cercanas',
              );
            },
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: StreamBuilder<List<ServiceJob>>(
            stream: _jobsStream,
            builder: (context, snapshot) {
              final jobs = snapshot.data ?? [];

              final activeJobs = jobs.where((job) {
                return job.status == 'pending_start' ||
                    job.status == 'in_progress' ||
                    job.status == 'awaiting_client_confirmation';
              }).toList();

              return _buildSummaryCard(
                icon: Icons.work_outline,
                value: '${activeJobs.length}',
                label: 'Trabajos activos',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),

            const SizedBox(height: 10),

            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentJob() {
    return StreamBuilder<List<ServiceJob>>(
      stream: _jobsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No se pudo cargar el trabajo actual.'),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final jobs = snapshot.data ?? [];

        final activeJobs = jobs.where((job) {
          return job.status == 'pending_start' ||
              job.status == 'in_progress' ||
              job.status == 'awaiting_client_confirmation';
        }).toList();

        if (activeJobs.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(Icons.work_off_outlined, color: Colors.grey.shade600),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text('No tienes trabajos activos por el momento.'),
                  ),
                ],
              ),
            ),
          );
        }

        final job = activeJobs.first;

        return ServiceJobCard(
          job: job,
          onTap: () {
            _openJob(job);
          },
        );
      },
    );
  }

  Widget _buildNearbyRequestsSummary() {
    return StreamBuilder<List<ServiceRequest>>(
      stream: _requestsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No se pudieron cargar las solicitudes cercanas.'),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(
                    Icons.location_searching_outlined,
                    color: Colors.grey.shade600,
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      'No hay solicitudes compatibles cerca de tu ubicación.',
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final request = requests.first;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined, size: 20),

                    const SizedBox(width: 8),

                    Expanded(child: Text(request.address)),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  request.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
