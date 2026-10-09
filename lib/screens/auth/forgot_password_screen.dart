import 'package:flutter/material.dart';

import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final AuthService _authService = AuthService();

  Future<void> _sendRecoveryInstructions() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(emailController.text.trim());

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(Icons.mark_email_read_outlined, size: 48),
            title: const Text('Revisa tu correo'),
            content: Text(
              'Se enviaron instrucciones de recuperación a '
              '${emailController.text.trim()}.',
              textAlign: TextAlign.center,
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                },
                child: const Text('Volver al inicio de sesión'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo enviar el correo de recuperación'),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),

                const Icon(Icons.lock_reset, size: 80),

                const SizedBox(height: 20),

                const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Ingresa tu correo electrónico y te enviaremos '
                  'instrucciones para restablecerla.',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                CustomTextField(
                  label: 'Correo electrónico',
                  hintText: 'Ingrese su correo',
                  icon: Icons.email_outlined,
                  controller: emailController,
                  validator: Validators.validateEmail,
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _sendRecoveryInstructions,
                    icon: const Icon(Icons.send_outlined),
                    label: const Text('Enviar instrucciones'),
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
