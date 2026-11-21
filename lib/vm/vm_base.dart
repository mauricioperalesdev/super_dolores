import 'package:flutter/foundation.dart';
import '../dominio/excepciones.dart';

/// Base para los ViewModels: maneja el error visible al usuario y notifica a la pantalla.
abstract class VmBase extends ChangeNotifier {
  String? error;

  void limpiarError() {
    if (error != null) {
      error = null;
      notifyListeners();
    }
  }

  /// Ejecuta una acción capturando errores de negocio y convirtiendo cualquier otro en mensaje seguro.
  bool ejecutar(void Function() accion) {
    error = null;
    try {
      accion();
      notifyListeners();
      return true;
    } catch (e) {
      error = mensajeSeguro(e);
      notifyListeners();
      return false;
    }
  }
}