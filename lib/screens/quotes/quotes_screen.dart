import 'package:flutter/material.dart';

class QuotesScreen extends StatelessWidget {
  final String requestId;

  const QuotesScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cotizaciones')),
      body: Center(child: Text('Cotizaciones de la solicitud: $requestId')),
    );
  }
}
