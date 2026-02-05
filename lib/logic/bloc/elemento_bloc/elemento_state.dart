import 'package:equatable/equatable.dart';
import 'package:mi_proyecto_guia4/data/models/elemento_model.dart';

abstract class ElementoState extends Equatable {
  const ElementoState();

  @override
  List<Object?> get props => [];
}

class ElementoInitial extends ElementoState {
  const ElementoInitial();
}

class ElementoLoading extends ElementoState {
  const ElementoLoading();
}

class ElementoLoaded extends ElementoState {
  final List<ElementoModel> elementos;

  const ElementoLoaded(this.elementos);

  @override
  List<Object?> get props => [elementos];
}

class ElementoError extends ElementoState {
  final String message;

  const ElementoError(this.message);

  @override
  List<Object?> get props => [message];
}

/// (Opcional) Útil para mostrar un snackbar/toast específico
class ElementoSuccess extends ElementoState {
  final String message;

  const ElementoSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
