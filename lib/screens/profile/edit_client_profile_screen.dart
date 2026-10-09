import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/user_service.dart';

import '../../utils/validators.dart';

import '../../widgets/custom_text_field.dart';

import 'dart:io';

import 'package:image_picker/image_picker.dart';
import '../../services/storage_service.dart';

class EditClientProfileScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String phone;
  final String location;
  final String? profileImageUrl;

  const EditClientProfileScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.location,
    this.profileImageUrl,
  });

  @override
  State<EditClientProfileScreen> createState() =>
      _EditClientProfileScreenState();
}

class _EditClientProfileScreenState extends State<EditClientProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final UserService _userService = UserService();

  bool _isLoading = false;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  final StorageService _storageService = StorageService();

  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController phoneController;
  late final TextEditingController locationController;

  @override
  void initState() {
    super.initState();

    firstNameController = TextEditingController(text: widget.firstName);

    lastNameController = TextEditingController(text: widget.lastName);

    phoneController = TextEditingController(text: widget.phone);

    locationController = TextEditingController(text: widget.location);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? profileImageUrl = widget.profileImageUrl;

      // Si seleccionó una nueva imagen, subirla a Storage
      if (_selectedImage != null) {
        final currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser == null) {
          throw Exception('No hay una sesión activa');
        }

        profileImageUrl = await _storageService.uploadProfileImage(
          userId: currentUser.uid,
          imageFile: File(_selectedImage!.path),
        );
      }

      await _userService.updateCurrentUserProfile(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        phone: phoneController.text.trim(),
        location: locationController.text.trim(),
        profileImageUrl: profileImageUrl,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar el perfil: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) {
      return;
    }

    setState(() {
      _selectedImage = image;
    });
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
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundImage: _selectedImage != null
                      ? FileImage(File(_selectedImage!.path))
                      : widget.profileImageUrl != null &&
                            widget.profileImageUrl!.isNotEmpty
                      ? NetworkImage(widget.profileImageUrl!)
                      : null,
                  child:
                      _selectedImage == null &&
                          (widget.profileImageUrl == null ||
                              widget.profileImageUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),

                const SizedBox(height: 12),

                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(
                    _selectedImage == null
                        ? 'Cambiar foto'
                        : 'Seleccionar otra foto',
                  ),
                ),

                const SizedBox(height: 24),

                CustomTextField(
                  label: 'Nombre',
                  hintText: 'Ingrese su nombre',
                  icon: Icons.person_outline,
                  controller: firstNameController,
                  validator: (value) {
                    return Validators.validateRequiredField(value, 'su nombre');
                  },
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Apellido',
                  hintText: 'Ingrese su apellido',
                  icon: Icons.person_outline,
                  controller: lastNameController,
                  validator: (value) {
                    return Validators.validateRequiredField(
                      value,
                      'su apellido',
                    );
                  },
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Teléfono',
                  hintText: 'Ingrese su teléfono',
                  icon: Icons.phone_outlined,
                  controller: phoneController,
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Ubicación',
                  hintText: 'Ej: Wanchaq, Cusco',
                  icon: Icons.location_on_outlined,
                  controller: locationController,
                  validator: (value) {
                    return Validators.validateUbicacion(value);
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Guardar cambios'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
