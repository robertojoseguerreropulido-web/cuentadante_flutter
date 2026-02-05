import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_proyecto_guia4/data/models/ambiente_model.dart';
import 'package:mi_proyecto_guia4/logic/bloc/ambiente_bloc/ambiente_bloc.dart';
import 'package:mi_proyecto_guia4/logic/bloc/ambiente_bloc/ambiente_event.dart';
import 'package:mi_proyecto_guia4/logic/bloc/ambiente_bloc/ambiente_state.dart';

class AmbienteScreen extends StatelessWidget {
  const AmbienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ambientes')),
      body: BlocBuilder<AmbienteBloc, AmbienteState>(
        builder: (context, state) {
          if (state is AmbienteLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AmbienteLoaded) {
            return ListView.builder(
              itemCount: state.ambientes.length,
              itemBuilder: (context, index) {
                final ambiente = state.ambientes[index];
                return ListTile(
                  title: Text(ambiente.nombre),
                  subtitle: Text('${ambiente.tipo} - ${ambiente.observacion}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      context.read<AmbienteBloc>().add(
                        DeleteAmbiente(ambiente.id),
                      );
                    },
                  ),
                  onTap: () {
                    _showAmbienteDialog(context, ambiente);
                  },
                );
              },
            );
          } //fin if
          else if (state is AmbienteError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No hay datos'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAmbienteDialog(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAmbienteDialog(BuildContext context, AmbienteModel? ambiente) {
    final nombreController = TextEditingController(
      text: ambiente?.nombre ?? '',
    );
    final tipoController = TextEditingController(text: ambiente?.tipo ?? '');
    final observacionController = TextEditingController(
      text: ambiente?.observacion ?? '',
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(ambiente == null ? 'Agregar Ambiente' : 'Editar Ambiente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: tipoController,
              decoration: const InputDecoration(labelText: 'Tipo'),
            ),
            TextField(
              controller: observacionController,
              decoration: const InputDecoration(labelText: 'Observación'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newAmbiente = AmbienteModel(
                id: ambiente?.id ?? '',
                nombre: nombreController.text,
                tipo: tipoController.text,
                observacion: observacionController.text,
              );
              if (ambiente == null) {
                context.read<AmbienteBloc>().add(AddAmbiente(newAmbiente));
              } else {
                context.read<AmbienteBloc>().add(UpdateAmbiente(newAmbiente));
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
