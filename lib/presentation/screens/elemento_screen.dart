import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_proyecto_guia4/data/models/elemento_model.dart';
import 'package:mi_proyecto_guia4/logic/bloc/ambiente_bloc/ambiente_bloc.dart';
import 'package:mi_proyecto_guia4/logic/bloc/ambiente_bloc/ambiente_state.dart';
import 'package:mi_proyecto_guia4/logic/bloc/elemento_bloc/elemento_bloc.dart'
    as elemento_bloc;
import 'package:mi_proyecto_guia4/logic/bloc/elemento_bloc/elemento_event.dart';
import 'package:mi_proyecto_guia4/logic/bloc/elemento_bloc/elemento_state.dart';

class ElementoScreen extends StatelessWidget {
  const ElementoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<elemento_bloc.ElementoBloc, ElementoState>(
      listener: (context, state) {
        if (state is ElementoSuccess) {
          final msg = state.message;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        }
        if (state is ElementoError) {
          final msg = state.message;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Elementos Sena')),
        body: BlocBuilder<elemento_bloc.ElementoBloc, ElementoState>(
          builder: (context, state) {
            if (state is ElementoLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ElementoLoaded) {
              return _buildList(context, state);
            } else if (state is ElementoError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('No hay datos'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showElementoDialog(context, null),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, ElementoLoaded state) {
    return ListView.builder(
      itemCount: state.elementos.length,
      itemBuilder: (context, index) {
        final elemento = state.elementos[index];
        final hasFoto = (elemento.foto?.isNotEmpty ?? false);

        return ListTile(
          leading: hasFoto
              ? ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(6),
                  child: Image.network(
                    elemento.foto!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(Icons.image_not_supported),
          title: Text(elemento.nombre),
          subtitle: Text('${elemento.tipo} - ${elemento.observacion}'),
          trailing: IconButton(
            onPressed: () async {
              final bloc = context.read<elemento_bloc.ElementoBloc>();
              final elementoId = elemento.id;

              final confirm = await _confirmDelete(context);
              if (confirm == true) {
                bloc.add(DeleteElemento(elementoId));
              }
            },
            icon: const Icon(Icons.delete),
            tooltip: 'Eliminar',
          ),
          onTap: () => _showElementoDialog(context, elemento),
        );
      },
    );
  }

  //Cuadro de dialogo de confirmacion de eliminar
  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Eliminación de Elemento'),
        content: const Text(
          '¿Desea Eliminar Este Elemento? Esta acción no se puede deshacer',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: Icon(Icons.delete),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  //Fromulario para Crear y Editar elementos
  void _showElementoDialog(BuildContext context, ElementoModel? elemento) {
    //Definicion controladores de Texto
    final nombreController = TextEditingController(
      text: elemento?.nombre ?? '',
    );
    final tipoController = TextEditingController(text: elemento?.tipo ?? '');
    final observacionController = TextEditingController(
      text: elemento?.observacion ?? '',
    );
    //variables estado local
    String? fotoUrl = elemento?.foto;
    String? selectedAmbienteId = elemento?.ambienteId;
    String? imagePath;
    bool removeFoto = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dCtx) {
        return StatefulBuilder(
          builder: (localCtx, setStateDialog) {
            //Seleccionar imagen desde la galearia
            Future<void> pickImage() async {
              final messenger = ScaffoldMessenger.of(dCtx);
              try {
                final picker = ImagePicker();
                final XFile? picked = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (picked == null) {
                  return;
                }
                setStateDialog(() {
                  imagePath = picked.path;
                  removeFoto = false;
                });
                messenger.showSnackBar(
                  const SnackBar(content: Text('Imagen Seleccionada')),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Error al seleccionar la imagen: $e')),
                );
              }
            }

            //Alert Dialog completo
            return AlertDialog(
              title: Text(
                elemento == null ? 'Adicionar Elemento' : 'Editar Elemento',
              ),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Elemento',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: tipoController,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Elemento',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: observacionController,
                        decoration: InputDecoration(
                          labelText: 'Observación del Elemento',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      //Control de imagen
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: pickImage,
                            icon: const Icon(Icons.photo),
                            label: Text(
                              imagePath == null
                                  ? 'Seleccionar Foto'
                                  : 'Foto Seleccionada',
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilterChip(
                            selected: removeFoto,
                            onSelected: (sel) {
                              setStateDialog(() {
                                removeFoto = sel;
                                if (removeFoto) {
                                  imagePath = null;
                                }
                              });
                            },
                            label: const Text('Quitar foto'),
                            selectedColor: Colors.red.shade100,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildPreviewImage(
                            imagePath: imagePath,
                            fotoUrl: fotoUrl,
                            removeFoto: removeFoto,
                          ),
                        ),
                      ),
                      //Selector de ambientes.
                      BlocBuilder<AmbienteBloc, AmbienteState>(
                        builder: (context, ambienteState) {
                          if (ambienteState is AmbienteLoading) {
                            return const LinearProgressIndicator();
                          }
                          if (ambienteState is AmbienteLoaded) {
                            final ambientes = ambienteState.ambientes;
                            return SizedBox(
                              width: double.maxFinite,
                              child: DropdownButtonFormField<String>(
                                initialValue:
                                    (selectedAmbienteId?.isNotEmpty ?? false)
                                    ? selectedAmbienteId
                                    : null,
                                decoration: const InputDecoration(
                                  labelText: 'Ambientes',
                                  border: OutlineInputBorder(),
                                ),
                                items: ambientes
                                    .map(
                                      (ambiente) => DropdownMenuItem<String>(
                                        value: ambiente.id,
                                        child: Text(ambiente.nombre),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (valor) => setStateDialog(
                                  () => selectedAmbienteId = valor,
                                ),
                                validator: (valor) =>
                                    (valor == null || valor.isEmpty)
                                    ? 'Seleccione un Ambiente'
                                    : null,
                              ),
                            );
                          }
                          if (AmbienteState is AmbienteError) {
                            return Text(
                              'Error cargando ambientes:',
                              style: const TextStyle(color: Colors.red),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              //Acciones
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dCtx, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar'),
                  onPressed: () {
                    final messenger = ScaffoldMessenger.of(dCtx);
                    if (selectedAmbienteId == null ||
                        selectedAmbienteId!.isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Seleccione un Ambiente')),
                      );
                      return;
                    }
                    if (nombreController.text.trim().isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Ingrese el nombre del elemento'),
                        ),
                      );
                      return;
                    }
                    if (tipoController.text.trim().isEmpty) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Ingrese el tipo del elemento'),
                        ),
                      );
                      return;
                    }
                    //contruir el elemento con copyWhit.
                    final actualizado =
                        elemento?.copyWith(
                          nombre: nombreController.text.trim(),
                          tipo: tipoController.text.trim(),
                          observacion: observacionController.text.trim(),
                          ambienteId: selectedAmbienteId,
                        ) ??
                        ElementoModel(
                          id: '',
                          nombre: nombreController.text.trim(),
                          tipo: tipoController.text.trim(),
                          observacion: observacionController.text.trim(),
                          ambienteId: selectedAmbienteId!,
                          foto: null,
                        );
                    //Capturar el bloc antes de enviar
                    final bloc = context.read<elemento_bloc.ElementoBloc>();
                    //Emitir el evento Bloc.
                    if (elemento == null) {
                      bloc.add(
                        AddElementoConFoto(
                          elemento: actualizado,
                          imagePath: imagePath,
                        ),
                      );
                    } else {
                      bloc.add(
                        UpdateElementoConFoto(
                          elemento: actualizado,
                          imagePath: imagePath,
                          removeFoto: removeFoto,
                        ),
                      );
                    }
                    Navigator.pop(dCtx, true);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  //Contruccion del preview de imagen.
  Widget _buildPreviewImage({
    required String? imagePath,
    required String? fotoUrl,
    required bool removeFoto,
  }) {
    final hasNewLocal = (imagePath?.isNotEmpty ?? false);
    final hasExisting = (fotoUrl?.isNotEmpty ?? false);

    if (hasNewLocal) {
      return AspectRatio(
        aspectRatio: 4 / 3,
        child: Image.file(File(imagePath!), fit: BoxFit.cover),
      );
    }
    if (removeFoto) {
      return _placeholderPreview('Sin Foto');
    }

    if (hasExisting) {
      return AspectRatio(
        aspectRatio: 4 / 3,
        child: Image.network(fotoUrl!, fit: BoxFit.cover),
      );
    }
    return _placeholderPreview('No Hay Foto');
  }

  Widget _placeholderPreview(String text) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Center(
        child: Text(text, style: TextStyle(color: Colors.grey.shade700)),
      ),
    );
  }
}
