import 'package:equatable/equatable.dart';
import 'package:mi_proyecto_guia4/data/models/ambiente_model.dart';

abstract class AmbienteEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAmbientes extends AmbienteEvent {}

class AddAmbiente extends AmbienteEvent {
  final AmbienteModel ambiente;
  AddAmbiente(this.ambiente);

  @override
  List<Object?> get props => [ambiente];
}

class UpdateAmbiente extends AmbienteEvent {
  final AmbienteModel ambiente;
  UpdateAmbiente(this.ambiente);

  @override
  List<Object?> get props => [ambiente];
}

class DeleteAmbiente extends AmbienteEvent {
  final String id;
  DeleteAmbiente(this.id);

  @override
  List<Object?> get props => [id];
}
