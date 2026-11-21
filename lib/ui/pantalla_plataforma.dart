import 'package:flutter/material.dart';
import '../dominio/dinero.dart';
import '../dominio/excepciones.dart';
import '../dominio/plataforma.dart';
import '../vm/app_vm.dart';
import 'widgets.dart';

class PantallaPlataforma extends StatefulWidget {
  final AppVm app;
  const PantallaPlataforma({super.key, required this.app});

  @override
  State<PantallaPlataforma> createState() => _PantallaPlataformaState();
}

class _PantallaPlataformaState extends State<PantallaPlataforma> {
  String _resultadoDemo = '';

  @override
  Widget build(BuildContext context) {
    final p = widget.app.plataforma;
    final hoy = p.reloj();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Programa de lealtad y canje
        TarjetaSeccion(
          titulo: 'Programa de Lealtad',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Puntos: ${widget.app.puntos} (${widget.app.nivel.nombre})'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: widget.app.puntos >= 100
                    ? () {
                        widget.app.canjearPuntos(100);
                      }
                    : null,
                child: const Text('Canjear 100 pts por \$10.00'),
              ),
            ],
          ),
        ),

        // Interruptor de apagado (Kill Switch)
        TarjetaSeccion(
          titulo: 'Control de Mini-Apps (Kill Switch)',
          child: Column(
            children: [
              Plataforma.miniChat,
              Plataforma.miniMonedero,
              Plataforma.miniTienda,
              Plataforma.miniViajes,
              Plataforma.miniHoroscopo,
            ].map((m) {
              final activa = p.registro.estaActiva(m.id);
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${m.emoji} ${m.nombre}'),
                subtitle: Text('Permisos: ${m.permisos.map((e) => e.name).join(', ')}'),
                value: activa,
                onChanged: (_) => widget.app.toggleMiniApp(m.id),
              );
            }).toList(),
          ),
        ),

        // Demostración de aislamiento de terceros
        TarjetaSeccion(
          titulo: 'Prueba de Sandbox (Tercero sin permisos)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Intenta leer el saldo desde la mini-app "Horóscopo":'),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  try {
                    final ctx = widget.app.contexto(Plataforma.miniHoroscopo);
                    ctx.monedero.saldo();
                  } catch (e) {
                    setState(() => _resultadoDemo = 'Bloqueado: ${mensajeSeguro(e)}');
                  }
                },
                child: const Text('Intentar leer saldo sin permiso'),
              ),
              if (_resultadoDemo.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(_resultadoDemo, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),

        // Analítica de retención
        TarjetaSeccion(
          titulo: 'Analítica de Retención',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DAU: ${p.analitica.dau(hoy)} · WAU: ${p.analitica.wau(hoy)} · MAU: ${p.analitica.mau(hoy)}'),
              Text('Stickiness (DAU/MAU): ${(p.analitica.stickiness(hoy) * 100).toStringAsFixed(1)}%'),
              Text('Ingresos plataforma (comisiones): ${formatearPesos(p.monedero.saldo('plataforma'))}'),
            ],
          ),
        ),
      ],
    );
  }
}