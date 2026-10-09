import 'package:flutter/material.dart';

class CategoryUtils {
  static String getCategoryName(String categoryId) {
    switch (categoryId) {
      case 'electricidad':
        return 'Electricidad';
      case 'plomeria':
        return 'Plomería';
      case 'gasfiteria':
        return 'Gasfitería';
      case 'carpinteria':
        return 'Carpintería';
      case 'pintura':
        return 'Pintura';
      case 'albanileria':
        return 'Albañilería';
      case 'computacion':
        return 'Computación';
      case 'electrodomesticos':
        return 'Electrodomésticos';
      default:
        return categoryId;
    }
  }

  static String formatCategories(
    List<String> categoryIds,
  ) {
    if (categoryIds.isEmpty) {
      return 'Sin especialidades';
    }

    return categoryIds
        .map(getCategoryName)
        .join(' · ');
  }

  static IconData getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'electricidad':
        return Icons.electrical_services_outlined;

      case 'plomeria':
        return Icons.plumbing_outlined;

      case 'gasfiteria':
        return Icons.build_outlined;

      case 'carpinteria':
        return Icons.carpenter_outlined;

      case 'pintura':
        return Icons.format_paint_outlined;

      case 'albanileria':
        return Icons.construction_outlined;

      case 'computacion':
        return Icons.computer_outlined;

      case 'electrodomesticos':
        return Icons.kitchen_outlined;

      default:
        return Icons.home_repair_service_outlined;
    }
  }
}