import 'package:equatable/equatable.dart';
import 'package:mi_proyecto_guia4/data/models/ambiente_model.dart';

abstract class AmbienteState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AmbienteInitial extends AmbienteState {}

class AmbienteLoading extends AmbienteState {}

class AmbienteLoaded extends AmbienteState {
  final List<AmbienteModel> ambientes;
  AmbienteLoaded(this.ambientes);

  @override
  List<Object?> get props => [ambientes];
}

class AmbienteError extends AmbienteState {
  final String message;
  AmbienteError(this.message);

  @override
  List<Object?> get props => [message];
}
