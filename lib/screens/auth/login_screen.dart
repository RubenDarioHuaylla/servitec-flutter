import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/validators.dart';
import '../client/client_main_screen.dart';
import 'register_role_screen.dart';
import '../technician/technician_main_screen.dart';
import 'forgot_password_screen.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final role = await _authService.getCurrentUserRole();

      if (!mounted) return;

      if (role == 'client') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ClientMainScreen()),
          (route) => false,
        );
      } else if (role == 'technician') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const TechnicianMainScreen()),
          (route) => false,
        );
      } else {
        await _authService.logout();

        throw Exception('El usuario no tiene un rol válido');
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      String message = 'No se pudo iniciar sesión';

      switch (error.code) {
        case 'invalid-credential':
          message = 'Correo o contraseña incorrectos';
          break;
        case 'invalid-email':
          message = 'El correo no es válido';
          break;
        case 'user-disabled':
          message = 'La cuenta está deshabilitada';
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
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.vertical -
                  40,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildForm(),
                  const SizedBox(height: 30),
                  _buildRegister(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          "SERVITEC",
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          "Encuentra técnicos de confianza",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            label: "Correo electrónico",
            hintText: "Ingresa tu correo electrónico",
            icon: Icons.email,
            validator: Validators.validateEmail,
            controller: emailController,
          ),
          CustomTextField(
            label: "Contraseña",
            hintText: "Ingresa tu contraseña",
            icon: Icons.lock,
            validator: Validators.validatePassword,
            controller: passwordController,
            obscureText: true,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen(),
                  ),
                );
              },
              child: const Text('¿Olvidaste tu contraseña?'),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Iniciar sesión'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegister() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("¿No tienes cuenta?"),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterRoleScreen()),
            );
          },
          child: const Text('Crear una cuenta'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
