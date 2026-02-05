import 'package:equatable/equatable.dart';
import 'package:mi_proyecto_guia4/data/models/instructor_model.dart';

abstract class InstructorEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadInstructores extends InstructorEvent {}

class AddInstructor extends InstructorEvent {
  final InstructorModel instructor;
  AddInstructor(this.instructor);

  @override
  List<Object?> get props => [instructor];
}

class UpdateInstructor extends InstructorEvent {
  final InstructorModel instructor;
  UpdateInstructor(this.instructor);

  @override
  List<Object?> get props => [instructor];
}

class DeleteInstructor extends InstructorEvent {
  final String id;
  DeleteInstructor(this.id);

  @override
  List<Object?> get props => [id];
}
