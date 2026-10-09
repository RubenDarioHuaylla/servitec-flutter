import 'package:flutter/material.dart';

import '../models/service_review.dart';
import '../utils/date_utils.dart';

class ReviewCard extends StatelessWidget {
  final ServiceReview review;

  const ReviewCard({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Row(
                  children: List.generate(
                    5,
                    (index) {
                      return Icon(
                        index < review.rating
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    },
                  ),
                ),

                const Spacer(),

                if (review.createdAt != null)
                  Text(
                    DateUtilsHelper.formatDate(
                      review.createdAt!,
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),

            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 10),

              Text(
                review.comment,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}