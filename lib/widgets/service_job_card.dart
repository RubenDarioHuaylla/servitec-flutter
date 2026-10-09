import 'package:flutter/material.dart';

import '../models/service_job.dart';
import '../utils/status_utils.dart';

class ServiceJobCard extends StatelessWidget {
  final ServiceJob job;
  final VoidCallback onTap;
  final String buttonText;

  const ServiceJobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.buttonText = 'Ver trabajo',
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        StatusUtils.getServiceStatusColor(job.status);

    final statusText =
        StatusUtils.getServiceStatusText(job.status);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.requestTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(
                        alpha: 0.15,
                      ),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(
                    Icons.payments_outlined,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'S/ ${job.agreedPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(
                    Icons.schedule_outlined,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Duración: ${job.formattedDuration}',
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Align(
                alignment:
                    Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(
                    Icons.chevron_right,
                  ),
                  label: Text(buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}