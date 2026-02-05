import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_proyecto_guia4/data/models/elemento_model.dart';

import 'package:mi_proyecto_guia4/data/repositories/elemento_repository.dart';
import 'package:mi_proyecto_guia4/logic/bloc/cuentadante_bloc/cuentadante_bloc.dart';
import 'package:mi_proyecto_guia4/logic/bloc/cuentadante_bloc/cuentadante_event.dart';
import 'package:mi_proyecto_guia4/logic/bloc/cuentadante_bloc/cuentadante_state.dart';

class CuentadanteScreen extends StatefulWidget {
  final String instructorId;
  final String? instructorNombre;

  const CuentadanteScreen({
    super.key,
    required this.instructorId,
    this.instructorNombre,
  });

  @override
  State<CuentadanteScreen> createState() => _CuentadanteScreenState();
}

class _CuentadanteScreenState extends State<CuentadanteScreen> {
  final observacionCtrl = TextEditingController();

  /// elementoId -> elementoNombre
  final Map<String, String> selected = {};

  late final ElementoRepository elementosRepo;

  @override
  void initState() {
    super.initState();
    elementosRepo = context
        .read<ElementoRepository>(); //Inyeccion ElementoRepository
    context.read<CuentadanteBloc>().add(
      //IMPORTANTE: este evento es el que carga los cuentadantes asignados
      CuentadanteWatchByInstructorRequested(
        widget.instructorId,
        estado: 'asignado',
      ),
    );
  }

  @override
  void dispose() {
    observacionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nombreInstructor = widget.instructorNombre ?? widget.instructorId;

    return Scaffold(
      appBar: AppBar(title: Text('Cuentadante - $nombreInstructor')),
      body: Column(
        children: [
          //Campo Observación
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: observacionCtrl,
              decoration: const InputDecoration(
                labelText: 'Observación (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          //Mostrar elementos disponibles
          Expanded(
            flex: 2,
            child: StreamBuilder<List<ElementoModel>>(
              stream: elementosRepo
                  .watchDisponibles(), //devulve elementos con asignadoActivo = false
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error cargando elementos'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data!;
                if (items.isEmpty) {
                  return const Center(
                    child: Text('No hay elementos disponibles'),
                  );
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final e = items[i];
                    final checked = selected.containsKey(e.id);

                    return CheckboxListTile(
                      value: checked,
                      title: Text(e.nombre),
                      subtitle: Text(
                        'Tipo: ${e.tipo} • Ambiente: ${e.ambienteId}',
                      ),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            selected[e.id] = e.nombre;
                          } else {
                            selected.remove(e.id);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),

          //Botón para Asignar Elemento
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.assignment_turned_in),
              label: const Text('Asignar elementos'),
              onPressed: selected.isEmpty
                  ? null
                  : () {
                      //Obtener el uid del usuario
                      final uid =
                          FirebaseAuth.instance.currentUser?.uid ??
                          'desconocido';
                      context.read<CuentadanteBloc>().add(
                        CuentadanteAssignManyRequested(
                          instructorId: widget.instructorId,
                          elementoIds: selected.keys.toList(),
                          observacion: observacionCtrl.text,
                          instructorNombre: widget.instructorNombre,
                          elementoNombresById: selected,
                          createdBy:
                              uid, //'uid-actual', //Reemplazar por el usuario logueado
                        ),
                      );
                    },
            ),
          ),
          const Divider(thickness: 2),

          //====== ELEMENTOS ASIGNADOS AL INSTRUCTOR (desde ElementoRepository) ======
          Expanded(
            child: StreamBuilder<List<ElementoModel>>(
              stream: elementosRepo.watchAsignadosAInstructor(
                widget.instructorId,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error cargando asignados'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final asignados = snapshot.data!;
                if (asignados.isEmpty) {
                  return const Center(
                    child: Text('Este instructor no tiene elementos asignados'),
                  );
                }
                return ListView.builder(
                  itemCount: asignados.length,
                  itemBuilder: (_, i) {
                    final e = asignados[i];
                    return ListTile(
                      leading: const Icon(Icons.inventory_2),
                      title: Text(e.nombre),
                      subtitle: Text(
                        'Tipo: ${e.tipo} • Ambiente: ${e.ambienteId}',
                      ),
                      trailing: IconButton(
                        tooltip: 'Devolver',
                        icon: const Icon(Icons.undo),
                        onPressed: () {
                          // Dispara el evento de devolución
                          context.read<CuentadanteBloc>().add(
                            CuentadanteDevolverElementoRequested(e.id),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          //Feedback
          BlocListener<CuentadanteBloc, CuentadanteState>(
            listener: (context, state) {
              if (state is CuentadanteAssignManyResultState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Asignados: ${state.createdIds.length} • '
                      'Conflictos: ${state.conflicts.length}',
                    ),
                  ),
                );

                if (state.createdIds.isNotEmpty) {
                  setState(() {
                    selected.clear();
                    observacionCtrl.clear();
                  });
                }
              }
            },
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
