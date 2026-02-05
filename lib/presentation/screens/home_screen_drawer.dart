import 'package:flutter/material.dart';
import 'package:mi_proyecto_guia4/data/repositories/instructor_repository.dart';
import 'package:mi_proyecto_guia4/presentation/screens/ambiente_screen.dart';
import 'package:mi_proyecto_guia4/presentation/screens/cuentadante_screen.dart';
import 'package:mi_proyecto_guia4/presentation/screens/elemento_screen.dart';
import 'package:mi_proyecto_guia4/presentation/screens/instructor_screen.dart';
import 'package:mi_proyecto_guia4/presentation/widgets/instructor_selector_dialog.dart';

class HomeScreenDrawer extends StatefulWidget {
  const HomeScreenDrawer({super.key});

  @override
  State<HomeScreenDrawer> createState() => _HomeScreenDrawerState();
}

class _HomeScreenDrawerState extends State<HomeScreenDrawer> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    AmbienteScreen(),
    InstructorScreen(),
    ElementoScreen(),
  ];

  final InstructorRepository _instructorRepository = InstructorRepository();

  Future<void> _openCuentadanteFlow() async {
    //Abrir el selector para instructores (dialog)
    final resultado = await showDialog<Map<String, String?>>(
      context: context,
      builder: (_) =>
          InstructorSelectorDialog(repository: _instructorRepository),
    );
    //Si el usuario cancela la accion//
    if (resultado == null) {
      return;
    }

    final instructorId = resultado['id']!;
    final instructorNombre = resultado['nombre'];

    if (!mounted) return;
    //Abrir la ventana de cuentadante con el instructor seleccionado:
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CuentadanteScreen(
          instructorId: instructorId,
          instructorNombre: instructorNombre,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Ambientes Sena')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Menú Principal')),
            ListTile(
              leading: const Icon(Icons.meeting_room),
              title: const Text('Ambientes'),
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_2),
              title: const Text('Intructores'),
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Elementos'),
              onTap: () {
                setState(() {
                  _currentIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            //Ventana cuentadante con instructor seleccionado
            ListTile(
              leading: const Icon(Icons.assignment_ind),
              title: const Text('Cuentadante (Asignar Elementos)'),
              onTap: () {
                Navigator.pop(context); //Se crea el Drawer
                _openCuentadanteFlow(); // se abre el selector de instructor
              },
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
    );
  }
}
