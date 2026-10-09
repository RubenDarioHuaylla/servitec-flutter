import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatusUtils {
  static String getServiceStatusText(String status) {
    switch (status) {
      case 'pending_start':
        return 'Pendiente de inicio';
      case 'in_progress':
        return 'En proceso';
      case 'awaiting_client_confirmation':
        return 'Esperando confirmación';
      case 'completed':
        return 'Completado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  static Color getServiceStatusColor(String status) {
    switch (status) {
      case 'pending_start':
        return AppColors.pending;
      case 'in_progress':
        return AppColors.inProgress;
      case 'awaiting_client_confirmation':
        return AppColors.waiting;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.cancelled;
      default:
        return AppColors.neutral;
    }
  }

  static IconData getServiceStatusIcon(String status) {
    switch (status) {
      case 'pending_start':
        return Icons.schedule;
      case 'in_progress':
        return Icons.handyman_outlined;
      case 'awaiting_client_confirmation':
        return Icons.hourglass_top;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }

  static String getQuoteStatusText(String status) {
    switch (status) {
      case 'accepted':
        return 'Aceptada';
      case 'rejected':
        return 'Rechazada';
      case 'withdrawn':
        return 'Retirada';
      default:
        return 'Pendiente';
    }
  }

  static Color getQuoteStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return AppColors.cancelled;
      case 'withdrawn':
        return AppColors.neutral;
      default:
        return AppColors.pending;
    }
  }

  static Color getRequestStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.pending;

      case 'receiving_quotes':
        return AppColors.pending;

      case 'accepted':
        return AppColors.inProgress;

      case 'in_progress':
        return AppColors.inProgress;

      case 'awaiting_client_confirmation':
        return AppColors.waiting;

      case 'completed':
        return AppColors.success;

      case 'cancelled':
        return AppColors.cancelled;

      default:
        return AppColors.neutral;
    }
  }

  static String getRequestStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';

      case 'receiving_quotes':
        return 'Recibiendo cotizaciones';

      case 'accepted':
        return 'Cotización aceptada';

      case 'in_progress':
        return 'En proceso';

      case 'awaiting_client_confirmation':
        return 'Esperando tu confirmación';

      case 'completed':
        return 'Finalizada';

      case 'cancelled':
        return 'Cancelada';

      default:
        return status;
    }
  }

  static String getRequestButtonText(String status) {
    switch (status) {
      case 'accepted':
      case 'in_progress':
        return 'Ver servicio';

      case 'awaiting_client_confirmation':
        return 'Confirmar servicio';

      case 'completed':
        return 'Ver detalles';

      case 'cancelled':
        return 'Ver solicitud';

      default:
        return 'Ver cotizaciones';
    }
  }

  static String getVerificationStatusText(String status) {
    switch (status) {
      case 'verified':
        return 'Perfil verificado';
      case 'rejected':
        return 'Verificación rechazada';
      default:
        return 'Verificación pendiente';
    }
  }

  static Color getVerificationStatusColor(String status) {
    switch (status) {
      case 'verified':
        return AppColors.success;
      case 'rejected':
        return AppColors.cancelled;
      default:
        return AppColors.pending;
    }
  }
}
