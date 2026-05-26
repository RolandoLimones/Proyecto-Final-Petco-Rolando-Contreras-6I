import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cliente_model.dart';
import '../services/firestore_service.dart';

class ClientsProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Cliente> _clientes = [];
  bool _loading = false;

  List<Cliente> get clientes => _clientes;
  bool get loading => _loading;

  Future<void> fetchClientes() async {
    _loading = true;
    notifyListeners();
    try {
      _clientes = await _firestoreService.getClientes();
    } catch (e) {
      _clientes = [];
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addCliente(Cliente cliente) async {
    _loading = true;
    notifyListeners();
    try {
      if (cliente.id.isNotEmpty) {
        await _firestoreService.setDocument(
          'clientes',
          cliente.id,
          cliente.toMap(),
        );
        _clientes.add(cliente);
      } else {
        final docRef = await _firestoreService.addDocument(
          'clientes',
          cliente.toMap(),
        );
        _clientes.add(cliente.copyWith(id: docRef.id));
      }
      _clientes.sort(
        (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
      );
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateCliente(Cliente cliente) async {
    _loading = true;
    notifyListeners();
    try {
      // Obtener el documento actual para comparar
      final docRef = FirebaseFirestore.instance
          .collection('clientes')
          .doc(cliente.id);
      final docSnap = await docRef.get();

      // Datos a actualizar (solo los que cambiaron)
      Map<String, dynamic> updates = {};

      // Comparar cada campo (incluyendo tarjeta)
      if (docSnap.exists) {
        final oldData = docSnap.data()!;

        // Nombre, email, teléfono, dirección (siempre se actualizan)
        updates['nombre'] = cliente.nombre;
        updates['email'] = cliente.email;
        updates['telefono'] = cliente.telefono;
        updates['direccion'] = cliente.direccion;

        // Tarjeta: si es null o vacío -> eliminar el campo
        _handleCardField(
          updates,
          'tarjetaNumero',
          cliente.tarjetaNumero,
          oldData,
        );
        _handleCardField(
          updates,
          'tarjetaNombre',
          cliente.tarjetaNombre,
          oldData,
        );
        _handleCardField(
          updates,
          'tarjetaExpiry',
          cliente.tarjetaExpiry,
          oldData,
        );
        _handleCardField(updates, 'tarjetaCvc', cliente.tarjetaCvc, oldData);
      } else {
        // Si no existe el documento (caso raro), usamos set con merge
        updates = cliente.toMap();
        // Convertir nulos a FieldValue.delete()
        updates.updateAll((key, value) {
          if (value == null || (value is String && value.isEmpty)) {
            return FieldValue.delete();
          }
          return value;
        });
        await docRef.set(updates, SetOptions(merge: true));
        _clientes.add(cliente);
        _clientes.sort(
          (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
        );
        _loading = false;
        notifyListeners();
        return;
      }

      // Realizar la actualización con los campos preparados
      if (updates.isNotEmpty) {
        await docRef.update(updates);
      }

      // Actualizar la lista local
      final index = _clientes.indexWhere((c) => c.id == cliente.id);
      if (index != -1) {
        _clientes[index] = cliente;
        _clientes.sort(
          (a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()),
        );
      }
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Método auxiliar para manejar campos de tarjeta
  void _handleCardField(
    Map<String, dynamic> updates,
    String fieldName,
    String? newValue,
    Map<String, dynamic> oldData,
  ) {
    final oldValue = oldData[fieldName];
    final shouldDelete = newValue == null || newValue.trim().isEmpty;

    if (shouldDelete) {
      // Si el campo existía en Firestore, lo eliminamos
      if (oldValue != null) {
        updates[fieldName] = FieldValue.delete();
      }
      // Si no existía, no hacemos nada
    } else {
      // Solo actualizar si cambió
      if (oldValue != newValue) {
        updates[fieldName] = newValue;
      }
    }
  }

  Future<void> deleteCliente(String id) async {
    _loading = true;
    notifyListeners();
    try {
      await _firestoreService.deleteDocument('clientes', id);
      _clientes.removeWhere((c) => c.id == id);
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
