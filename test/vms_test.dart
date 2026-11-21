import 'package:flutter_test/flutter_test.dart';
import 'package:super_dolores/dominio/plataforma.dart';
import 'package:super_dolores/dominio/transporte.dart';
import 'package:super_dolores/vm/app_vm.dart';
import 'package:super_dolores/vm/chat_vm.dart';
import 'package:super_dolores/vm/monedero_vm.dart';
import 'package:super_dolores/vm/tienda_vm.dart';
import 'package:super_dolores/vm/viajes_vm.dart';

void main() {
  test('AppVm cambia de usuario, abre mini-apps y respeta el kill switch', () {
    final p = Plataforma()..cargarDatosDemo();
    final app = AppVm(p);
    expect(app.usuarioId, 'ana');

    app.abrirMiniApp(Plataforma.miniChat);
    expect(app.miniAppAbierta?.id, 'chat');

    app.toggleMiniApp('chat'); // apaga chat y lo cierra automáticamente
    expect(app.miniAppAbierta, isNull);
    app.abrirMiniApp(Plataforma.miniChat); // apagado: no abre
    expect(app.miniAppAbierta, isNull);

    app.cambiarUsuario('luis');
    expect(app.usuarioId, 'luis');
  });

  test('ChatVm envía mensajes y dinero y expone errores claros', () {
    final p = Plataforma()..cargarDatosDemo();
    final vm = ChatVm(p.contextoPara(Plataforma.miniChat, 'ana'));

    expect(vm.enviarTexto('luis', '   '), isFalse);
    expect(vm.error, isNotNull);

    expect(vm.enviarTexto('luis', 'Hola Luis'), isTrue);
    expect(vm.error, isNull);
    expect(vm.mensajesCon('luis').single.texto, 'Hola Luis');

    expect(vm.enviarDinero('luis', 5000), isTrue);
    expect(p.monedero.saldo('luis'), 105000);
  });

  test('MonederoVm consulta saldo y ejecuta pagos', () {
    final p = Plataforma()..cargarDatosDemo();
    final vm = MonederoVm(p.contextoPara(Plataforma.miniMonedero, 'ana'));
    expect(vm.saldo, 100000);

    expect(vm.pagarServicio(15000, 'Recibo CFE'), isTrue);
    expect(vm.saldo, 85000);
    expect(vm.movimientos.first.concepto, 'Recibo CFE');
  });

  test('TiendaVm gestiona carrito, compra y limpia al cambiar tienda', () {
    final p = Plataforma()..cargarDatosDemo();
    final vm = TiendaVm(p.contextoPara(Plataforma.miniTienda, 'ana'));

    vm.agregar('kilo');
    vm.agregar('kilo');
    expect(vm.totalCarrito, 5600);

    expect(vm.comprar(), isTrue);
    expect(vm.carrito, isEmpty);
    expect(vm.pedidos.length, 1);

    vm.agregar('kilo');
    vm.seleccionarTienda('cajeta');
    expect(vm.carrito, isEmpty);
  });

  test('ViajesVm recorre todo el ciclo de vida de un viaje', () {
    final p = Plataforma()..cargarDatosDemo();
    final vm = ViajesVm(p.contextoPara(Plataforma.miniViajes, 'ana'));

    expect(vm.solicitar(), isTrue);
    expect(vm.viajeActivo?.estado, EstadoViaje.solicitado);

    expect(vm.avanzar(), isTrue);
    expect(vm.viajeActivo?.estado, EstadoViaje.aceptado);

    expect(vm.avanzar(), isTrue);
    expect(vm.viajeActivo?.estado, EstadoViaje.enCurso);

    expect(vm.avanzar(), isTrue);
    expect(vm.viajeActivo, isNull);
    expect(vm.historial.single.estado, EstadoViaje.finalizado);
  });
}