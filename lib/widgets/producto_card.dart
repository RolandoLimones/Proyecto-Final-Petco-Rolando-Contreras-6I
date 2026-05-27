// lib/widgets/producto_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import '../utils/app_colors.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;
  final String currentUserId;
  final bool isAdmin; // Si es admin, siempre muestra botones
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductoCard({
    Key? key,
    required this.producto,
    required this.currentUserId,
    this.isAdmin = false,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  Color _getPastelColor(String name) {
    if (name.isEmpty) return AppColors.primaryBlue;
    final charCode = name.toUpperCase().codeUnitAt(0);
    final colors = [
      AppColors.primaryBlue,
      AppColors.primaryRed,
      const Color(0xFFC3E5D8),
      const Color(0xFFE2C9F3),
      const Color(0xFFF7E2AD),
      const Color(0xFFF9C5D1),
      const Color(0xFFC5F3E2),
    ];
    return colors[charCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final bool showButtons = isAdmin || producto.creadorId == currentUserId;
    final initial = producto.nombre.isNotEmpty
        ? producto.nombre[0].toUpperCase()
        : '?';
    final avatarColor = _getPastelColor(producto.nombre);

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
              // Imagen o avatar
              Center(
                child:
                    producto.imagenUrl != null && producto.imagenUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(36.0),
                        child: Image.network(
                          producto.imagenUrl!,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              CircleAvatar(
                                radius: 36.0,
                                backgroundColor: avatarColor,
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 28.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                        ),
                      )
                    : CircleAvatar(
                        radius: 36.0,
                        backgroundColor: avatarColor,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 12.0),

              // Nombre
              Text(
                producto.nombre,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Categoría
              Text(
                producto.categoria,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),

              // Precio y botones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${producto.precio.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkRed,
                    ),
                  ),
                  if (showButtons)
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
                          onPressed:
                              onDelete, // El diálogo lo maneja la pantalla padre
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
