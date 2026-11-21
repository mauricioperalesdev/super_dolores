import '../dominio/contexto.dart';
import '../dominio/transporte.dart';
import 'vm_base.dart';

class LugarDolores {
  final String nombre;
  final Punto punto;
  const LugarDolores(this.nombre, this.punto);
}

class ViajesVm extends VmBase {
  static const lugares = [
    LugarDolores('Jardín Principal', Punto(21.1561, -100.9333)),
    LugarDolores('Parroquia de Dolores', Punto(21.1565, -100.9339)),
    LugarDolores('Museo Casa Hidalgo', Punto(21.1553, -100.9345)),
    LugarDolores('UTNG', Punto(21.1325, -100.9267)),
    LugarDolores('Central de Autobuses', Punto(21.1489, -100.9281)),
  ];

  final ContextoMiniApp _ctx;
  int origenIdx = 0;
  int destinoIdx = 3;

  ViajesVm(this._ctx);

  LugarDolores get origen => lugares[origenIdx];
  LugarDolores get destino => lugares[destinoIdx];

  int get estimado => _ctx.viajes.estimar(origen.punto, destino.punto);

  List<Viaje> get historial => _ctx.viajes.misViajes();

  Viaje? get viajeActivo {
    for (final v in historial) {
      if (v.estado == EstadoViaje.solicitado ||
          v.estado == EstadoViaje.aceptado ||
          v.estado == EstadoViaje.enCurso) {
        return v;
      }
    }
    return null;
  }

  void setOrigen(int idx) {
    origenIdx = idx;
    limpiarError();
    notifyListeners();
  }

  void setDestino(int idx) {
    destinoIdx = idx;
    limpiarError();
    notifyListeners();
  }

  bool solicitar() => ejecutar(() {
        _ctx.viajes.solicitar(origen.punto, destino.punto);
      });

  bool avanzar() => ejecutar(() {
        final v = viajeActivo;
        if (v == null) return;
        switch (v.estado) {
          case EstadoViaje.solicitado:
            _ctx.viajes.aceptar(v.id, 'conductor1');
          case EstadoViaje.aceptado:
            _ctx.viajes.iniciar(v.id);
          case EstadoViaje.enCurso:
            final km = distanciaKm(v.origen, v.destino);
            _ctx.viajes.finalizar(
              v.id,
              km: km < 0.5 ? 0.5 : km,
              minutos: Tarifa.minutosEstimados(km < 0.5 ? 0.5 : km),
            );
          default:
            break;
        }
      });

  bool cancelar() => ejecutar(() {
        final v = viajeActivo;
        if (v != null) _ctx.viajes.cancelar(v.id);
      });
}