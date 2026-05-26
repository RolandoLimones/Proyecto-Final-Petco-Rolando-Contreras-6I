import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/mascota_model.dart';
import '../utils/app_colors.dart';

class MascotaCard extends StatelessWidget {
  final Mascota mascota;
  final String currentUserId;
  final bool isAdmin; // Nuevo: si es admin puede modificar todas
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MascotaCard({
    Key? key,
    required this.mascota,
    required this.currentUserId,
    this.isAdmin = false,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  Color _getSpeciesColor(String especie) {
    switch (especie.toLowerCase()) {
      case 'perro':
        return AppColors.primaryBlue;
      case 'gato':
        return AppColors.primaryRed;
      default:
        return const Color(0xFFC3E5D8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _getSpeciesColor(mascota.especie);
    final isOwner = mascota.clienteId == currentUserId;
    final canModify = isAdmin || isOwner;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          decoration: AppColors.glassDecoration(borderRadius: 16.0),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 36.0,
                  backgroundColor: avatarColor,
                  child: const Icon(
                    Icons.pets_rounded,
                    size: 36.0,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                mascota.nombre,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${mascota.especie} • ${mascota.raza}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${mascota.edad} ${mascota.edad == 1 ? 'año' : 'años'}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (mascota.peso != null)
                        Text(
                          '${mascota.peso} kg',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.0,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  if (canModify)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 20.0,
                            color: AppColors.darkBlue,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: onEdit,
                        ),
                        const SizedBox(width: 8.0),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 20.0,
                            color: AppColors.darkRed,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
