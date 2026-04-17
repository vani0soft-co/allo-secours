import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:allo_secours/config/app_colors.dart';
import 'package:allo_secours/models/service_model.dart';

class ServiceListTile extends StatelessWidget {
  final Service service;

  const ServiceListTile({Key? key, required this.service}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.lightGray,
        ),
        child: Icon(_getCategoryIcon(), color: _getCategoryColor(), size: 32),
      ),
      title: Text(
        service.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            service.address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star, size: 14, color: Colors.orange),
              const SizedBox(width: 4),
              Text(
                '${service.rating}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${service.distance.toStringAsFixed(1)} km',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: service.isOpen
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.red.withValues(alpha: 0.1),
        ),
        child: Icon(
          service.isOpen ? Icons.check_circle : Icons.cancel,
          color: service.isOpen ? Colors.green : Colors.red,
          size: 20,
        ),
      ),
      onTap: () => Get.toNamed('/service-detail'),
    );
  }

  IconData _getCategoryIcon() {
    switch (service.category) {
      case 'hospital':
        return Icons.local_hospital;
      case 'pharmacy':
        return Icons.local_pharmacy;
      case 'specialist':
        return Icons.person;
      case 'emergency':
        return Icons.emergency;
      default:
        return Icons.medical_services;
    }
  }

  Color _getCategoryColor() {
    switch (service.category) {
      case 'hospital':
        return AppColors.primary;
      case 'pharmacy':
        return Colors.green;
      case 'specialist':
        return Colors.blue;
      case 'emergency':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }
}
