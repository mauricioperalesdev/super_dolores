import '../dominio/contexto.dart';
import '../dominio/monedero.dart';
import 'vm_base.dart';

class MonederoVm extends VmBase {
  final ContextoMiniApp _ctx;
  int _sec = 0;

  MonederoVm(this._ctx);

  int get saldo => _ctx.monedero.saldo();
  List<Movimiento> get movimientos => _ctx.monedero.movimientos();

  bool pagarServicio(int centavos, String concepto) => ejecutar(() {
        _ctx.pagos.pagar(centavos, concepto, clave: 'pago-${++_sec}');
      });
}