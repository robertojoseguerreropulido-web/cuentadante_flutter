import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_proyecto_guia4/data/repositories/cuentadante_repository.dart';
import 'package:mi_proyecto_guia4/logic/bloc/cuentadante_bloc/cuentadante_event.dart';
import 'package:mi_proyecto_guia4/logic/bloc/cuentadante_bloc/cuentadante_state.dart';

class CuentadanteBloc extends Bloc<CuentadanteEvent, CuentadanteState> {
  final CuentadanteRepository repository;
  StreamSubscription? _subscription;
  CuentadanteBloc(this.repository) : super(CuentadanteInitial()) {
    on<CuentadanteWatchByInstructorRequested>(_onWatchByInstructor);
    on<CuentadanteAssignManyRequested>(_onAssignMany);
    on<CuentadanteDevolverElementoRequested>(_onDevolverElemento);
  }

  // ====== STREAM: VER CUENTADANTES POR INSTRUCTOR ======
  Future<void> _onWatchByInstructor(
    CuentadanteWatchByInstructorRequested e,
    Emitter<CuentadanteState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = repository
        .watchByInstructor(e.instructorId, estado: e.estado)
        .listen(
          (items) {
            emit(CuentadanteListLoaded(items));
          },
          onError: (err) {
            emit(CuentadanteFailure(err.toString()));
          },
        );
  }

  // ====== ASIGNAR ELEMENTOS ======
  Future<void> _onAssignMany(
    CuentadanteAssignManyRequested e,
    Emitter<CuentadanteState> emit,
  ) async {
    try {
      final resultado = await repository.assignMany(
        instructorId: e.instructorId,
        elementoIds: e.elementoIds,
        observacion: e.observacion,
        instructorNombre: e.instructorNombre,
        elementoNombresById: e.elementoNombresById,
        createdBy: e.createdBy,
      );
      //feedback (SnackBar)
      emit(
        CuentadanteAssignManyResultState(
          createdIds: resultado.createdIds,
          conflicts: resultado.conflicts,
        ),
      ); // IMPORTANTE: NO cambie el estado base
      // el StreamBuilder seguirá recibiendo CuentadanteListLoaded
    } catch (e) {
      emit(CuentadanteFailure(e.toString()));
    }
  }

  //====== DEVOLVER ELEMENTO ======
  Future<void> _onDevolverElemento(
    CuentadanteDevolverElementoRequested elemento,
    Emitter<CuentadanteState> emit,
  ) async {
    try {
      await repository.devolverElemento(elemento.elementoId);
      //NO se emite nada el stream se actualiza solo
    } catch (e) {
      emit(CuentadanteFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
