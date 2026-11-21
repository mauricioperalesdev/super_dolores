import '../dominio/contexto.dart';
import '../dominio/mensajeria.dart';
import 'vm_base.dart';

class ChatVm extends VmBase {
  final ContextoMiniApp _ctx;
  String? chatCon;
  int _sec = 0;

  ChatVm(this._ctx);

  List<ResumenConversacion> get resumenes => _ctx.mensajes.resumenes();

  List<Mensaje> mensajesCon(String con) => _ctx.mensajes.conversacion(con);

  void abrirChat(String con) {
    chatCon = con;
    _ctx.mensajes.marcarLeidos(con);
    limpiarError();
    notifyListeners();
  }

  void cerrarChat() {
    chatCon = null;
    limpiarError();
    notifyListeners();
  }

  bool enviarTexto(String para, String texto) => ejecutar(() {
        _ctx.mensajes.enviar(para, texto);
      });

  bool enviarDinero(String para, int centavos) => ejecutar(() {
        _ctx.pagos.enviarDinero(para, centavos, clave: 'chat-${++_sec}');
      });
}