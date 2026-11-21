import 'package:flutter/foundation.dart';
import '../dominio/contexto.dart';
import '../dominio/dinero.dart';
import '../dominio/eventos.dart';
import '../dominio/lealtad.dart';
import '../dominio/mini_app.dart';
import '../dominio/notificaciones.dart';
import '../dominio/plataforma.dart';
import '../dominio/sugerencias.dart';

/// Estado global de la SuperApp: usuario activo, navegación, notificaciones y analítica.
class AppVm extends ChangeNotifier {
  final Plataforma plataforma;
  String _usuarioId;
  MiniApp? _abierta;
  int tab = 0;

  AppVm(this.plataforma, {String usuarioInicial = 'ana'}) : _usuarioId = usuarioInicial {
    plataforma.bus.suscribir<EventoApp>((_) => notifyListeners());
  }

  String get usuarioId => _usuarioId;
  PerfilDemo get perfilActivo =>
      plataforma.perfiles.firstWhere((p) => p.id == _usuarioId);

  List<PerfilDemo> get contactos =>
      plataforma.perfiles.where((p) => p.id != _usuarioId).toList();

  MiniApp? get miniAppAbierta => _abierta;

  void cambiarUsuario(String id) {
    if (_usuarioId == id) return;
    _usuarioId = id;
    _abierta = null;
    notifyListeners();
  }

  void abrirMiniApp(MiniApp app) {
    if (!plataforma.registro.estaActiva(app.id)) return;
    _abierta = app;
    notifyListeners();
  }

  void cerrarMiniApp() {
    _abierta = null;
    notifyListeners();
  }

  void cambiarTab(int nuevo) {
    tab = nuevo;
    _abierta = null;
    notifyListeners();
  }

  ContextoMiniApp contexto(MiniApp app) => plataforma.contextoPara(app, _usuarioId);

  void toggleMiniApp(String id) {
    if (plataforma.registro.estaActiva(id)) {
      plataforma.registro.apagar(id);
      if (_abierta?.id == id) _abierta = null;
    } else {
      plataforma.registro.encender(id);
    }
    notifyListeners();
  }

  // Resumen superior del inicio
  int get saldo => plataforma.monedero.saldo(_usuarioId);
  int get puntos => plataforma.lealtad.puntos(_usuarioId);
  NivelLealtad get nivel => plataforma.lealtad.nivel(_usuarioId);
  int get racha => plataforma.lealtad.racha(_usuarioId);
  int get noLeidos => plataforma.mensajes.noLeidos(_usuarioId);
  List<Notificacion> get notificaciones => plataforma.notificador.de(_usuarioId);

  Sugerencia get sugerencia {
    final ahora = plataforma.reloj();
    final desde = masDias(soloFecha(ahora), -29);
    final usos = <Servicio, int>{};
    for (final r in plataforma.analitica.registros) {
      if (r.usuarioId == _usuarioId && !soloFecha(r.fecha).isBefore(desde)) {
        usos[r.servicio] = (usos[r.servicio] ?? 0) + 1;
      }
    }
    return sugerirServicio(usosUltimos30Dias: usos, ahora: ahora);
  }

  bool canjearPuntos(int pts) {
    try {
      plataforma.lealtad.canjear(_usuarioId, pts);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void refrescar() => notifyListeners();
}