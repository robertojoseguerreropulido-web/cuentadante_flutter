import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_proyecto_guia4/data/models/instructor_model.dart';
import 'package:mi_proyecto_guia4/logic/bloc/Instructor_bloc/instructor_bloc.dart';
import 'package:mi_proyecto_guia4/logic/bloc/Instructor_bloc/instructor_event.dart';
import 'package:mi_proyecto_guia4/logic/bloc/Instructor_bloc/instructor_state.dart';

class InstructorScreen extends StatelessWidget {
  const InstructorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Instructores Sena')),
      body: BlocBuilder<InstructorBloc, InstructorState>(
        builder: (context, state) {
          if (state is InstructorLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is InstructorLoaded) {
            return ListView.builder(
              itemCount: state.instructores.length,
              itemBuilder: (context, index) {
                final instructor = state.instructores[index];
                return ListTile(
                  title: Text(instructor.nombreCompleto),
                  subtitle: Text('${instructor.area} * ${instructor.celular}'),
                  trailing: IconButton(
                    onPressed: () {
                      context.read<InstructorBloc>().add(
                        DeleteInstructor(instructor.id),
                      );
                    },
                    icon: const Icon(Icons.delete),
                  ),
                  onTap: () {
                    _showInstructorDialog(context, instructor);
                  },
                );
              },
            );
          } else if (state is InstructorError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No hay Datos de Instructores'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showInstructorDialog(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  //Metodo _showInstructorDialog//
  void _showInstructorDialog(
    BuildContext context,
    InstructorModel? instructor,
  ) {
    final nombreCompletoController = TextEditingController(
      text: instructor?.nombreCompleto ?? '',
    );
    final areaController = TextEditingController(text: instructor?.area ?? '');
    final celularController = TextEditingController(
      text: instructor?.celular ?? '',
    );
    final cedulacontroller = TextEditingController(
      text: instructor?.cedula ?? '',
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          instructor == null ? 'Adicionar Instructor' : 'Editar Instructor',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            TextField(
              controller: nombreCompletoController,
              decoration: const InputDecoration(
                labelText: 'Nombre Del Instructor',
              ),
            ),
            TextField(
              controller: areaController,
              decoration: const InputDecoration(
                labelText: 'Area Del Instructor',
              ),
            ),
            TextField(
              controller: celularController,
              decoration: const InputDecoration(labelText: 'Número Celular'),
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: cedulacontroller,
              decoration: const InputDecoration(labelText: 'Número Documento'),
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
              final newInstructor = InstructorModel(
                id: instructor?.id ?? '',
                nombreCompleto: nombreCompletoController.text.trim(),
                area: areaController.text.trim(),
                celular: celularController.text.trim(),
                cedula: cedulacontroller.text.trim(),
              );
              if (instructor == null) {
                context.read<InstructorBloc>().add(
                  AddInstructor(newInstructor),
                );
              } else {
                context.read<InstructorBloc>().add(
                  UpdateInstructor(newInstructor),
                );
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
