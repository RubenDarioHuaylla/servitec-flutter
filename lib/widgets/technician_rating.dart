import 'package:flutter/material.dart';

import '../models/rating_summary.dart';
import '../services/review_service.dart';

class TechnicianRating extends StatelessWidget {
  final String technicianId;
  final bool centered;

  const TechnicianRating({
    super.key,
    required this.technicianId,
    this.centered = true,
  });

  @override
  Widget build(BuildContext context) {
    final ReviewService reviewService = ReviewService();

    return StreamBuilder<RatingSummary>(
      stream: reviewService.getTechnicianRatingSummary(
        technicianId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            'No se pudo cargar la calificación',
          );
        }

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          );
        }

        final summary =
            snapshot.data ??
            const RatingSummary(
              average: 0,
              totalReviews: 0,
            );

        if (summary.totalReviews == 0) {
          return Row(
            mainAxisAlignment: centered
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: const [
              Icon(
                Icons.star_border,
                color: Colors.grey,
              ),
              SizedBox(width: 6),
              Text('Sin calificaciones'),
            ],
          );
        }

        return Row(
          mainAxisAlignment: centered
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            const Icon(
              Icons.star,
              color: Colors.amber,
            ),

            const SizedBox(width: 5),

            Text(
              summary.average.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(width: 5),

            Text(
              '(${summary.totalReviews} '
              '${summary.totalReviews == 1 ? 'reseña' : 'reseñas'})',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        );
      },
    );
  }
}