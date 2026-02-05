import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_proyecto_guia4/data/models/instructor_model.dart';

class InstructorRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'ambientesena_instructor';

  //Consultar todos los Instructores
  Future<List<InstructorModel>> getAll() async {
    final snapshot = await _firestore.collection(collection).get();
    return snapshot.docs
        .map((doc) => InstructorModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  //Adicionar Instructor//
  Future<void> addInstructor(InstructorModel instructor) async {
    await _firestore.collection(collection).add(instructor.toMap());
  }

  //Actualizar Instructor//
  Future<void> updateInstructor(InstructorModel instructor) async {
    await _firestore
        .collection(collection)
        .doc(instructor.id)
        .update(instructor.toMap());
  }

  //Eliminar Instructor//
  Future<void> deleteInstructor(String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }

  //Cargar los instructores por Streem
  Stream<List<InstructorModel>> watchAll() {
    return _firestore
        .collection(collection)
        .orderBy('NombreCompleto')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((datos) => InstructorModel.fromMap(datos.data(), datos.id))
              .toList(),
        );
  }
}
