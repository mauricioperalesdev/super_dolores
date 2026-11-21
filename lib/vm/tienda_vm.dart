import '../dominio/comercio.dart';
import '../dominio/contexto.dart';
import 'vm_base.dart';

class TiendaVm extends VmBase {
  final ContextoMiniApp _ctx;
  String tiendaSeleccionadaId;
  final Map<String, int> carrito = {};
  int _sec = 0;

  TiendaVm(this._ctx) : tiendaSeleccionadaId = _ctx.comercio.tiendas().first.id;

  List<Tienda> get tiendas => _ctx.comercio.tiendas();
  Tienda get tiendaActual => tiendas.firstWhere((t) => t.id == tiendaSeleccionadaId);
  List<Pedido> get pedidos => _ctx.comercio.misPedidos();

  void seleccionarTienda(String id) {
    if (tiendaSeleccionadaId == id) return;
    tiendaSeleccionadaId = id;
    carrito.clear();
    limpiarError();
    notifyListeners();
  }

  void agregar(String productoId) {
    carrito[productoId] = (carrito[productoId] ?? 0) + 1;
    limpiarError();
    notifyListeners();
  }

  void quitar(String productoId) {
    final actual = carrito[productoId] ?? 0;
    if (actual <= 1) {
      carrito.remove(productoId);
    } else {
      carrito[productoId] = actual - 1;
    }
    limpiarError();
    notifyListeners();
  }

  int get totalCarrito {
    var suma = 0;
    for (final e in carrito.entries) {
      final p = tiendaActual.producto(e.key);
      if (p != null) suma += p.precioCentavos * e.value;
    }
    return suma;
  }

  bool comprar() => ejecutar(() {
        _ctx.comercio.comprar(
          tiendaActual.id,
          Map.of(carrito),
          clave: 'ped-${++_sec}',
        );
        carrito.clear();
      });
}