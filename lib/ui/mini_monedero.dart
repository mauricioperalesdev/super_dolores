import 'package:flutter/material.dart';
import '../dominio/dinero.dart';
import '../vm/app_vm.dart';
import '../vm/monedero_vm.dart';
import 'widgets.dart';

class MiniMonederoScreen extends StatelessWidget {
  final AppVm app;
  final MonederoVm vm;
  const MiniMonederoScreen({super.key, required this.app, required this.vm});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (_, __) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BannerError(vm.error, alCerrar: vm.limpiarError),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Saldo actual'),
                    Text(
                      formatearPesos(vm.saldo),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilledButton.tonal(
                          onPressed: () {
                            if (vm.pagarServicio(15000, 'Pago Agua SIMAPAS')) app.refrescar();
                          },
                          child: const Text('Pagar Agua (\$150)'),
                        ),
                        FilledButton.tonal(
                          onPressed: () {
                            if (vm.pagarServicio(32000, 'Recibo CFE')) app.refrescar();
                          },
                          child: const Text('Pagar Luz (\$320)'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TarjetaSeccion(
              titulo: 'Libro de movimientos (auditoría)',
              child: Column(
                children: vm.movimientos
                    .map((m) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(m.concepto),
                          subtitle: Text(m.tipo.name),
                          trailing: Text(
                            formatearPesos(m.montoCentavos),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: m.montoCentavos >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
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