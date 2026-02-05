class AmbienteModel {
  final String id;
  final String nombre;
  final String tipo;
  final String observacion;

  AmbienteModel({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.observacion,
  });

  factory AmbienteModel.fromMap(Map<String, dynamic> map, String id) {
    return AmbienteModel(
      id: id,
      nombre: map['Nombre'] ?? '',
      tipo: map['Tipo'] ?? '',
      observacion: map['Observacion'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'Nombre': nombre, 'Tipo': tipo, 'Observacion': observacion};
  }
}
