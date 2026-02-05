import 'package:equatable/equatable.dart';
import 'package:mi_proyecto_guia4/data/models/elemento_model.dart';

abstract class ElementoEvent extends Equatable {
  const ElementoEvent();

  @override
  List<Object?> get props => [];
}

class LoadElementos extends ElementoEvent {
  const LoadElementos();
}

class AddElemento extends ElementoEvent {
  final ElementoModel elemento;
  const AddElemento(this.elemento);

  @override
  List<Object?> get props => [elemento];
}

class UpdateElemento extends ElementoEvent {
  final ElementoModel elemento;
  const UpdateElemento(this.elemento);

  @override
  List<Object?> get props => [elemento];
}

class DeleteElemento extends ElementoEvent {
  final String id;
  const DeleteElemento(this.id);

  @override
  List<Object?> get props => [id];
}

/// Crear elemento con foto
class AddElementoConFoto extends ElementoEvent {
  final ElementoModel elemento;
  final String? imagePath; // ruta local del archivo (ImagePicker)

  const AddElementoConFoto({required this.elemento, this.imagePath});

  @override
  List<Object?> get props => [elemento, imagePath];
}

//Modificar elemento con foto(quitar, reemplazar o conservar)
class UpdateElementoConFoto extends ElementoEvent {
  final ElementoModel elemento;
  final String? imagePath;
  final bool removeFoto;

  const UpdateElementoConFoto({
    required this.elemento,
    this.imagePath,
    this.removeFoto = false,
  });

  /// Útil para saber si se seleccionó nueva imagen
  bool get hasNewImage => (imagePath?.isNotEmpty ?? false);

  @override
  List<Object?> get props => [elemento, imagePath, removeFoto];

  @override
  String toString() =>
      'UpdateElementoConFoto(elemento: ${elemento.id}, imagePath: $imagePath, removeFoto: $removeFoto)';
}
