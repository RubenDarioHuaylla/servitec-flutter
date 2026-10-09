import 'package:flutter/material.dart';

import '../../models/technician_profile.dart';
import '../../services/auth_service.dart';
import '../../services/technician_service.dart';

import '../auth/change_password_screen.dart';
import '../auth/login_screen.dart';
import 'edit_technician_profile_screen.dart';
import 'technician_reviews_screen.dart';

import '../../utils/category_utils.dart';
import '../../utils/status_utils.dart';

import '../../widgets/information_row.dart';
import '../../widgets/reviews_section.dart';
import '../../widgets/technician_rating.dart';

class TechnicianProfileScreen extends StatefulWidget {
  const TechnicianProfileScreen({super.key});

  @override
  State<TechnicianProfileScreen> createState() =>
      _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends State<TechnicianProfileScreen> {
  final TechnicianService _technicianService = TechnicianService();

  final AuthService _authService = AuthService();

  TechnicianProfile? _technician;

  bool _isLoading = true;
  bool _isUpdatingAvailability = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final technician = await _technicianService.getCurrentTechnicianProfile();

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

  Future<void> _changeAvailability(bool value) async {
    final technician = _technician;

    if (technician == null || _isUpdatingAvailability) {
      return;
    }

    setState(() {
      _isUpdatingAvailability = true;
    });

    try {
      await _technicianService.updateAvailability(value);

      if (!mounted) return;

      await _loadProfile();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'Ahora estás disponible' : 'Ahora no estás disponible',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cambiar la disponibilidad: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingAvailability = false;
        });
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await _authService.logout();

                  if (!mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                } catch (error) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('No se pudo cerrar sesión: $error')),
                  );
                }
              },
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Mi perfil'),
          automaticallyImplyLeading: false,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mi perfil'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 60),
                const SizedBox(height: 16),
                Text(_errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadProfile,
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
      return const Scaffold(
        body: Center(child: Text('No se encontró el perfil técnico')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CircleAvatar(
              radius: 52,
              backgroundImage: technician.profileImageUrl != null
                  ? NetworkImage(technician.profileImageUrl!)
                  : null,
              child: technician.profileImageUrl == null
                  ? const Icon(Icons.person, size: 60)
                  : null,
            ),

            const SizedBox(height: 16),

            Text(
              technician.fullName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              _formatCategories(technician.categoryIds),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, color: Colors.grey.shade700),
            ),

            const SizedBox(height: 14),

            TechnicianRating(technicianId: technician.userId),

            const SizedBox(height: 8),

            Text(
              StatusUtils.getVerificationStatusText(
                technician.verificationStatus,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: StatusUtils.getVerificationStatusColor(
                  technician.verificationStatus,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    InformationRow(
                      icon: Icons.email_outlined,
                      label: 'Correo',
                      value: technician.email,
                    ),
                    const Divider(),
                    InformationRow(
                      icon: Icons.phone_outlined,
                      label: 'Teléfono',
                      value: technician.phone,
                    ),
                    const Divider(),
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
                      value:
                          '${technician.serviceRadiusKm.toStringAsFixed(0)} km',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: SwitchListTile(
                title: const Text(
                  'Disponible para trabajar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  technician.available
                      ? 'Puedes recibir nuevas solicitudes'
                      : 'No recibirás nuevas solicitudes',
                ),
                value: technician.available,
                onChanged: _isUpdatingAvailability ? null : _changeAvailability,
              ),
            ),

            if (technician.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Descripción profesional',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        technician.description,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ReviewsSection(
                technicianId: technician.userId,
                onViewAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TechnicianReviewsScreen(
                        technicianId: technician.userId,
                        technicianName: technician.fullName,
                      ),
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final wasUpdated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditTechnicianProfileScreen(technician: technician),
                    ),
                  );

                  if (!mounted || wasUpdated != true) {
                    return;
                  }

                  await _loadProfile();

                  if (!mounted) return;

                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text('Perfil actualizado correctamente'),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar perfil'),
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Cambiar contraseña'),
                    subtitle: const Text(
                      'Actualiza la contraseña de tu cuenta',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Cerrar sesión'),
                    onTap: _showLogoutDialog,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCategories(List<String> categoryIds) {
    return CategoryUtils.formatCategories(categoryIds);
  }
}
