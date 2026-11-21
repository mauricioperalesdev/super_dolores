import 'package:flutter/material.dart';

class BannerError extends StatelessWidget {
  final String? mensaje;
  final VoidCallback? alCerrar;

  const BannerError(this.mensaje, {super.key, this.alCerrar});

  @override
  Widget build(BuildContext context) {
    if (mensaje == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje!,
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
            ),
          ),
          if (alCerrar != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: alCerrar,
            ),
        ],
      ),
    );
  }
}

class TarjetaSeccion extends StatelessWidget {
  final String titulo;
  final Widget child;
  final Widget? accion;

  const TarjetaSeccion({super.key, required this.titulo, required this.child, this.accion});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(titulo, style: Theme.of(context).textTheme.titleMedium),
                ),
                if (accion != null) accion!,
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}