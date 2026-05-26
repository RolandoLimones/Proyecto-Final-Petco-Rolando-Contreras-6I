import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/cliente_model.dart';
import '../providers/clients_provider.dart';
import '../widgets/custom_textfield.dart';
import '../utils/app_colors.dart';

class AddEditClienteScreen extends StatefulWidget {
  final String? id;
  final Cliente? cliente;

  const AddEditClienteScreen({
    Key? key,
    this.id,
    this.cliente,
  }) : super(key: key);

  @override
  State<AddEditClienteScreen> createState() => _AddEditClienteScreenState();
}

class _AddEditClienteScreenState extends State<AddEditClienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();

  bool get isEdit => widget.id != null;

  @override
  void initState() {
    super.initState();
    if (isEdit && widget.cliente != null) {
      _nombreController.text = widget.cliente!.nombre;
      _emailController.text = widget.cliente!.email;
      _telefonoController.text = widget.cliente!.telefono;
      _direccionController.text = widget.cliente!.direccion;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<ClientsProvider>(context, listen: false);
    final cliente = Cliente(
      id: widget.id ?? '',
      nombre: _nombreController.text.trim(),
      email: _emailController.text.trim(),
      telefono: _telefonoController.text.trim(),
      direccion: _direccionController.text.trim(),
    );

    try {
      if (isEdit) {
        await provider.updateCliente(cliente);
      } else {
        await provider.addCliente(cliente);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Cliente actualizado con éxito' : 'Cliente agregado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.darkRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<ClientsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Cliente' : 'Agregar Cliente'),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(color: Colors.white.withOpacity(0.4)),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: -30,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryRed),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 500),
                    decoration: AppColors.glassDecoration(borderRadius: 24.0),
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isEdit ? Icons.person_rounded : Icons.person_add_rounded,
                            size: 48,
                            color: AppColors.darkBlue,
                          ),
                          const SizedBox(height: 24.0),
                          CustomTextField(
                            controller: _nombreController,
                            labelText: 'Nombre del Cliente',
                            prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Ingrese el nombre' : null,
                          ),
                          const SizedBox(height: 16.0),
                          CustomTextField(
                            controller: _emailController,
                            labelText: 'Correo Electrónico',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Ingrese un correo';
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                              if (!emailRegex.hasMatch(val.trim())) return 'Ingrese un correo válido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16.0),
                          CustomTextField(
                            controller: _telefonoController,
                            labelText: 'Teléfono',
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.textSecondary),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Ingrese un teléfono' : null,
                          ),
                          const SizedBox(height: 16.0),
                          CustomTextField(
                            controller: _direccionController,
                            labelText: 'Dirección de Envío',
                            maxLines: 2,
                            prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.textSecondary),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Ingrese una dirección' : null,
                          ),
                          const SizedBox(height: 32.0),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: provider.loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkBlue,
                                foregroundColor: Colors.white,
                              ),
                              child: provider.loading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                      isEdit ? 'Guardar Cambios' : 'Registrar Cliente',
                                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 16.0, fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
