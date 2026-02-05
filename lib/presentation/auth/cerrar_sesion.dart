import 'package:flutter/material.dart';
import 'package:mi_proyecto_guia4/core/auth_service.dart';

class CerrarSesionButton extends StatefulWidget {
  const CerrarSesionButton({super.key});

  @override
  State<CerrarSesionButton> createState() => _CerrarSesionButtonState();
}

class _CerrarSesionButtonState extends State<CerrarSesionButton> {
  bool _loading = false;

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Seguro Que Deseas Cerrar Sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _loading = true);
    try {
      await AuthService.I.signOut();
      // El StreamBuilder en MyApp redirige al Login automáticamente.
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Cerrar Sesión',
      onPressed: _loading ? null : _signOut,
      icon: _loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.logout),
    );
  }
}
