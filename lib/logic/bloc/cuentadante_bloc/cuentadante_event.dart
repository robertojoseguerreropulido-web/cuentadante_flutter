import 'package:equatable/equatable.dart';

abstract class CuentadanteEvent extends Equatable {
  const CuentadanteEvent();
  @override
  List<Object?> get props => [];
}

class CuentadanteWatchByInstructorRequested extends CuentadanteEvent {
  final String instructorId;
  final String? estado; //asignado o devuelto
  const CuentadanteWatchByInstructorRequested(this.instructorId, {this.estado});
}

class CuentadanteAssignManyRequested extends CuentadanteEvent {
  final String instructorId;
  final List<String> elementoIds;
  final String? observacion;
  final String? instructorNombre;
  final Map<String, String>? elementoNombresById;
  final String? createdBy;

  const CuentadanteAssignManyRequested({
    required this.instructorId,
    required this.elementoIds,
    this.observacion,
    this.instructorNombre,
    this.elementoNombresById,
    this.createdBy,
  });
}

class CuentadanteDevolverElementoRequested extends CuentadanteEvent {
  final String elementoId;
  const CuentadanteDevolverElementoRequested(this.elementoId);
}
