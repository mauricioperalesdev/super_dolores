import 'package:flutter/material.dart';
import '../dominio/dinero.dart';
import '../dominio/transporte.dart';
import '../vm/app_vm.dart';
import '../vm/viajes_vm.dart';
import 'widgets.dart';

class MiniViajesScreen extends StatelessWidget {
  final AppVm app;
  final ViajesVm vm;
  const MiniViajesScreen({super.key, required this.app, required this.vm});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (_, __) {
        final activo = vm.viajeActivo;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BannerError(vm.error, alCerrar: vm.limpiarError),
            if (activo == null)
              TarjetaSeccion(
                titulo: 'Pedir viaje en Dolores Hidalgo',
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      value: vm.origenIdx,
                      decoration: const InputDecoration(labelText: 'Origen'),
                      items: [
                        for (var i = 0; i < ViajesVm.lugares.length; i++)
                          DropdownMenuItem(value: i, child: Text(ViajesVm.lugares[i].nombre)),
                      ],
                      onChanged: (v) => vm.setOrigen(v ?? 0),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: vm.destinoIdx,
                      decoration: const InputDecoration(labelText: 'Destino'),
                      items: [
                        for (var i = 0; i < ViajesVm.lugares.length; i++)
                          DropdownMenuItem(value: i, child: Text(ViajesVm.lugares[i].nombre)),
                      ],
                      onChanged: (v) => vm.setDestino(v ?? 3),
                    ),
                    const SizedBox(height: 12),
                    Text('Tarifa estimada: ${formatearPesos(vm.estimado)}',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      icon: const Icon(Icons.local_taxi),
                      label: const Text('Solicitar viaje'),
                      onPressed: () {
                        if (vm.solicitar()) app.refrescar();
                      },
                    ),
                  ],
                ),
              )
            else
              TarjetaSeccion(
                titulo: 'Viaje activo: ${activo.id}',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estado: ${activo.estado.name.toUpperCase()}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Estimado: ${formatearPesos(activo.estimadoCentavos)}'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilledButton(
                          onPressed: () {
                            if (vm.avanzar()) app.refrescar();
                          },
                          child: Text(switch (activo.estado) {
                            EstadoViaje.solicitado => 'Simular: Conductor acepta',
                            EstadoViaje.aceptado => 'Simular: Iniciar viaje',
                            EstadoViaje.enCurso => 'Simular: Finalizar y cobrar',
                            _ => 'Avanzar',
                          }),
                        ),
                        if (activo.estado != EstadoViaje.enCurso)
                          OutlinedButton(
                            onPressed: () {
                              if (vm.cancelar()) app.refrescar();
                            },
                            child: const Text('Cancelar'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            TarjetaSeccion(
              titulo: 'Historial de viajes (${vm.historial.length})',
              child: Column(
                children: vm.historial
                    .map((v) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text('${v.id} · ${v.estado.name}'),
                          trailing: Text(formatearPesos(v.cobradoCentavos ?? v.estimadoCentavos)),
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