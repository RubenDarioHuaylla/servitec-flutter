import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/service_job.dart';
import '../../models/service_request.dart';
import '../../services/service_job_service.dart';
import '../../services/review_service.dart';
import '../chat/chat_screen.dart';
import '../reviews/create_review_screen.dart';

import '../../utils/category_utils.dart';
import '../../utils/status_utils.dart';

import '../../widgets/information_row.dart';
import '../../widgets/request_images.dart';

class ServiceInProgressScreen extends StatefulWidget {
  final ServiceJob service;
  final ServiceRequest request;

  const ServiceInProgressScreen({
    super.key,
    required this.service,
    required this.request,
  });

  @override
  State<ServiceInProgressScreen> createState() =>
      _ServiceInProgressScreenState();
}

class _ServiceInProgressScreenState extends State<ServiceInProgressScreen> {
  final ServiceJobService _serviceJobService = ServiceJobService();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  late ServiceJob _service;

  bool _isUpdating = false;

  bool _isLoadingReview = false;
  bool _hasReview = false;
  final ReviewService _reviewService = ReviewService();

  @override
  void initState() {
    super.initState();

    _service = widget.service;
    if (_service.status == 'completed' && _isClient) {
      _checkReview();
    }
  }

  Future<void> _checkReview() async {
    setState(() {
      _isLoadingReview = true;
    });

    try {
      final review = await _reviewService.getReviewByServiceId(_service.id);

      if (!mounted) return;

      setState(() {
        _hasReview = review != null;
      });
    } catch (error) {
      if (!mounted) return;

      debugPrint('Error comprobando reseña: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingReview = false;
        });
      }
    }
  }

  bool get _isTechnician {
    final user = _auth.currentUser;

    return user != null && user.uid == _service.technicianId;
  }

  bool get _isClient {
    final user = _auth.currentUser;

    return user != null && user.uid == _service.clientId;
  }

  Future<void> _startService() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Iniciar trabajo'),
          content: const Text('¿Deseas marcar este trabajo como iniciado?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Iniciar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await _serviceJobService.startService(
        serviceId: _service.id,
        requestId: _service.requestId,
      );

      await _reloadService();

      if (!mounted) return;

      ScaffoldMessenger.of(
        this.context,
      ).showSnackBar(const SnackBar(content: Text('El trabajo fue iniciado')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('No se pudo iniciar el trabajo: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _finishService() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Finalizar trabajo'),
          content: const Text(
            '¿Terminaste el trabajo? '
            'El cliente deberá confirmar la finalización.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Finalizar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await _serviceJobService.finishServiceByTechnician(
        serviceId: _service.id,
        requestId: _service.requestId,
      );

      await _reloadService();

      if (!mounted) return;

      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text('Trabajo marcado como terminado')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('No se pudo finalizar el trabajo: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _confirmCompletion() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar finalización'),
          content: const Text(
            '¿Confirmas que el trabajo fue realizado '
            'correctamente?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await _serviceJobService.confirmServiceCompletion(
        serviceId: _service.id,
        requestId: _service.requestId,
      );

      await _reloadService();

      if (!mounted) return;

      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text('Servicio completado correctamente')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(content: Text('No se pudo confirmar el servicio: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _reloadService() async {
    final updatedService = await _serviceJobService.getServiceById(_service.id);

    if (!mounted) return;

    setState(() {
      _service = updatedService;
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;

    return Scaffold(
      appBar: AppBar(title: const Text('Servicio')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            request.title,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            _isTechnician ? 'Trabajo asignado' : 'Servicio contratado',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
          ),

          const SizedBox(height: 20),

          _buildStatusCard(),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InformationRow(
                    icon: Icons.payments_outlined,
                    label: 'Precio acordado',
                    value: 'S/ ${_service.agreedPrice.toStringAsFixed(2)}',
                  ),

                  const Divider(),

                  InformationRow(
                    icon: Icons.schedule_outlined,
                    label: 'Duración estimada',
                    value: _service.formattedDuration,
                  ),

                  const Divider(),

                  InformationRow(
                    icon: Icons.location_on_outlined,
                    label: 'Dirección',
                    value: request.address,
                  ),

                  const Divider(),

                  InformationRow(
                    icon: Icons.category_outlined,
                    label: 'Categoría',
                    value: CategoryUtils.getCategoryName(request.categoryId),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Descripción del trabajo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            request.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),

          const SizedBox(height: 24),
          RequestImages(imageUrls: request.imageUrls),

          if (request.imageUrls.isNotEmpty) const SizedBox(height: 24),

          _buildChatButton(),

          const SizedBox(height: 12),

          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final color = StatusUtils.getServiceStatusColor(_service.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              StatusUtils.getServiceStatusIcon(_service.status),
              color: color,
              size: 34,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estado del servicio',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    StatusUtils.getServiceStatusText(_service.status),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatButton() {
    if (_service.status == 'completed' || _service.status == 'cancelled') {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(serviceId: _service.id),
            ),
          );
        },
        icon: const Icon(Icons.chat_outlined),
        label: Text(
          _isTechnician ? 'Contactar al cliente' : 'Contactar al técnico',
        ),
      ),
    );
  }

  Widget _buildActions() {
    if (_isUpdating) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isTechnician) {
      return _buildTechnicianActions();
    }

    if (_isClient) {
      return _buildClientActions();
    }

    return const SizedBox.shrink();
  }

  Widget _buildTechnicianActions() {
    switch (_service.status) {
      case 'pending_start':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startService,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Iniciar trabajo'),
          ),
        );

      case 'in_progress':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _finishService,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Marcar trabajo como terminado'),
          ),
        );

      case 'awaiting_client_confirmation':
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.hourglass_top),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'El trabajo fue marcado como terminado. '
                    'Esperando confirmación del cliente.',
                  ),
                ),
              ],
            ),
          ),
        );

      case 'completed':
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 12),
                Expanded(child: Text('Servicio completado.')),
              ],
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildClientActions() {
    switch (_service.status) {
      case 'pending_start':
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Esperando que el técnico inicie el trabajo.'),
          ),
        );

      case 'in_progress':
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('El técnico está realizando el trabajo.'),
          ),
        );

      case 'awaiting_client_confirmation':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _confirmCompletion,
            icon: const Icon(Icons.verified_outlined),
            label: const Text('Confirmar trabajo realizado'),
          ),
        );

      case 'completed':
        if (_isLoadingReview) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_hasReview) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.star, color: Colors.amber),
                  SizedBox(width: 12),
                  Expanded(child: Text('Ya calificaste este servicio.')),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(child: Text('Servicio completado correctamente.')),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final created = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateReviewScreen(service: _service),
                    ),
                  );

                  if (created != true || !mounted) {
                    return;
                  }

                  await _checkReview();
                },
                icon: const Icon(Icons.star_outline),
                label: const Text('Calificar técnico'),
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
