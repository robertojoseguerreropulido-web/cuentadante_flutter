import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_proyecto_guia4/data/repositories/instructor_repository.dart';
import 'package:mi_proyecto_guia4/presentation/auth/cerrar_sesion.dart';
import 'package:mi_proyecto_guia4/presentation/screens/ambiente_screen.dart';
import 'package:mi_proyecto_guia4/presentation/screens/cuentadante_screen.dart';
import 'package:mi_proyecto_guia4/presentation/screens/elemento_screen.dart';
import 'package:mi_proyecto_guia4/presentation/screens/instructor_screen.dart';
import 'package:mi_proyecto_guia4/presentation/widgets/instructor_selector_dialog.dart';

class HomeScreenBottomNav extends StatefulWidget {
  const HomeScreenBottomNav({super.key});

  @override
  State<HomeScreenBottomNav> createState() => _HomeScreenBottomNavState();
}

class _HomeScreenBottomNavState extends State<HomeScreenBottomNav> {
  int _currentIndex = 0;

  //final InstructorRepository _instructorRepository = InstructorRepository();
  final List<Widget> _screens = const [
    AmbienteScreen(),
    InstructorScreen(),
    ElementoScreen(),
  ];

  //Método especial para abrir CUENTADANTES ---
  Future<void> _openCuentadanteFlow() async {
    //Se toma el repository desde el provider (Ya lo provee AuthGate)
    final instructorRepository = context.read<InstructorRepository>();
    final resultado = await showDialog<Map<String, String?>>(
      context: context,
      useRootNavigator: false,
      builder: (dialogCtx) =>
          InstructorSelectorDialog(repository: instructorRepository),
    );

    if (resultado == null) return;

    final instructorId = resultado['id']!;
    final instructorNombre = resultado['nombre'];

    if (!mounted) return;

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
      appBar: AppBar(
        title: const Text("Gestión de Ambientes SENA"),
        actions: const [
          //Boton Cerrar Sesión
          CerrarSesionButton(),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 3) {
            // Botón CUENTADANTES
            _openCuentadanteFlow();
            return; // No cambia de tab
          }
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          //Botones del menu
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room),
            label: "Ambientes de Formación",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Instructores Sena.",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: "Elementos Fisicos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_ind),
            label: "Cuentadantes Sena",
          ),
        ],
      ),
    );
  }
}
