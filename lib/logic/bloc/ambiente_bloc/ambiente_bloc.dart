import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_proyecto_guia4/data/repositories/ambiente_repository.dart';
import 'ambiente_event.dart';
import 'ambiente_state.dart';

class AmbienteBloc extends Bloc<AmbienteEvent, AmbienteState> {
  final AmbienteRepository repository;

  AmbienteBloc(this.repository) : super(AmbienteInitial()) {
    on<LoadAmbientes>(_onLoadAmbientes);
    on<AddAmbiente>(_onAddAmbiente);
    on<UpdateAmbiente>(_onUpdateAmbiente);
    on<DeleteAmbiente>(_onDeleteAmbiente);
  }

  Future<void> _onLoadAmbientes(
    LoadAmbientes event,
    Emitter<AmbienteState> emit,
  ) async {
    emit(AmbienteLoading());
    try {
      final ambientes = await repository.getAll();
      emit(AmbienteLoaded(ambientes));
    } catch (e) {
      emit(AmbienteError(e.toString()));
    }
  }

  Future<void> _onAddAmbiente(
    AddAmbiente event,
    Emitter<AmbienteState> emit,
  ) async {
    try {
      await repository.add(event.ambiente);
      add(LoadAmbientes());
    } catch (e) {
      emit(AmbienteError(e.toString()));
    }
  }

  Future<void> _onUpdateAmbiente(
    UpdateAmbiente event,
    Emitter<AmbienteState> emit,
  ) async {
    try {
      await repository.update(event.ambiente);
      add(LoadAmbientes());
    } catch (e) {
      emit(AmbienteError(e.toString()));
    }
  }

  Future<void> _onDeleteAmbiente(
    DeleteAmbiente event,
    Emitter<AmbienteState> emit,
  ) async {
    try {
      await repository.delete(event.id);
      add(LoadAmbientes());
    } catch (e) {
      emit(AmbienteError(e.toString()));
    }
  }
}
