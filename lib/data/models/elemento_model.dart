import 'package:equatable/equatable.dart';

class ElementoModel extends Equatable {
  final String id;
  final String nombre;
  final String tipo;
  final String observacion;
  final String? foto;
  final String ambienteId;
  final String? publicId; // id interno en Cloudinary (para borrar)

  final bool asignado;
  final String? asignadoAInstructorId;
  final String? cuentadanteActivoId;

  const ElementoModel({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.observacion,
    this.foto,
    required this.ambienteId,
    this.publicId,

    this.asignado = false,
    this.asignadoAInstructorId,
    this.cuentadanteActivoId,
  });

  //Metodo copyWith//
  ElementoModel copyWith({
    String? id,
    String? nombre,
    String? tipo,
    String? observacion,
    String? foto,
    String? ambienteId,
    String? publicId,
    bool? asignado,
    String? asignadoAInstructorId,
    String? cuentadanteActivoId,
  }) {
    return ElementoModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      observacion: observacion ?? this.observacion,
      foto: foto ?? this.foto,
      ambienteId: ambienteId ?? this.ambienteId,
      publicId: publicId ?? this.publicId,

      asignado: asignado ?? this.asignado,
      asignadoAInstructorId:
          asignadoAInstructorId ?? this.asignadoAInstructorId,
      cuentadanteActivoId: cuentadanteActivoId ?? this.cuentadanteActivoId,
    );
  }

  factory ElementoModel.fromMap(Map<String, dynamic> map, String id) {
    return ElementoModel(
      id: id,
      nombre: map['Nombre'] ?? '',
      tipo: map['Tipo'] ?? '',
      observacion: map['Observacion'] ?? '',
      foto: map['Foto'],
      ambienteId: map['ambiente_id'] ?? '',
      publicId: map['public_id'],

      asignado: map['asignado'] ?? false,
      asignadoAInstructorId: map['asignadoAInstructorId'],
      cuentadanteActivoId: map['cuentadanteActivoId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Nombre': nombre,
      'Tipo': tipo,
      'Observacion': observacion,
      'Foto': foto,
      'ambiente_id': ambienteId,
      'public_id': publicId,
      'asignado': asignado,
      'asignadoAInstructorId': asignadoAInstructorId,
      'cuentadanteActivoId': cuentadanteActivoId,
    };
  }

  @override
  List<Object?> get props => [
    id,
    nombre,
    tipo,
    observacion,
    foto,
    ambienteId,
    publicId,

    asignado,
    asignadoAInstructorId,
    cuentadanteActivoId,
  ];

  @override
  String toString() =>
      'ElementoModel(id: $id, nombre: $nombre, foto: $foto, publicId: $publicId, ambienteId: $ambienteId, asignado: $asignado, asignadoAInstructorId: $asignadoAInstructorId, cuentadanteActivoId: $cuentadanteActivoId,)';
}
