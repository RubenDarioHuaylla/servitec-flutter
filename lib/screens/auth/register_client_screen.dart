import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';

import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../client/client_main_screen.dart';

class RegisterClientScreen extends StatefulWidget {
  const RegisterClientScreen({super.key});

  @override
  State<RegisterClientScreen> createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends State<RegisterClientScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController lastNameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool acceptTerms = false;

  Future<void> _registerClient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe aceptar los términos y condiciones'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.registerClient(
        firstName: nameController.text,
        lastName: lastNameController.text,
        email: emailController.text,
        phone: phoneController.text,
        password: passwordController.text,
        location: 'Cusco',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta registrada correctamente')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ClientMainScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      String message = 'No se pudo crear la cuenta';

      switch (error.code) {
        case 'email-already-in-use':
          message = 'Este correo ya está registrado';
          break;

        case 'invalid-email':
          message = 'El correo electrónico no es válido';
          break;

        case 'weak-password':
          message = 'La contraseña debe tener al menos 6 caracteres';
          break;

        case 'operation-not-allowed':
          message = 'El registro por correo no está habilitado en Firebase';
          break;

        case 'network-request-failed':
          message = 'No se pudo conectar con Firebase';
          break;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ocurrió un error: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirme su contraseña';
    }

    if (value != passwordController.text) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de cliente')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: Icon(Icons.person_add_alt_1, size: 72)),

                const SizedBox(height: 12),

                const Center(
                  child: Text(
                    'Crea tu cuenta de cliente',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 8),

                const Center(
                  child: Text(
                    'Solicita servicios de técnicos en tu zona',
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),

                CustomTextField(
                  label: 'Nombres',
                  hintText: 'Ingrese sus nombres',
                  icon: Icons.person_outline,
                  controller: nameController,
                  validator: (value) {
                    return Validators.validateRequiredField(value, 'sus nombres');
                  },
                ),

                CustomTextField(
                  label: 'Apellidos',
                  hintText: 'Ingrese sus apellidos',
                  icon: Icons.person_outline,
                  controller: lastNameController,
                  validator: (value) {
                    return Validators.validateRequiredField(value, 'sus apellidos');
                  },
                ),

                CustomTextField(
                  label: 'Correo electrónico',
                  hintText: 'Ingrese su correo',
                  icon: Icons.email_outlined,
                  controller: emailController,
                  validator: Validators.validateEmail,
                ),

                CustomTextField(
                  label: 'Teléfono',
                  hintText: 'Ingrese 9 dígitos',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  controller: phoneController,
                  validator: Validators.validatePhone,
                ),

                CustomTextField(
                  label: 'Contraseña',
                  hintText: 'Ingrese su contraseña',
                  icon: Icons.lock_outline,
                  controller: passwordController,
                  validator: Validators.validatePassword,
                  obscureText: true,
                ),

                CustomTextField(
                  label: 'Confirmar contraseña',
                  hintText: 'Repita su contraseña',
                  icon: Icons.lock_outline,
                  controller: confirmPasswordController,
                  validator: _validateConfirmPassword,
                  obscureText: true,
                ),

                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: acceptTerms,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Acepto los términos y condiciones'),
                  onChanged: (value) {
                    setState(() {
                      acceptTerms = value ?? false;
                    });
                  },
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registerClient,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Registrarme como cliente'),
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
