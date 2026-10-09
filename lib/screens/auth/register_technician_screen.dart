import 'package:flutter/material.dart';

import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../technician/technician_main_screen.dart';

import '../../services/category_service.dart';
import '../../models/category.dart';
import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/location_service.dart';

class RegisterTechnicianScreen extends StatefulWidget {
  const RegisterTechnicianScreen({super.key});

  @override
  State<RegisterTechnicianScreen> createState() =>
      _RegisterTechnicianScreenState();
}

class _RegisterTechnicianScreenState extends State<RegisterTechnicianScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LocationService _locationService = LocationService();
  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  //--- cargar categorias desde firestore
  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = [];
  final Set<String> _selectedCategoryIds = {};
  bool _isLoadingCategories = true;
  String? _categoriesError;

  @override
  void initState() {
    super.initState();
    _loadCategories();
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
        _isLoadingCategories = false;
        _categoriesError = error.toString();
      });
    }
  }

  // registrar tecnicos
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  //--
  double selectedRadius = 5;
  bool isAvailable = true;
  bool acceptTerms = false;

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

  Future<void> _registerTechnician() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione al menos una especialidad')),
      );
      return;
    }

    if (!acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe aceptar los términos y condiciones'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.registerTechnician(
        firstName: nameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,
        categoryIds: _selectedCategoryIds.toList(),
        experienceYears: int.parse(experienceController.text.trim()),
        description: descriptionController.text.trim(),
        location: locationController.text.trim(),
        serviceRadiusKm: selectedRadius,
        latitude: _latitude ?? 0,
        longitude: _longitude ?? 0,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Técnico registrado correctamente')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const TechnicianMainScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      String message = 'No se pudo registrar el técnico';

      switch (error.code) {
        case 'email-already-in-use':
          message = 'Este correo ya está registrado';
          break;

        case 'invalid-email':
          message = 'El correo no es válido';
          break;

        case 'weak-password':
          message = 'La contraseña debe tener al menos 6 caracteres';
          break;

        case 'network-request-failed':
          message = 'No se pudo conectar con Firebase';
          break;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
        SnackBar(content: Text('Error al registrar el técnico: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // validaciones de campos

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirme su contraseña';
    }

    if (value != passwordController.text) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    experienceController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de técnico')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: Icon(Icons.engineering_outlined, size: 72)),

                const SizedBox(height: 12),

                const Center(
                  child: Text(
                    'Crea tu perfil profesional',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 8),

                const Center(
                  child: Text(
                    'Recibe solicitudes y ofrece tus servicios',
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Datos personales',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                CustomTextField(
                  label: 'Nombres',
                  hintText: 'Ingrese sus nombres',
                  icon: Icons.person_outline,
                  controller: nameController,
                  validator: (value) {
                    return Validators.validateRequiredField(
                      value,
                      'sus nombres',
                    );
                  },
                ),

                CustomTextField(
                  label: 'Apellidos',
                  hintText: 'Ingrese sus apellidos',
                  icon: Icons.person_outline,
                  controller: lastNameController,
                  validator: (value) {
                    return Validators.validateRequiredField(
                      value,
                      'sus apellidos',
                    );
                  },
                ),

                CustomTextField(
                  label: 'Correo electrónico',
                  hintText: 'Ingrese su correo',
                  icon: Icons.email_outlined,
                  controller: emailController,
                  validator: Validators.validateEmail,
                ),

                CustomTextField(
                  label: 'Teléfono',
                  hintText: 'Ingrese 9 dígitos',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  controller: phoneController,
                  validator: Validators.validatePhone,
                ),

                CustomTextField(
                  label: 'Contraseña',
                  hintText: 'Ingrese su contraseña',
                  icon: Icons.lock_outline,
                  controller: passwordController,
                  validator: Validators.validatePassword,
                  obscureText: true,
                ),

                CustomTextField(
                  label: 'Confirmar contraseña',
                  hintText: 'Repita su contraseña',
                  icon: Icons.lock_outline,
                  controller: confirmPasswordController,
                  validator: _validateConfirmPassword,
                  obscureText: true,
                ),

                const SizedBox(height: 24),

                const Text(
                  'Información profesional',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

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
                    prefixIcon: Icon(Icons.description_outlined),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: Validators.validateDescription,
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Zona de atención',
                  hintText: 'Ej: San Jerónimo, Cusco',
                  icon: Icons.location_on_outlined,
                  controller: locationController,
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

                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: acceptTerms,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Acepto los términos y condiciones'),
                  onChanged: (value) {
                    setState(() {
                      acceptTerms = value ?? false;
                    });
                  },
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registerTechnician,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Registrarme como técnico'),
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
      return Text(
        'No se pudieron cargar las categorías',
        style: const TextStyle(color: Colors.red),
      );
    }

    if (_categories.isEmpty) {
      return const Text('No hay categorías disponibles');
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
            final isSelected = _selectedCategoryIds.contains(category.id);

            return FilterChip(
              label: Text(category.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
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
