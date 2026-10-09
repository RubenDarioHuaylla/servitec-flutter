import 'package:flutter/material.dart';

import '../../services/request_service.dart';
import '../services/service_in_progress_screen.dart';

import '../../models/service_job.dart';
import '../../services/service_job_service.dart';
import '../../widgets/service_job_card.dart';

class TechnicianJobsScreen extends StatefulWidget {
  const TechnicianJobsScreen({super.key});

  @override
  State<TechnicianJobsScreen> createState() => _TechnicianJobsScreenState();
}

class _TechnicianJobsScreenState extends State<TechnicianJobsScreen> {
  final ServiceJobService _serviceJobService = ServiceJobService();
  final RequestService _requestService = RequestService();

  late final Stream<List<ServiceJob>> _jobsStream;

  @override
  void initState() {
    super.initState();

    _jobsStream = _serviceJobService.getCurrentTechnicianJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis trabajos'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<ServiceJob>>(
        stream: _jobsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final jobs = snapshot.data ?? [];

          if (jobs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 100),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];

              return ServiceJobCard(
                job: job,
                onTap: () {
                  _openJob(job);
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
            Icon(Icons.work_outline, size: 72, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tienes trabajos asignados',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Cuando un cliente acepte una de tus '
              'cotizaciones, el trabajo aparecerá aquí.',
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
              'No se pudieron cargar los trabajos',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
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

      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el servicio: $error')),
      );
    }
  }
}
