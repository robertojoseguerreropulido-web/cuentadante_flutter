import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CuentadanteModel extends Equatable {
  final String id;
  final String observacion;

  /// Puede llegar null al inicio cuando se usa serverTimestamp
  final DateTime? fechaAsignacion;

  /// 'asignado' | 'devuelto'
  final String estado;
  final DateTime? fechaDevolucion;

  // Relaciones por ID (obligatorio)
  final String instructorId;
  final String elementoId;

  // Denormalización para UI
  final String? instructorNombre;
  final String? elementoNombre;

  // Evidencia opcional (Cloudinary)
  final String? actaUrl;
  final String? actaPublicId;

  // Auditoría
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;

  const CuentadanteModel({
    required this.id,
    required this.observacion,
    required this.fechaAsignacion,
    required this.estado,
    this.fechaDevolucion,
    required this.instructorId,
    required this.elementoId,
    this.instructorNombre,
    this.elementoNombre,
    this.actaUrl,
    this.actaPublicId,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
  });

  CuentadanteModel copyWith({
    String? id,
    String? observacion,
    DateTime? fechaAsignacion,
    String? estado,
    DateTime? fechaDevolucion,
    String? instructorId,
    String? elementoId,
    String? instructorNombre,
    String? elementoNombre,
    String? actaUrl,
    String? actaPublicId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return CuentadanteModel(
      id: id ?? this.id,
      observacion: observacion ?? this.observacion,
      fechaAsignacion: fechaAsignacion ?? this.fechaAsignacion,
      estado: estado ?? this.estado,
      fechaDevolucion: fechaDevolucion ?? this.fechaDevolucion,
      instructorId: instructorId ?? this.instructorId,
      elementoId: elementoId ?? this.elementoId,
      instructorNombre: instructorNombre ?? this.instructorNombre,
      elementoNombre: elementoNombre ?? this.elementoNombre,
      actaUrl: actaUrl ?? this.actaUrl,
      actaPublicId: actaPublicId ?? this.actaPublicId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  // Helper robusto: convierte Timestamp/DateTime en DateTime
  static DateTime? _toDate(dynamic valor) {
    if (valor == null) return null;
    if (valor is Timestamp) return valor.toDate();
    if (valor is DateTime) return valor;
    return null;
  }

  factory CuentadanteModel.fromMap(Map<String, dynamic> map, String id) {
    return CuentadanteModel(
      id: id,
      observacion: map['Observacion'] ?? '',
      fechaAsignacion: _toDate(map['FechaAsignacion']),
      estado: map['Estado'] ?? 'asignado',
      fechaDevolucion: _toDate(map['FechaDevolucion']),
      instructorId: map['instructor_id'] ?? '',
      elementoId: map['elemento_id'] ?? '',
      instructorNombre: map['instructor_nombre'],
      elementoNombre: map['elemento_nombre'],
      actaUrl: map['acta_url'],
      actaPublicId: map['acta_public_id'],
      createdAt: _toDate(map['created_at']),
      updatedAt: _toDate(map['updated_at']),
      createdBy: map['created_by'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Observacion': observacion,
      'FechaAsignacion': fechaAsignacion != null
          ? Timestamp.fromDate(fechaAsignacion!)
          : null,
      'Estado': estado,
      'FechaDevolucion': fechaDevolucion != null
          ? Timestamp.fromDate(fechaDevolucion!)
          : null,
      'instructor_id': instructorId,
      'elemento_id': elementoId,
      'instructor_nombre': instructorNombre,
      'elemento_nombre': elementoNombre,
      'acta_url': actaUrl,
      'acta_public_id': actaPublicId,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'created_by': createdBy,
    };
  }

  @override
  List<Object?> get props => [
    id,
    observacion,
    fechaAsignacion,
    estado,
    fechaDevolucion,
    instructorId,
    elementoId,
    instructorNombre,
    elementoNombre,
    actaUrl,
    actaPublicId,
    createdAt,
    updatedAt,
    createdBy,
  ];
}
