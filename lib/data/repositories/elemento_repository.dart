import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:mi_proyecto_guia4/data/models/elemento_model.dart';

class ElementoRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'ambientesena_elementos';

  /// Lista todos los elementos. (Opcional) orderBy por Nombre
  Future<List<ElementoModel>> getAll() async {
    final snapshot = await _firestore
        .collection(collection)
        .orderBy('Nombre')
        .get();

    debugPrint('Elementos encontrados: ${snapshot.docs.length}');

    return snapshot.docs
        .map((doc) => ElementoModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Obtiene un elemento por id (útil para leer public_id antes de borrar imagen).
  Future<ElementoModel?> getById(String id) async {
    final doc = await _firestore.collection(collection).doc(id).get();
    if (!doc.exists) return null;
    return ElementoModel.fromMap(doc.data()!, doc.id);
  }

  /// Agrega un elemento y retorna el id del documento creado.
  /// Puedes setear también timestamps si lo deseas.
  Future<String> addElemento(ElementoModel elemento) async {
    final data = {
      ...elemento.toMap(),
      'asignado': elemento.asignado,
      'asignadoAInstructorId': elemento.asignadoAInstructorId,
      'cuentadanteActivoId': elemento.cuentadanteActivoId,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
    final ref = await _firestore.collection(collection).add(data);
    return ref.id;
  }

  /// Actualiza un elemento existente por su id.
  Future<void> update(ElementoModel elemento) async {
    final data = {
      ...elemento.toMap(),
      'updated_at': FieldValue.serverTimestamp(),
    };

    await _firestore.collection(collection).doc(elemento.id).update(data);
  }

  /// Borra el documento. (Ojo: esto por sí solo NO borra la imagen en Cloudinary)
  Future<void> delete(String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }

  /// (Opcional) Borra el elemento Y retorna el publicId para que lo borres en Cloudinary.
  /// Útil si prefieres centralizar la lectura del doc aquí.
  Future<String?> deleteAndReturnPublicId(String id) async {
    final docRef = _firestore.collection(collection).doc(id);
    final snap = await docRef.get();
    if (!snap.exists) {
      // No existe el documento, nada que borrar
      return null;
    }

    final data = snap.data()!;
    final publicId = data['public_id'] as String?;
    await docRef.delete();
    return publicId;
  }

  //Consultar los elementos como stream (útil para UI reactiva).
  Stream<List<ElementoModel>> watchAll({String? ambienteId}) {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);
    if (ambienteId != null && ambienteId.isNotEmpty) {
      query = query.where('ambiente_id', isEqualTo: ambienteId);
    }

    //Ordernar por Nombre si ese campo es estable
    query = query.orderBy('nombre');
    return query.snapshots().map(
      (snap) =>
          snap.docs.map((d) => ElementoModel.fromMap(d.data(), d.id)).toList(),
    );
  }

  //Consultar elementos disponibles asignado == false
  Stream<List<ElementoModel>> watchDisponibles({String? ambienteId}) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(collection)
        .where('asignado', isEqualTo: false);

    if (ambienteId != null && ambienteId.isNotEmpty) {
      query = query.where('ambiente_id', isEqualTo: ambienteId);
    }

    return query.snapshots().map(
      (snap) =>
          snap.docs.map((d) => ElementoModel.fromMap(d.data(), d.id)).toList(),
    );
  }

  //Consultar elementos asignados a instructores
  Stream<List<ElementoModel>> watchAsignadosAInstructor(String instructorId) {
    final query = _firestore
        .collection(collection)
        .where('asignadoAInstructorId', isEqualTo: instructorId);
    //debugPrint("************************ instructor_id = $instructorId  ");
    return query.snapshots().map(
      (snap) =>
          snap.docs.map((d) => ElementoModel.fromMap(d.data(), d.id)).toList(),
    );
  }

  /// Marca un elemento como ASIGNADO a un instructor, vinculando el cuentadante activo.
  Future<void> marcarAsignado({
    required ElementoModel elemento,
    required String instructorId,
    required String cuentadanteId,
  }) async {
    await _firestore.collection(collection).doc(elemento.id).update({
      'asignado': true,
      'asignadoAInstructorId': instructorId,
      'cuentadanteActivoId': cuentadanteId,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // Marca un elemento como DISPONIBLE (devolución).
  Future<void> desmarcarAsignado(ElementoModel elemento) async {
    await _firestore.collection(collection).doc(elemento.id).update({
      'asignado': false,
      'asignadoAInstructorId': null,
      'cuentadanteActivoId': null,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
