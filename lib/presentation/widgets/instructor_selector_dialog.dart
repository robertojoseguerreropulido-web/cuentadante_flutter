import 'package:flutter/material.dart';
import 'package:mi_proyecto_guia4/data/models/instructor_model.dart';
import 'package:mi_proyecto_guia4/data/repositories/instructor_repository.dart';

class InstructorSelectorDialog extends StatefulWidget {
  final InstructorRepository repository;
  const InstructorSelectorDialog({super.key, required this.repository});

  @override
  State<InstructorSelectorDialog> createState() =>
      _InstructorSelectorDialogState();
}

class _InstructorSelectorDialogState extends State<InstructorSelectorDialog> {
  String? _selectedId;
  String? _selectedNombre;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar instructor'),
      content: SizedBox(
        width: 400,
        child: StreamBuilder<List<InstructorModel>>(
          stream: widget.repository.watchAll(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Error cargando instructores');
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final items = snapshot.data!;
            if (items.isEmpty) {
              return const Text('No hay instructores registrados');
            }
            return DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Instructor'),
              initialValue: _selectedId,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item.id,
                  child: Text(
                    item.nombreCompleto.isNotEmpty
                        ? item.nombreCompleto
                        : item.id,
                  ),
                );
              }).toList(),
              onChanged: (valor) {
                setState(() {
                  _selectedId = valor;
                  final found = items.firstWhere((item) => item.id == valor);
                  _selectedNombre = found.nombreCompleto;
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.check),
          label: const Text('Continuar'),
          onPressed: _selectedId == null
              ? null
              : () {
                  Navigator.pop(context, {
                    'id': _selectedId!,
                    'nombre': _selectedNombre,
                  });
                },
        ),
      ],
    );
  }
}
