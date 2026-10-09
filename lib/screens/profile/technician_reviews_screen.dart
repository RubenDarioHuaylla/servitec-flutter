import 'package:flutter/material.dart';

import '../../models/service_review.dart';
import '../../services/review_service.dart';
import '../../widgets/review_card.dart';
import '../../widgets/technician_rating.dart';

class TechnicianReviewsScreen extends StatelessWidget {
  final String technicianId;
  final String technicianName;

  const TechnicianReviewsScreen({
    super.key,
    required this.technicianId,
    required this.technicianName,
  });

  @override
  Widget build(BuildContext context) {
    final ReviewService reviewService =
        ReviewService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reseñas'),
      ),
      body: StreamBuilder<List<ServiceReview>>(
        stream: reviewService.getTechnicianReviews(
          technicianId,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'No se pudieron cargar las reseñas',
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final reviews = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                technicianName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              TechnicianRating(
                technicianId: technicianId,
                centered: false,
              ),

              const SizedBox(height: 24),

              Text(
                reviews.isEmpty
                    ? 'Sin reseñas'
                    : '${reviews.length} '
                        '${reviews.length == 1 ? 'reseña' : 'reseñas'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              if (reviews.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Este técnico todavía no tiene reseñas.',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...reviews.map(
                  (review) => ReviewCard(
                    review: review,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}