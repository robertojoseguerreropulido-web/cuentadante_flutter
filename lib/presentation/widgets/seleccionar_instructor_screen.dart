// lib/presentation/screens/seleccionar_instructor_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_proyecto_guia4/presentation/screens/cuentadante_screen.dart';

class SeleccionarInstructorScreen extends StatefulWidget {
  const SeleccionarInstructorScreen({super.key});

  @override
  State<SeleccionarInstructorScreen> createState() =>
      _SeleccionarInstructorScreenState();
}

class _SeleccionarInstructorScreenState
    extends State<SeleccionarInstructorScreen> {
  String? _selectedInstructorId;
  String? _selectedInstructorNombre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar instructor')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // 1) Selector de instructor (puede ser lista o dropdown)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('instructores')
                  .orderBy('nombreCompleto')
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const LinearProgressIndicator();
                final docs = snap.data!.docs;

                return DropdownButtonFormField<String>(
                  initialValue: _selectedInstructorId,
                  hint: const Text('Seleccione un instructor'),
                  items: docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final nombre = (data['nombreCompleto'] as String?) ?? d.id;
                    return DropdownMenuItem<String>(
                      value: d.id,
                      child: Text(nombre),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedInstructorId = val;
                      // Busca el nombre en el snapshot
                      final doc = docs.firstWhere((x) => x.id == val);
                      final data = doc.data() as Map<String, dynamic>;
                      _selectedInstructorNombre =
                          (data['nombreCompleto'] as String?) ?? val;
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 16),

            // 2) AQUÍ VA EL BOTÓN "Continuar"
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continuar'),
              onPressed: _selectedInstructorId == null
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CuentadanteScreen(
                            instructorId: _selectedInstructorId!,
                            instructorNombre: _selectedInstructorNombre,
                          ),
                        ),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
