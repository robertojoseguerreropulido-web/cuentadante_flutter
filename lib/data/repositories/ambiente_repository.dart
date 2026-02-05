import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_proyecto_guia4/data/models/ambiente_model.dart';

class AmbienteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'ambientesena_ambiente';

  // Obtener todos los ambientes
  Future<List<AmbienteModel>> getAll() async {
    final snapshot = await _firestore.collection(collection).get();
    return snapshot.docs
        .map((doc) => AmbienteModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Agregar un ambiente
  Future<void> add(AmbienteModel ambiente) async {
    await _firestore.collection(collection).add(ambiente.toMap());
  }

  // Actualizar un ambiente
  Future<void> update(AmbienteModel ambiente) async {
    await _firestore
        .collection(collection)
        .doc(ambiente.id)
        .update(ambiente.toMap());
  }

  // Eliminar un ambiente
  Future<void> delete(String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }
}
