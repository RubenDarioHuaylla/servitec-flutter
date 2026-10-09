import 'package:flutter/material.dart';

import '../../models/technician_profile.dart';
import '../../models/rating_summary.dart';

import '../../services/technician_service.dart';
import '../../services/review_service.dart';

import '../../utils/category_utils.dart';

import '../../widgets/information_row.dart';
import '../../widgets/reviews_section.dart';

class PublicTechnicianProfileScreen extends StatefulWidget {
  final String technicianId;

  const PublicTechnicianProfileScreen({super.key, required this.technicianId});

  @override
  State<PublicTechnicianProfileScreen> createState() =>
      _PublicTechnicianProfileScreenState();
}

class _PublicTechnicianProfileScreenState
    extends State<PublicTechnicianProfileScreen> {
  final TechnicianService _technicianService = TechnicianService();

  final ReviewService _reviewService = ReviewService();

  TechnicianProfile? _technician;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadTechnician();
  }

  Future<void> _loadTechnician() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final technician = await _technicianService.getTechnicianProfileById(
        widget.technicianId,
      );

      if (!mounted) return;

      setState(() {
        _technician = technician;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil del técnico')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil del técnico')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'No se pudo cargar el perfil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(_errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadTechnician,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final technician = _technician;

    if (technician == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Perfil del técnico')),
        body: const Center(child: Text('No se encontró el técnico')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil del técnico')),
      body: RefreshIndicator(
        onRefresh: _loadTechnician,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(technician),

            const SizedBox(height: 24),

            _buildProfessionalInformation(technician),

            if (technician.description.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildDescription(technician.description),
            ],

            const SizedBox(height: 24),

            ReviewsSection(technicianId: technician.userId),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TechnicianProfile technician) {
    return Column(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundImage:
              technician.profileImageUrl != null &&
                  technician.profileImageUrl!.isNotEmpty
              ? NetworkImage(technician.profileImageUrl!)
              : null,

          child:
              technician.profileImageUrl == null ||
                  technician.profileImageUrl!.isEmpty
              ? const Icon(Icons.person, size: 64)
              : null,
        ),

        const SizedBox(height: 14),

        Text(
          technician.fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 6),

        Text(
          CategoryUtils.formatCategories(technician.categoryIds),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),

        const SizedBox(height: 12),

        StreamBuilder<RatingSummary>(
          stream: _reviewService.getTechnicianRatingSummary(technician.userId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('No se pudo cargar la calificación');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }

            final summary =
                snapshot.data ??
                const RatingSummary(average: 0, totalReviews: 0);

            if (summary.totalReviews == 0) {
              return const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, color: Colors.grey),
                  SizedBox(width: 6),
                  Text('Sin calificaciones'),
                ],
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber),

                const SizedBox(width: 5),

                Text(
                  summary.average.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 5),

                Text(
                  '(${summary.totalReviews} '
                  '${summary.totalReviews == 1 ? 'reseña' : 'reseñas'})',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 10),

        _buildVerificationStatus(technician.verificationStatus),
      ],
    );
  }

  Widget _buildProfessionalInformation(TechnicianProfile technician) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InformationRow(
              icon: Icons.work_history_outlined,
              label: 'Experiencia',
              value: '${technician.experienceYears} años',
            ),

            const Divider(),

            InformationRow(
              icon: Icons.location_on_outlined,
              label: 'Zona de atención',
              value: technician.location,
            ),

            const Divider(),

            InformationRow(
              icon: Icons.radar,
              label: 'Radio de atención',
              value: '${technician.serviceRadiusKm.toStringAsFixed(0)} km',
            ),

            const Divider(),

            InformationRow(
              icon: Icons.circle_outlined,
              label: 'Disponibilidad',
              value: technician.available ? 'Disponible' : 'No disponible',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(String description) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Descripción profesional',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationStatus(String status) {
    final bool approved = status == 'approved';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: approved
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            approved ? Icons.verified : Icons.schedule_outlined,
            size: 18,
            color: approved ? Colors.green : Colors.orange,
          ),

          const SizedBox(width: 5),

          Text(
            approved ? 'Técnico verificado' : 'Verificación pendiente',
            style: TextStyle(
              color: approved ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
