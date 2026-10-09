import 'package:flutter/material.dart';

import '../models/service_request.dart';
import '../utils/category_utils.dart';
import '../utils/status_utils.dart';
import '../utils/date_utils.dart';

class RequestCard extends StatelessWidget {
  final ServiceRequest request;

  final VoidCallback onViewDetails;

  final VoidCallback? onDelete;

  final VoidCallback? onTap;

  final bool showStatus;

  final String? buttonText;

  const RequestCard({
    super.key,
    required this.request,
    required this.onViewDetails,
    this.onDelete,
    this.onTap,
    this.showStatus = false,
    this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = StatusUtils.getRequestStatusColor(request.status);

    final statusText = StatusUtils.getRequestStatusText(request.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título y estado
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      request.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  if (showStatus) ...[
                    const SizedBox(width: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // Categoría
              Row(
                children: [
                  const Icon(Icons.category_outlined, size: 19),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      CategoryUtils.getCategoryName(request.categoryId),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Ubicación
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, size: 19),
                  const SizedBox(width: 8),
                  Expanded(child: Text(request.address)),
                ],
              ),

              const SizedBox(height: 8),

              // Radio de búsqueda
              Row(
                children: [
                  const Icon(Icons.radar_outlined, size: 19),
                  const SizedBox(width: 8),
                  Text(
                    'Radio: '
                    '${request.searchRadiusKm.toStringAsFixed(0)} km',
                  ),
                ],
              ),

              // Fecha
              if (request.createdAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule_outlined, size: 19),
                    const SizedBox(width: 8),
                    Text(DateUtilsHelper.formatDateTime(request.createdAt!)),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Descripción
              Text(
                request.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Imágenes
              if (request.imageUrls.isNotEmpty) ...[
                const SizedBox(height: 12),

                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        request.imageUrls.first,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_outlined),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Text(
                      '${request.imageUrls.length} '
                      '${request.imageUrls.length == 1 ? 'imagen' : 'imágenes'}',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ],

              // Eliminar
              if (onDelete != null) ...[
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar solicitud'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Acción principal
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onViewDetails,
                  child: Text(buttonText ?? 'Ver detalles'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
