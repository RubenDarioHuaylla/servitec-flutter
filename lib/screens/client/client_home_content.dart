import 'package:flutter/material.dart';

import '../../models/category.dart';
import '../../services/category_service.dart';

import '../requests/create_request_screen.dart';
import '../../widgets/category_home_card.dart';
import '../../utils/category_utils.dart';

class ClientHomeContent extends StatefulWidget {
  const ClientHomeContent({super.key});

  @override
  State<ClientHomeContent> createState() => _ClientHomeContentState();
}

class _ClientHomeContentState extends State<ClientHomeContent> {
  final CategoryService _categoryService = CategoryService();

  List<Category> _categories = [];

  bool _isLoadingCategories = true;
  String? _categoriesError;

  @override
  void initState() {
    super.initState();

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getActiveCategories();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
        _categoriesError = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoadingCategories = false;
        _categoriesError = error.toString();
      });
    }
  }

  void _openCreateRequest({String? categoryId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateRequestScreen(initialCategoryId: categoryId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ServiTec'),
        automaticallyImplyLeading: false,
      ),

      body: RefreshIndicator(
        onRefresh: _loadCategories,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hola', style: TextStyle(fontSize: 16)),

              const SizedBox(height: 4),

              Text(
                '¿Qué necesitas hoy?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _openCreateRequest();
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Solicitar un técnico'),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Servicios',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  if (!_isLoadingCategories && _categories.isNotEmpty)
                    Text(
                      '${_categories.length} categorías',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                'Selecciona el tipo de servicio que necesitas.',
                style: TextStyle(color: Colors.grey.shade700),
              ),

              const SizedBox(height: 16),

              _buildCategories(),

              const SizedBox(height: 32),

              Text(
                '¿Cómo funciona ServiTec?',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              _buildStep(
                number: 1,
                title: 'Publica tu solicitud',
                description:
                    'Describe el problema, indica la ubicación y agrega fotografías si lo necesitas.',
              ),

              _buildStep(
                number: 2,
                title: 'Recibe cotizaciones',
                description:
                    'Los técnicos disponibles pueden enviarte sus propuestas.',
              ),

              _buildStep(
                number: 3,
                title: 'Elige un técnico',
                description:
                    'Compara precio, experiencia, perfil y reseñas antes de aceptar.',
              ),

              _buildStep(
                number: 4,
                title: 'Coordina el servicio',
                description:
                    'Comunícate con el técnico y realiza el seguimiento del trabajo.',
              ),

              _buildStep(
                number: 5,
                title: 'Confirma y califica',
                description:
                    'Cuando el trabajo finalice, confirma el servicio y deja una reseña.',
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    if (_isLoadingCategories) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_categoriesError != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 42),

              const SizedBox(height: 10),

              const Text(
                'No se pudieron cargar los servicios',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              TextButton.icon(
                onPressed: _loadCategories,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: Text('No hay categorías disponibles')),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _categories.length,

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),

      itemBuilder: (context, index) {
        final category = _categories[index];

        return CategoryHomeCard(
          name: category.name,
          description: category.description,
          icon: CategoryUtils.getCategoryIcon(category.id),
          onTap: () {
            _openCreateRequest(categoryId: category.id);
          },
        );
      },
    );
  }

  Widget _buildStep({
    required int number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.20),
            child: Text(
              '$number',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
