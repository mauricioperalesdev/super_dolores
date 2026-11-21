import 'package:flutter/material.dart';
import 'dominio/plataforma.dart';
import 'ui/mini_chat.dart';
import 'ui/mini_monedero.dart';
import 'ui/mini_tienda.dart';
import 'ui/mini_viajes.dart';
import 'ui/pantalla_inicio.dart';
import 'ui/pantalla_plataforma.dart';
import 'vm/app_vm.dart';
import 'vm/chat_vm.dart';
import 'vm/monedero_vm.dart';
import 'vm/tienda_vm.dart';
import 'vm/viajes_vm.dart';

void main() {
  final plataforma = Plataforma()..cargarDatosDemo();
  runApp(SuperDoloresApp(app: AppVm(plataforma)));
}

class SuperDoloresApp extends StatelessWidget {
  final AppVm app;
  const SuperDoloresApp({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Dolores',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
        useMaterial3: true,
      ),
      home: ShellSuperApp(app: app),
    );
  }
}

class ShellSuperApp extends StatelessWidget {
  final AppVm app;
  const ShellSuperApp({super.key, required this.app});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (_, __) {
        final abierta = app.miniAppAbierta;

        return Scaffold(
          appBar: AppBar(
            leading: abierta != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: app.cerrarMiniApp,
                  )
                : null,
            title: Text(abierta != null ? '${abierta.emoji} ${abierta.nombre}' : 'Super Dolores'),
            actions: [
              DropdownButton<String>(
                value: app.usuarioId,
                underline: const SizedBox.shrink(),
                items: app.plataforma.perfiles
                    .map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombre)))
                    .toList(),
                onChanged: (id) {
                  if (id != null) app.cambiarUsuario(id);
                },
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: abierta != null
              ? _construirMiniApp(abierta.id)
              : (app.tab == 0 ? PantallaInicio(app: app) : PantallaPlataforma(app: app)),
          bottomNavigationBar: abierta != null
              ? null
              : NavigationBar(
                  selectedIndex: app.tab,
                  onDestinationSelected: app.cambiarTab,
                  destinations: const [
                    NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Inicio'),
                    NavigationDestination(icon: Icon(Icons.hub_outlined), label: 'Plataforma'),
                  ],
                ),
        );
      },
    );
  }

  Widget _construirMiniApp(String id) {
    switch (id) {
      case 'chat':
        return MiniChatScreen(
          app: app,
          vm: ChatVm(app.contexto(Plataforma.miniChat)),
        );
      case 'monedero':
        return MiniMonederoScreen(
          app: app,
          vm: MonederoVm(app.contexto(Plataforma.miniMonedero)),
        );
      case 'tienda':
        return MiniTiendaScreen(
          app: app,
          vm: TiendaVm(app.contexto(Plataforma.miniTienda)),
        );
      case 'viajes':
        return MiniViajesScreen(
          app: app,
          vm: ViajesVm(app.contexto(Plataforma.miniViajes)),
        );
      default:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              '🔮 Horóscopo de Dolores:\n"Hoy es un buen día para programar en Dart con arquitectura limpia."',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
        );
    }
  }
}