import 'package:equatable/equatable.dart';
import 'package:mi_proyecto_guia4/data/models/cuentadante_model.dart';

abstract class CuentadanteState extends Equatable {
  const CuentadanteState();
  @override
  List<Object?> get props => [];
}

class CuentadanteInitial extends CuentadanteState {}

class CuentadanteLoading extends CuentadanteState {}

class CuentadanteListLoaded extends CuentadanteState {
  final List<CuentadanteModel> items;
  const CuentadanteListLoaded(this.items);
  @override
  List<Object?> get props => [items];
}

class CuentadanteAssignManyResultState extends CuentadanteState {
  final List<String> createdIds;
  final List<String> conflicts;
  const CuentadanteAssignManyResultState({
    required this.createdIds,
    required this.conflicts,
  });
  @override
  List<Object?> get props => [createdIds, conflicts];
}

class CuentadanteFailure extends CuentadanteState {
  final String message;
  const CuentadanteFailure(this.message);
  @override
  List<Object?> get props => [message];
}
