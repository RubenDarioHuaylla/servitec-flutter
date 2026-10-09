import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/category_service.dart';
import '../../models/category.dart';
import '../../services/request_service.dart';
import '../../utils/validators.dart';
import '../../services/location_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/storage_service.dart';

class CreateRequestScreen extends StatefulWidget {
  final String? initialCategoryId;
  const CreateRequestScreen({super.key, this.initialCategoryId});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  final RequestService _requestService = RequestService();

  bool _isSaving = false;

  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = [];
  String? _selectedCategoryId;
  double selectedRadius = 5;

  bool _isLoadingCategories = true;
  String? _categoryError;

  final LocationService _locationService = LocationService();

  double? _latitude;
  double? _longitude;

  bool _isGettingLocation = false;

  final ImagePicker _imagePicker = ImagePicker();
  final StorageService _storageService = StorageService();
  final List<XFile> _selectedImages = [];
  static const int _maxImages = 5;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    _loadCategories();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo puedes agregar hasta 5 imágenes')),
      );
      return;
    }

    final images = await _imagePicker.pickMultiImage(imageQuality: 80);

    if (images.isEmpty) {
      return;
    }

    final remaining = _maxImages - _selectedImages.length;

    setState(() {
      _selectedImages.addAll(images.take(remaining));
    });

    if (images.length > remaining && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo se agregaron las imágenes permitidas'),
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getActiveCategories();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _categoryError = error.toString();
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      final result = await _locationService.getCurrentLocation();

      if (!mounted) return;

      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;

        locationController.text = result.address;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ubicación obtenida correctamente')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo obtener la ubicación: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleccione una categoría')));
      return;
    }

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe registrar la ubicación del servicio'),
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final requestId = await _requestService.createRequest(
        categoryId: _selectedCategoryId!,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        address: locationController.text.trim(),
        latitude: _latitude ?? 0,
        longitude: _longitude ?? 0,
        searchRadiusKm: selectedRadius,
        imageUrls: const [],
      );

      List<String> imageUrls = [];

    if (_selectedImages.isNotEmpty) {
      final files = _selectedImages
          .map((image) => File(image.path))
          .toList();

      imageUrls = await _storageService.uploadRequestImages(
        requestId: requestId,
        images: files,
      );

      await _requestService.updateRequestImages(
        requestId: requestId,
        imageUrls: imageUrls,
      );
    }

      if (!mounted) return;

      Navigator.pop(context, requestId);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo crear la solicitud: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitud de Servicio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCategoryField(),
              CustomTextField(
                label: 'Título de la solicitud',
                hintText: 'Título de la solicitud',
                icon: Icons.title,
                controller: titleController,
                validator: Validators.validateTitulo,
              ),
              SizedBox(height: 20),
              CustomTextField(
                label: 'Descripción del problema',
                hintText: 'Descripción tu problema',
                icon: Icons.description,
                controller: descriptionController,
                maxLines: 5,
                validator: Validators.validateDescripcion,
              ),
              SizedBox(height: 20),
              // *********fotografia *****
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fotografías del problema',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Puedes agregar hasta $_maxImages imágenes.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _selectedImages.length >= _maxImages
                          ? null
                          : _pickImages,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: Text(
                        _selectedImages.isEmpty
                            ? 'Agregar fotografías'
                            : 'Agregar más fotografías',
                      ),
                    ),
                  ),

                  if (_selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(_selectedImages[index].path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              Positioned(
                                top: 4,
                                right: 4,
                                child: CircleAvatar(
                                  radius: 14,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.close, size: 16),
                                    onPressed: () {
                                      _removeImage(index);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),

              SizedBox(height: 20),

              // ***** ubicacion ****************
              CustomTextField(
                label: 'Ubicación del servicio',
                hintText: 'Obten tu ubicacion actual',
                icon: Icons.location_on,
                controller: locationController,
                validator: Validators.validateUbicacion,
                readOnly: true,
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isGettingLocation ? null : _getCurrentLocation,
                  icon: _isGettingLocation
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(
                    _latitude == null || _longitude == null
                        ? 'Usar mi ubicación actual'
                        : 'Actualizar ubicación',
                  ),
                ),
              ),

              if (_latitude != null && _longitude != null)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, size: 18),
                      SizedBox(width: 6),
                      Text('Ubicación GPS registrada'),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // radio de busqueda
              _buildRadio(),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submitRequest,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enviar solicitud'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Radio de búsqueda: '
          '${selectedRadius.toInt()} km',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        Slider(
          value: selectedRadius,
          min: 1,
          max: 20,
          divisions: 19,
          label: '${selectedRadius.toInt()} km',
          onChanged: (value) {
            setState(() {
              selectedRadius = value;
            });
          },
        ),

        Text(
          'Se buscarán técnicos dentro de '
          '${selectedRadius.toInt()} km.',
          style: TextStyle(color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    if (_isLoadingCategories) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_categoryError != null) {
      return Column(
        children: [
          const Text('No se pudieron cargar las categorías'),
          TextButton(
            onPressed: _loadCategories,
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: _selectedCategoryId,
      decoration: const InputDecoration(
        labelText: 'Categoría',
        border: OutlineInputBorder(),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem<String>(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Seleccione una categoría';
        }

        return null;
      },
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.dispose();
  }
}
