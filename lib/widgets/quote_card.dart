import 'package:flutter/material.dart';

import '../models/service_quote.dart';
import '../utils/status_utils.dart';

class QuoteCard extends StatelessWidget {
  final ServiceQuote quote;

  final String technicianName;
  final double ratingAverage;
  final int totalReviews;

  final VoidCallback? onAccept;
  final VoidCallback? onViewProfile;

  const QuoteCard({
    super.key,
    required this.quote,
    required this.technicianName,
    required this.ratingAverage,
    required this.totalReviews,
    this.onAccept,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = StatusUtils.getQuoteStatusColor(quote.status);
    final statusText = StatusUtils.getQuoteStatusText(quote.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        technicianName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      if (totalReviews > 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              ratingAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '($totalReviews '
                              '${totalReviews == 1 ? 'reseña' : 'reseñas'})',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          'Sin calificaciones',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),

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
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.payments_outlined),
                const SizedBox(width: 8),
                Text(
                  'S/ ${quote.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.schedule_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Tiempo estimado: '
                  '${quote.formattedDuration}',
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              quote.message,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),

            if (onViewProfile != null || onAccept != null) ...[
              const SizedBox(height: 18),

              Row(
                children: [
                  if (onViewProfile != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onViewProfile,
                        icon: const Icon(Icons.person_outline),
                        label: const Text('Ver perfil'),
                      ),
                    ),

                  if (onViewProfile != null && onAccept != null)
                    const SizedBox(width: 10),

                  if (onAccept != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onAccept,
                        icon: const Icon(Icons.check),
                        label: const Text('Aceptar'),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
