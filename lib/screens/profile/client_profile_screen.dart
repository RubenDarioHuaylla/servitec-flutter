import 'package:flutter/material.dart';

import '../auth/change_password_screen.dart';
import '../auth/login_screen.dart';
import 'edit_client_profile_screen.dart';

import '../../services/user_service.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  AppUser? _user;
  bool _isLoading = true;
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
      final user = await _userService.getCurrentUserProfile();

      if (!mounted) return;

      setState(() {
        _user = user;
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
                    SnackBar(
                      content: Text('No se pudo cerrar la sesión: $error'),
                    ),
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

  Widget _buildInformationTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mi perfil')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mi perfil')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 56),
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

    final user = _user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No se encontró el perfil')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 52,
            backgroundImage:
                user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                ? NetworkImage(user.profileImageUrl!)
                : null,
            child: user.profileImageUrl == null || user.profileImageUrl!.isEmpty
                ? const Icon(Icons.person, size: 60)
                : null,
          ),

          const SizedBox(height: 16),

          Text(
            user.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          const Text('Cliente', textAlign: TextAlign.center),

          const SizedBox(height: 24),

          Card(
            child: Column(
              children: [
                _buildInformationTile(
                  icon: Icons.email_outlined,
                  title: 'Correo electrónico',
                  value: user.email,
                ),
                const Divider(height: 1),
                _buildInformationTile(
                  icon: Icons.phone_outlined,
                  title: 'Teléfono',
                  value: user.phone,
                ),
                const Divider(height: 1),
                _buildInformationTile(
                  icon: Icons.location_on_outlined,
                  title: 'Ubicación',
                  value: user.location,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Editar perfil'),
                  subtitle: const Text('Actualiza tus datos personales'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    if (_user == null) return;

                    final wasUpdated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditClientProfileScreen(
                          firstName: _user!.firstName,
                          lastName: _user!.lastName,
                          phone: _user!.phone,
                          location: _user!.location,
                          profileImageUrl: _user!.profileImageUrl,
                        ),
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
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Cambiar contraseña'),
                  subtitle: const Text('Actualiza la contraseña de tu cuenta'),
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
              ],
            ),
          ),

          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: _showLogoutDialog,
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
