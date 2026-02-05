import 'package:equatable/equatable.dart';

class InstructorModel extends Equatable {
  final String id;
  final String nombreCompleto;
  final String area;
  final String celular;
  final String cedula;

  const InstructorModel({
    required this.id,
    required this.nombreCompleto,
    required this.area,
    required this.celular,
    required this.cedula,
  });

  factory InstructorModel.fromMap(Map<String, dynamic> map, String id) {
    return InstructorModel(
      id: id,
      nombreCompleto: map['NombreCompleto'] ?? '',
      area: map['Area'] ?? '',
      celular: map['Celular'] ?? '',
      cedula: map['Cedula'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'NombreCompleto': nombreCompleto,
      'Area': area,
      'Celular': celular,
      'Cedula': cedula,
    };
  }

  @override
  List<Object?> get props => [id, nombreCompleto, area, celular, cedula];
}
