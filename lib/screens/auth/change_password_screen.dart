import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirme la nueva contraseña';
    }

    if (value != newPasswordController.text) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (currentPasswordController.text == newPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La nueva contraseña debe ser diferente')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró el usuario autenticado')),
      );
      return;
    }

    try {
      // 1. Comprobar la contraseña actual
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);

      // 2. Cambiar a la nueva contraseña
      await user.updatePassword(newPasswordController.text);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada correctamente')),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      String message;

      switch (error.code) {
        case 'wrong-password':
        case 'invalid-credential':
          message = 'La contraseña actual es incorrecta';
          break;

        case 'weak-password':
          message = 'La nueva contraseña es demasiado débil';
          break;

        case 'requires-recent-login':
          message = 'Vuelve a iniciar sesión e inténtalo nuevamente';
          break;

        default:
          message = 'No se pudo cambiar la contraseña';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocurrió un error al cambiar la contraseña'),
        ),
      );
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cambiar contraseña')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.lock_reset, size: 72),

                const SizedBox(height: 16),

                const Text(
                  'Actualiza tu contraseña',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Ingresa tu contraseña actual y define una nueva.',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                CustomTextField(
                  label: 'Contraseña actual',
                  hintText: 'Ingrese su contraseña actual',
                  icon: Icons.lock_outline,
                  controller: currentPasswordController,
                  validator: Validators.validatePassword,
                  obscureText: true,
                ),

                CustomTextField(
                  label: 'Nueva contraseña',
                  hintText: 'Ingrese una nueva contraseña',
                  icon: Icons.lock_reset_outlined,
                  controller: newPasswordController,
                  validator: Validators.validatePassword,
                  obscureText: true,
                ),

                CustomTextField(
                  label: 'Confirmar contraseña',
                  hintText: 'Repita la nueva contraseña',
                  icon: Icons.lock_outline,
                  controller: confirmPasswordController,
                  validator: _validateConfirmPassword,
                  obscureText: true,
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _changePassword,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Guardar nueva contraseña'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
