import 'package:flutter/material.dart';
import '../dominio/mensajeria.dart';
import '../vm/app_vm.dart';
import '../vm/chat_vm.dart';
import 'widgets.dart';

class MiniChatScreen extends StatefulWidget {
  final AppVm app;
  final ChatVm vm;
  const MiniChatScreen({super.key, required this.app, required this.vm});

  @override
  State<MiniChatScreen> createState() => _MiniChatScreenState();
}

class _MiniChatScreenState extends State<MiniChatScreen> {
  final _txtCtrl = TextEditingController();
  final _montoCtrl = TextEditingController(text: '50');

  @override
  void dispose() {
    _txtCtrl.dispose();
    _montoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.vm,
      builder: (_, __) {
        final con = widget.vm.chatCon;
        if (con == null) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              BannerError(widget.vm.error, alCerrar: widget.vm.limpiarError),
              TarjetaSeccion(
                titulo: 'Contactos',
                child: Column(
                  children: widget.app.contactos
                      .map((c) => ListTile(
                            leading: CircleAvatar(child: Text(c.nombre[0])),
                            title: Text(c.nombre),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => widget.vm.abrirChat(c.id),
                          ))
                      .toList(),
                ),
              ),
              if (widget.vm.resumenes.isNotEmpty)
                TarjetaSeccion(
                  titulo: 'Conversaciones recientes',
                  child: Column(
                    children: widget.vm.resumenes
                        .map((r) => ListTile(
                              title: Text(r.con.toUpperCase()),
                              subtitle: Text(r.ultimo.texto),
                              trailing: r.noLeidos > 0
                                  ? CircleAvatar(radius: 12, child: Text('${r.noLeidos}'))
                                  : null,
                              onTap: () => widget.vm.abrirChat(r.con),
                            ))
                        .toList(),
                  ),
                ),
            ],
          );
        }

        final msgs = widget.vm.mensajesCon(con);
        return Column(
          children: [
            MaterialBanner(
              content: Text('Chat con ${con.toUpperCase()}'),
              actions: [
                TextButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                  onPressed: widget.vm.cerrarChat,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: BannerError(widget.vm.error, alCerrar: widget.vm.limpiarError),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: msgs.length,
                itemBuilder: (_, i) {
                  final m = msgs[i];
                  final mio = m.de == widget.app.usuarioId;
                  return Align(
                    alignment: mio ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: m.tipo == TipoMensaje.dinero
                            ? Colors.green.shade100
                            : (mio
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).colorScheme.surfaceContainerHighest),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(m.texto),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _txtCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Escribe un mensaje...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          if (widget.vm.enviarTexto(con, _txtCtrl.text)) {
                            _txtCtrl.clear();
                            widget.app.refrescar();
                          }
                        },
                        child: const Icon(Icons.send),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(
                        width: 110,
                        child: TextField(
                          controller: _montoCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Pesos \$',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.attach_money),
                        label: const Text('Enviar dinero en chat'),
                        onPressed: () {
                          final pesos = int.tryParse(_montoCtrl.text) ?? 0;
                          if (widget.vm.enviarDinero(con, pesos * 100)) {
                            widget.app.refrescar();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}