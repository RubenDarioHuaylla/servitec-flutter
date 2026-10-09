
class Validators {

  static String? validateEmail(String? value) {

    if (value == null || value.isEmpty) {
      return "El correo es obligatorio";
    }

    if (!value.contains("@")) {
      return "Ingrese un correo válido";
    }

    return null;
  }

  static String? validatePassword(String? value) {

    if (value == null || value.isEmpty) {
      return "La contraseña es obligatoria";
    }

    if (value.length < 6) {
      return "Debe tener al menos 6 caracteres";
    }

    return null;
  }


  static String? validateRequiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese $fieldName';
    }

    if (value.trim().length < 2) {
      return '$fieldName debe tener al menos 2 caracteres';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese su número de teléfono';
    }

    final phone = value.trim();

    if (!RegExp(r'^[0-9]{9}$').hasMatch(phone)) {
      return 'Ingrese un número de 9 dígitos';
    }

    return null;
  }

  static String? validateExperience(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese sus años de experiencia';
    }

    final years = int.tryParse(value.trim());

    if (years == null) {
      return 'Ingrese una cantidad válida';
    }

    if (years < 0 || years > 60) {
      return 'Ingrese una experiencia válida';
    }

    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese una descripción profesional';
    }

    if (value.trim().length < 20) {
      return 'Escriba al menos 20 caracteres';
    }

    return null;
  }


  static String? validateTitulo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese el titulo';
    }


    if (value.trim().length < 5) {
      return 'El titulo debe tener al menos 5 caracteres';
    }

    return null;
  }

  static String? validateDescripcion(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese la descripción';
    }

    if (value.trim().length < 10) {
      return 'La descripción debe tener al menos 10 caracteres';
    }

    return null;
  }

  static String? validateUbicacion(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese la ubicación';
    }

    return null;
  }

  // validacion para realizar un cotizacion

  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese el precio de la cotización';
    }

    final price = double.tryParse(value.trim().replaceAll(',', '.'));

    if (price == null) {
      return 'Ingrese un precio válido';
    }

    if (price <= 0) {
      return 'El precio debe ser mayor que cero';
    }

    if (price > 100000) {
      return 'Ingrese un precio válido';
    }

    return null;
  }

  static String? validateDuration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese la duración estimada';
    }

    final duration = double.tryParse(value.trim().replaceAll(',', '.'));

    if (duration == null) {
      return 'Ingrese una duración válida';
    }

    if (duration <= 0) {
      return 'La duración debe ser mayor que cero';
    }

    return null;
  }

  static String? validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Escriba un mensaje para el cliente';
    }

    if (value.trim().length < 10) {
      return 'El mensaje debe tener al menos 10 caracteres';
    }

    return null;
  }

}