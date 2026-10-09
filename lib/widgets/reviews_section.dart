import 'package:flutter/material.dart';

import '../models/service_review.dart';
import '../services/review_service.dart';
import 'review_card.dart';

class ReviewsSection extends StatelessWidget {
  final String technicianId;
  final int previewLimit;
  final VoidCallback? onViewAll;

  const ReviewsSection({
    super.key,
    required this.technicianId,
    this.previewLimit = 3,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final ReviewService reviewService = ReviewService();

    return StreamBuilder<List<ServiceReview>>(
      stream: reviewService.getTechnicianReviews(technicianId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No se pudieron cargar las reseñas'),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reviews = snapshot.data ?? [];

        if (reviews.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.rate_review_outlined),
                  SizedBox(width: 12),
                  Expanded(child: Text('Todavía no hay reseñas.')),
                ],
              ),
            ),
          );
        }

        final visibleReviews = reviews.take(previewLimit).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Reseñas',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '${reviews.length}',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ...visibleReviews.map((review) => ReviewCard(review: review)),

            if (reviews.length > previewLimit && onViewAll != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onViewAll,
                  icon: const Icon(Icons.rate_review_outlined),
                  label: Text('Ver todas (${reviews.length})'),
                ),
              ),
          ],
        );
      },
    );
  }
}
