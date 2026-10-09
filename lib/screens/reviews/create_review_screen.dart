import 'package:flutter/material.dart';

import '../../models/service_job.dart';
import '../../services/review_service.dart';

class CreateReviewScreen extends StatefulWidget {
  final ServiceJob service;

  const CreateReviewScreen({super.key, required this.service});

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  final ReviewService _reviewService = ReviewService();

  final TextEditingController _commentController = TextEditingController();

  int _rating = 0;

  bool _isSaving = false;

  @override
  void dispose() {
    _commentController.dispose();

    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una calificación')),
      );

      return;
    }

    if (_commentController.text.trim().length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe un comentario de al menos 5 caracteres'),
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _reviewService.createReview(
        service: widget.service,
        rating: _rating,
        comment: _commentController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calificación enviada correctamente')),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('No se pudo enviar la calificación: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _getRatingText() {
    switch (_rating) {
      case 1:
        return 'Muy malo';

      case 2:
        return 'Malo';

      case 3:
        return 'Regular';

      case 4:
        return 'Bueno';

      case 5:
        return 'Excelente';

      default:
        return 'Selecciona una calificación';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calificar servicio')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: Icon(Icons.rate_review_outlined, size: 70)),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  '¿Cómo fue tu experiencia?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  'Califica el trabajo realizado '
                  'por el técnico.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),

              const SizedBox(height: 28),

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    final star = index + 1;

                    return IconButton(
                      onPressed: _isSaving
                          ? null
                          : () {
                              setState(() {
                                _rating = star;
                              });
                            },
                      iconSize: 42,
                      icon: Icon(
                        star <= _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  _getRatingText(),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Comentario',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _commentController,
                maxLines: 5,
                maxLength: 500,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Cuéntanos cómo fue el servicio...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submitReview,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(
                    _isSaving ? 'Enviando...' : 'Enviar calificación',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
