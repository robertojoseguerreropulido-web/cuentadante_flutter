import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_proyecto_guia4/data/models/cuentadante_model.dart';

class CuentadanteRepository {
  final FirebaseFirestore _firestore;
  final String cuentadantesCollection;
  final String elementosCollection;

  CuentadanteRepository(
    this._firestore, {
    this.cuentadantesCollection = 'ambientesena_cuentadantes',
    this.elementosCollection = 'ambientesena_elementos',
  });

  // ========== STREAMS ==========
  Stream<List<CuentadanteModel>> watchAll({String? estado}) {
    Query<Map<String, dynamic>> query = _firestore.collection(
      cuentadantesCollection,
    );
    if (estado != null && estado.isNotEmpty) {
      //debugPrint("el estado es $estado");
      query = query.where('Estado', isEqualTo: estado);
    }
    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => CuentadanteModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  Stream<List<CuentadanteModel>> watchByInstructor(
    String instructorId, {
    String? estado,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(cuentadantesCollection)
        .where('instructor_id', isEqualTo: instructorId);
    //debugPrint("el estado es $estado y el instructor: $instructorId");

    if (estado != null && estado.isNotEmpty) {
      query = query.where('Estado', isEqualTo: estado);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => CuentadanteModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  Stream<List<CuentadanteModel>> watchByElemento(
    String elementoId, {
    String? estado,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(cuentadantesCollection)
        .where('elemento_id', isEqualTo: elementoId);
    //debugPrint("el estado es $estado el elemento: $elementoId");

    if (estado != null && estado.isNotEmpty) {
      query = query.where('Estado', isEqualTo: estado);
      //debugPrint('Estado xxxxxxxx $estado');
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => CuentadanteModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  // ========== CRUD SIMPLE ==========
  Future<String> create(CuentadanteModel cuentadante) async {
    final ref = await _firestore
        .collection(cuentadantesCollection)
        .add(cuentadante.toMap());
    return ref.id;
  }

  Future<void> update(CuentadanteModel cuentadante) async {
    await _firestore
        .collection(cuentadantesCollection)
        .doc(cuentadante.id)
        .update(cuentadante.toMap());
  }

  Future<void> delete(String cuentadanteId) async {
    await _firestore
        .collection(cuentadantesCollection)
        .doc(cuentadanteId)
        .delete();
  }

  // ========== ASIGNAR ELEMENTOS ==========
  Future<AssignManyResult> assignMany({
    required String instructorId,
    required List<String> elementoIds,
    String? observacion,
    String? instructorNombre,
    Map<String, String>? elementoNombresById,
    String? createdBy,
  }) async {
    final createdIds = <String>[];
    final conflicts = <String>[];

    await _firestore.runTransaction((tx) async {
      final Map<String, DocumentSnapshot> elementosSnaps = {};
      // ========== LECTURAS ==========
      for (final elementoId in elementoIds) {
        final elemRef = _firestore
            .collection(elementosCollection)
            .doc(elementoId);
        final snap = await tx.get(elemRef);
        elementosSnaps[elementoId] = snap;
      }

      // ========== VALIDACIONES ==========
      for (final entry in elementosSnaps.entries) {
        final snap = entry.value;
        final data = snap.data() as Map<String, dynamic>?;
        final bool asignado = data?['asignado'] as bool? ?? false;

        if (!snap.exists || asignado) {
          conflicts.add(entry.key);
        }
      }
      // ========== ESCRITURAS ==========
      for (final entry in elementosSnaps.entries) {
        if (conflicts.contains(entry.key)) continue;
        final elementoId = entry.key;
        final elemRef = _firestore
            .collection(elementosCollection)
            .doc(elementoId);
        final cuentRef = _firestore.collection(cuentadantesCollection).doc();
        tx.set(cuentRef, {
          'Observacion': observacion ?? '',
          'FechaAsignacion': FieldValue.serverTimestamp(),
          'Estado': 'asignado',
          'FechaDevolucion': null,
          'instructor_id': instructorId,
          'elemento_id': elementoId,
          'instructor_nombre': instructorNombre,
          'elemento_nombre': elementoNombresById?[elementoId],
          'acta_url': null,
          'acta_public_id': null,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
          'created_by': createdBy,
        });
        tx.update(elemRef, {
          'asignado': true,
          'asignadoAInstructorId': instructorId,
          'cuentadanteActivoId': cuentRef.id,
          'updated_at': FieldValue.serverTimestamp(),
        });
        createdIds.add(cuentRef.id);
      }
    });
    return AssignManyResult(createdIds: createdIds, conflicts: conflicts);
  }

  // ========== DEVOLVER ELEMENTO ==========
  Future<void> devolverElemento(String elementoId) async {
    await _firestore.runTransaction((tx) async {
      final elemRef = _firestore
          .collection(elementosCollection)
          .doc(elementoId);
      final elemSnap = await tx.get(elemRef);
      if (!elemSnap.exists) return;
      final activoId = elemSnap.data()?['cuentadanteActivoId'] as String?;
      if (activoId == null) return;

      final cuentRef = _firestore
          .collection(cuentadantesCollection)
          .doc(activoId);
      final cuentSnap = await tx.get(cuentRef);
      if (!cuentSnap.exists) return;

      tx.update(cuentRef, {
        'Estado': 'devuelto',
        'FechaDevolucion': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      tx.update(elemRef, {
        'asignado': false,
        'asignadoAInstructorId': null,
        'cuentadanteActivoId': null,
        'updated_at': FieldValue.serverTimestamp(),
      });
    });
  }
}

// ========== CLASE AssignManyResult ==========
class AssignManyResult {
  final List<String> createdIds;
  final List<String> conflicts;

  AssignManyResult({required this.createdIds, required this.conflicts});
}
