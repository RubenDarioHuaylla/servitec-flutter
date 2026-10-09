import 'package:flutter/material.dart';

import 'register_client_screen.dart';
import 'register_technician_screen.dart';


class RegisterRoleScreen extends StatelessWidget {
  const RegisterRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_add_alt_1, size: 80),
            const SizedBox(height: 20),

            const Text(
              '¿Cómo deseas registrarte?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterClientScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.person_outline),
                label: const Text('Registrarme como cliente'),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterTechnicianScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.build_outlined),
                label: const Text('Registrarme como técnico'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
