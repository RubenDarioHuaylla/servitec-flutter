import 'package:flutter/material.dart';

import '../../models/service_request.dart';

import '../quotes/create_quote_screen.dart';

import '../../utils/category_utils.dart';
import '../../utils/status_utils.dart';
import '../../widgets/information_row.dart';
import '../../widgets/request_images.dart';

class RequestDetailScreen extends StatelessWidget {
  final ServiceRequest request;
  final bool canQuote;

  const RequestDetailScreen({
    super.key,
    required this.request,
    this.canQuote = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de la solicitud')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            InformationRow(
              icon: Icons.category_outlined,
              label: 'Categoría',
              value: CategoryUtils.getCategoryName(request.categoryId),
            ),

            InformationRow(
              icon: Icons.location_on_outlined,
              label: 'Ubicación',
              value: request.address,
            ),

            InformationRow(
              icon: Icons.radar,
              label: 'Radio de búsqueda',
              value: '${request.searchRadiusKm.toStringAsFixed(0)} km',
            ),

            InformationRow(
              icon: Icons.info_outline,
              label: 'Estado',
              value: StatusUtils.getRequestStatusText(request.status),
            ),

            const SizedBox(height: 24),

            const Text(
              'Descripción del problema',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              request.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 24),

            RequestImages(imageUrls: request.imageUrls),

            const SizedBox(height: 32),

            if (canQuote && request.status == 'receiving_quotes') ...[
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateQuoteScreen(request: request),
                      ),
                    );
                  },
                  icon: const Icon(Icons.request_quote_outlined),
                  label: const Text('Enviar cotización'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
