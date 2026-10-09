import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../models/technician_profile.dart';
import '../../services/category_service.dart';
import '../../services/technician_service.dart';
import '../../utils/validators.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../services/storage_service.dart';
import '../../services/location_service.dart';

class EditTechnicianProfileScreen extends StatefulWidget {
  final TechnicianProfile technician;

  const EditTechnicianProfileScreen({super.key, required this.technician});

  @override
  State<EditTechnicianProfileScreen> createState() =>
      _EditTechnicianProfileScreenState();
}

class _EditTechnicianProfileScreenState
    extends State<EditTechnicianProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController phoneController;
  late final TextEditingController experienceController;
  late final TextEditingController descriptionController;
  late final TextEditingController locationController;

  final Set<String> _selectedCategoryIds = {};
  late double selectedRadius;
  late bool isAvailable;

  final ImagePicker _imagePicker = ImagePicker();
  final StorageService _storageService = StorageService();
  File? _selectedImage;

  final LocationService _locationService = LocationService();

  double? _latitude;
  double? _longitude;

  bool _isGettingLocation = false;

  final CategoryService _categoryService = CategoryService();
  final TechnicianService _technicianService = TechnicianService();

  List<Category> _categories = [];

  bool _isLoadingCategories = true;
  bool _isSaving = false;

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) {
      return;
    }

    setState(() {
      _selectedImage = File(image.path);
    });
  }

  String? _categoriesError;
  @override
  void initState() {
    super.initState();

    final technician = widget.technician;

    firstNameController = TextEditingController(text: technician.firstName);

    lastNameController = TextEditingController(text: technician.lastName);

    phoneController = TextEditingController(text: technician.phone);

    experienceController = TextEditingController(
      text: technician.experienceYears.toString(),
    );

    descriptionController = TextEditingController(text: technician.description);

    locationController = TextEditingController(text: technician.location);

    _latitude = technician.latitude;
    _longitude = technician.longitude;

    _selectedCategoryIds.addAll(technician.categoryIds);

    selectedRadius = technician.serviceRadiusKm;
    isAvailable = technician.available;

    _loadCategories();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    experienceController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.dispose();
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

  Future<void> _loadCategories() async {
    try {
      final result = await _categoryService.getActiveCategories();

      if (!mounted) return;

      setState(() {
        _categories = result;
        _isLoadingCategories = false;
        _categoriesError = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _categoriesError = error.toString();
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione al menos una especialidad')),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      String? profileImageUrl = widget.technician.profileImageUrl;
      if (_selectedImage != null) {
        profileImageUrl = await _storageService.uploadProfileImage(
          userId: widget.technician.userId,
          imageFile: _selectedImage!,
        );
      }

      await _technicianService.updateCurrentTechnicianProfile(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phone: phoneController.text.trim(),
        location: locationController.text.trim(),
        description: descriptionController.text.trim(),
        experienceYears: int.parse(experienceController.text.trim()),
        categoryIds: _selectedCategoryIds.toList(),
        serviceRadiusKm: selectedRadius,
        available: isAvailable,
        latitude: _latitude,
        longitude: _longitude,
        profileImageUrl: profileImageUrl,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } on FormatException {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Los años de experiencia deben ser un número válido'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar el perfil: $error')),
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
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen de perfil y botón para cambiarla
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : widget.technician.profileImageUrl != null
                            ? NetworkImage(widget.technician.profileImageUrl!)
                            : null,
                        child:
                            _selectedImage == null &&
                                widget.technician.profileImageUrl == null
                            ? const Icon(Icons.person, size: 58)
                            : null,
                      ),

                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: _pickImage,
                            icon: const Icon(
                              Icons.camera_alt_outlined,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Cambiar foto'),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Datos profesionales',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: firstNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    return Validators.validateRequiredField(value, 'su nombre');
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: lastNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Apellido',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    return Validators.validateRequiredField(
                      value,
                      'su apellido',
                    );
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: Validators.validatePhone,
                ),

                const SizedBox(height: 16),

                _buildCategoriesSection(),

                const SizedBox(height: 16),

                TextFormField(
                  controller: experienceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Años de experiencia',
                    prefixIcon: Icon(Icons.work_history_outlined),
                    suffixText: 'años',
                    border: OutlineInputBorder(),
                  ),
                  validator: Validators.validateExperience,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: descriptionController,
                  maxLines: 4,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    labelText: 'Descripción profesional',
                    hintText:
                        'Describe tu experiencia, habilidades y servicios',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.description_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: Validators.validateDescription,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Zona de atención',
                    hintText: 'Ej: San Jerónimo, Cusco',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    return Validators.validateRequiredField(
                      value,
                      'su zona de atención',
                    );
                  },
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
                const SizedBox(height: 24),

                Text(
                  'Radio de atención: '
                  '${selectedRadius.toInt()} km',
                  style: const TextStyle(fontWeight: FontWeight.bold),
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

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Disponible para trabajar'),
                  subtitle: Text(
                    isAvailable
                        ? 'Recibirás nuevas solicitudes'
                        : 'No recibirás nuevas solicitudes',
                  ),
                  value: isAvailable,
                  onChanged: (value) {
                    setState(() {
                      isAvailable = value;
                    });
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveChanges,
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.save_outlined),
                              SizedBox(width: 8),
                              Text('Guardar cambios'),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    if (_isLoadingCategories) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_categoriesError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No se pudieron cargar las especialidades',
            style: TextStyle(color: Colors.red),
          ),
          TextButton(
            onPressed: _loadCategories,
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Especialidades',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final selected = _selectedCategoryIds.contains(category.id);

            return FilterChip(
              label: Text(category.name),
              selected: selected,
              onSelected: (value) {
                setState(() {
                  if (value) {
                    _selectedCategoryIds.add(category.id);
                  } else {
                    _selectedCategoryIds.remove(category.id);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
