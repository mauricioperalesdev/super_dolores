import 'package:flutter/material.dart';
import '../dominio/dinero.dart';
import '../dominio/plataforma.dart';
import '../vm/app_vm.dart';
import 'widgets.dart';

class PantallaInicio extends StatelessWidget {
  final AppVm app;
  const PantallaInicio({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    final activas = app.plataforma.registro.activas;
    final sug = app.sugerencia;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Encabezado con saldo y nivel
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, ${app.perfilActivo.nombre} 👋',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Saldo disponible'),
                        Text(
                          formatearPesos(app.saldo),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Chip(label: Text('${app.nivel.nombre} · ${app.puntos} pts')),
                        Text('🔥 Racha: ${app.racha} día(s)',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Siguiente mejor acción
        TarjetaSeccion(
          titulo: 'Sugerencia para ti',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Text(sug.servicio.emoji, style: const TextStyle(fontSize: 28)),
            title: Text(sug.servicio.nombre),
            subtitle: Text(sug.razon),
          ),
        ),

        // Grid de mini-apps activas
        TarjetaSeccion(
          titulo: 'Mini-Apps del ecosistema',
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.0,
            ),
            itemCount: activas.length,
            itemBuilder: (_, i) {
              final m = activas[i];
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => app.abrirMiniApp(m),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(m.emoji, style: const TextStyle(fontSize: 30)),
                      const SizedBox(height: 6),
                      Text(m.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Notificaciones recientes
        TarjetaSeccion(
          titulo: 'Avisos recientes (${app.notificaciones.length})',
          child: app.notificaciones.isEmpty
              ? const Text('Sin notificaciones por ahora.')
              : Column(
                  children: app.notificaciones
                      .take(4)
                      .map((n) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.notifications_active_outlined),
                            title: Text(n.titulo),
                            subtitle: Text(n.cuerpo),
                          ))
                      .toList(),
                ),
        ),
      ],
    );
  }
}