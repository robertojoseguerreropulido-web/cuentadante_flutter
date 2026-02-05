import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_proyecto_guia4/data/repositories/instructor_repository.dart';
import 'package:mi_proyecto_guia4/logic/bloc/Instructor_bloc/instructor_event.dart';
import 'package:mi_proyecto_guia4/logic/bloc/Instructor_bloc/instructor_state.dart';

class InstructorBloc extends Bloc<InstructorEvent, InstructorState> {
  InstructorRepository repository;

  InstructorBloc(this.repository) : super(InstructorInitial()) {
    on<LoadInstructores>(_onLoadInstructores);
    on<AddInstructor>(_onAddInstructor);
    on<UpdateInstructor>(_onUpdateInstructor);
    on<DeleteInstructor>(_onDeleteInstructor);
  }

  void _onLoadInstructores(
    LoadInstructores event,
    Emitter<InstructorState> emit,
  ) async {
    emit(InstructorLoading());
    try {
      final instructores = await repository.getAll();
      emit(InstructorLoaded(instructores));
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }

  Future<void> _onAddInstructor(
    AddInstructor event,
    Emitter<InstructorState> emit,
  ) async {
    try {
      await repository.addInstructor(event.instructor);
      add(LoadInstructores());
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }

  Future<void> _onUpdateInstructor(
    UpdateInstructor event,
    Emitter<InstructorState> emit,
  ) async {
    try {
      await repository.updateInstructor(event.instructor);
      add(LoadInstructores());
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }

  Future<void> _onDeleteInstructor(
    DeleteInstructor event,
    Emitter<InstructorState> emit,
  ) async {
    try {
      await repository.deleteInstructor(event.id);
      add(LoadInstructores());
    } catch (e) {
      emit(InstructorError(e.toString()));
    }
  }
}
