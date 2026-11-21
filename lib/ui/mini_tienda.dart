import 'package:flutter/material.dart';
import '../dominio/dinero.dart';
import '../vm/app_vm.dart';
import '../vm/tienda_vm.dart';
import 'widgets.dart';

class MiniTiendaScreen extends StatelessWidget {
  final AppVm app;
  final TiendaVm vm;
  const MiniTiendaScreen({super.key, required this.app, required this.vm});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (_, __) {
        final tienda = vm.tiendaActual;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BannerError(vm.error, alCerrar: vm.limpiarError),
            SegmentedButton<String>(
              segments: vm.tiendas
                  .map((t) => ButtonSegment(value: t.id, label: Text('${t.emoji} ${t.nombre}')))
                  .toList(),
              selected: {vm.tiendaSeleccionadaId},
              onSelectionChanged: (s) => vm.seleccionarTienda(s.first),
            ),
            const SizedBox(height: 12),
            TarjetaSeccion(
              titulo: 'Catálogo de ${tienda.nombre}',
              child: Column(
                children: tienda.productos.map((p) {
                  final cant = vm.carrito[p.id] ?? 0;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(p.nombre),
                    subtitle: Text('${formatearPesos(p.precioCentavos)} · Stock: ${p.existencias}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: cant > 0 ? () => vm.quitar(p.id) : null,
                        ),
                        Text('$cant'),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => vm.agregar(p.id),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            if (vm.carrito.isNotEmpty)
              FilledButton.icon(
                icon: const Icon(Icons.shopping_bag),
                label: Text('Comprar (${formatearPesos(vm.totalCarrito)})'),
                onPressed: () {
                  if (vm.comprar()) app.refrescar();
                },
              ),
            const SizedBox(height: 12),
            TarjetaSeccion(
              titulo: 'Mis pedidos (${vm.pedidos.length})',
              child: vm.pedidos.isEmpty
                  ? const Text('Aún no has realizado pedidos.')
                  : Column(
                      children: vm.pedidos
                          .map((ped) => ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text('Pedido ${ped.id} (${ped.tiendaId})'),
                                trailing: Text(formatearPesos(ped.totalCentavos)),
                              ))
                          .toList(),
                    ),
            ),
          ],
        );
      },
    );
  }
}