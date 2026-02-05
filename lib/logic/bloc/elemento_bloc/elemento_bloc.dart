import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_proyecto_guia4/core/cloudinary_service.dart';
import 'package:mi_proyecto_guia4/data/models/elemento_model.dart';
import 'package:mi_proyecto_guia4/data/repositories/elemento_repository.dart';
import 'package:mi_proyecto_guia4/logic/bloc/elemento_bloc/elemento_event.dart';
import 'package:mi_proyecto_guia4/logic/bloc/elemento_bloc/elemento_state.dart';

class ElementoBloc extends Bloc<ElementoEvent, ElementoState> {
  final ElementoRepository repository;
  final CloudinaryService cloudinary;

  ElementoBloc(this.repository, this.cloudinary) : super(ElementoInitial()) {
    on<LoadElementos>(_onLoadElementos);
    on<AddElemento>(_onAddElemento);
    on<UpdateElemento>(_onUpdateElemento);
    on<DeleteElemento>(_onDeleteElemento);
    //Con Foto.
    on<AddElementoConFoto>(_onAddElementoConFoto);
    on<UpdateElementoConFoto>(_onUpdateElementoConFoto);
  }

  Future<void> _onLoadElementos(
    LoadElementos event,
    Emitter<ElementoState> emit,
  ) async {
    emit(ElementoLoading());
    try {
      final elementos = await repository.getAll();
      emit(ElementoLoaded(elementos));
    } catch (e) {
      emit(ElementoError(e.toString()));
    }
  }

  Future<void> _onAddElemento(
    AddElemento event,
    Emitter<ElementoState> emit,
  ) async {
    try {
      await repository.addElemento(event.elemento);
      emit(const ElementoSuccess('Elemento agregado correctamente'));
      add(LoadElementos());
    } catch (e) {
      emit(ElementoError(e.toString()));
    }
  }

  Future<void> _onUpdateElemento(
    UpdateElemento event,
    Emitter<ElementoState> emit,
  ) async {
    try {
      await repository.update(event.elemento);
      emit(const ElementoSuccess('Elemento actualizado correctamente'));
      add(LoadElementos());
    } catch (e) {
      emit(ElementoError(e.toString()));
    }
  }

  Future<void> _onDeleteElemento(
    DeleteElemento event,
    Emitter<ElementoState> emit,
  ) async {
    try {
      emit(ElementoLoading());
      await repository.delete(event.id);
      add(LoadElementos());
      emit(const ElementoSuccess('Elemento eliminado correctamente'));
    } catch (e) {
      emit(ElementoError(e.toString()));
    }
  }

  Future<void> _onAddElementoConFoto(
    AddElementoConFoto event,
    Emitter<ElementoState> emit,
  ) async {
    try {
      emit(ElementoLoading());
      ElementoModel elementoAdcionar = event.elemento;
      if (event.imagePath != null && event.imagePath!.isNotEmpty) {
        final file = File(event.imagePath!);
        final upload = await cloudinary.uploadImageFile(
          file,
          folder: 'elementos',
        );
        elementoAdcionar = elementoAdcionar.copyWith(
          foto: upload.url,
          publicId: upload.publicId,
        );
      }
      await repository.addElemento(elementoAdcionar);
      add(LoadElementos());
      emit(const ElementoSuccess('Elemento creado correctamente'));
    } catch (e) {
      emit(ElementoError(e.toString()));
    }
  }

  Future<void> _onUpdateElementoConFoto(
    UpdateElementoConFoto event,
    Emitter<ElementoState> emit,
  ) async {
    try {
      emit(ElementoLoading());
      final oldPublicId = event.elemento.publicId;
      final oldFotoUrl = event.elemento.foto;
      String? finalFotoUrl;
      String? finalPublicId;
      if (event.removeFoto) {
        //Caso 1: Quitar Foto
        finalFotoUrl = null;
        finalPublicId = null;

        if (oldPublicId != null && oldPublicId.isNotEmpty) {
          try {
            await cloudinary.deleteImage(publicId: oldPublicId);
          } catch (e) {
            emit(ElementoError(e.toString()));
          }
        }
      } else if (event.imagePath != null && event.imagePath!.isNotEmpty) {
        //Caso 2: Reemplazar la imagen por la nueva.
        final file = File(event.imagePath!);
        final upload = await cloudinary.uploadImageFile(
          file,
          folder: 'elementos',
        );
        finalFotoUrl = upload.url;
        finalPublicId = upload.publicId;

        //Eliminar Foto anterior
        if (oldPublicId != null && oldPublicId.isNotEmpty) {
          try {
            await cloudinary.deleteImage(publicId: oldPublicId);
          } catch (e) {
            emit(ElementoError(e.toString()));
          }
        }
      } else {
        //Caso 3: Conservar la foto anterior si no hay cambios
        finalFotoUrl = oldFotoUrl;
        finalPublicId = oldPublicId;
      }
      //Actualizar el modelo
      final elementoActualizado = event.elemento.copyWith(
        foto: finalFotoUrl,
        publicId: finalPublicId,
      );
      await repository.update(elementoActualizado);
      add(LoadElementos());
      emit(const ElementoSuccess('Elemento Actualizado Correctamente'));
    } catch (e, st) {
      debugPrint('[Bloc] UpdateElementoConFoto error: $e\n$st');
    }
  }
}
