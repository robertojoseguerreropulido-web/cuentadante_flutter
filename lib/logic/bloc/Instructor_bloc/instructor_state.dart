import 'package:equatable/equatable.dart';
import 'package:mi_proyecto_guia4/data/models/instructor_model.dart';

abstract class InstructorState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InstructorInitial extends InstructorState {}

class InstructorLoading extends InstructorState {}

class InstructorLoaded extends InstructorState {
  final List<InstructorModel> instructores;
  InstructorLoaded(this.instructores);

  @override
  List<Object?> get props => [instructores];
}

class InstructorError extends InstructorState {
  final String message;
  InstructorError(this.message);

  @override
  List<Object?> get props => [message];
}
