import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_proyecto_guia4/core/auth_service.dart';
import 'package:mi_proyecto_guia4/core/cloudinary_service.dart';
import 'package:mi_proyecto_guia4/data/repositories/ambiente_repository.dart';
import 'package:mi_proyecto_guia4/data/repositories/cuentadante_repository.dart';
import 'package:mi_proyecto_guia4/data/repositories/elemento_repository.dart';
import 'package:mi_proyecto_guia4/data/repositories/instructor_repository.dart';
import 'package:mi_proyecto_guia4/logic/bloc/Instructor_bloc/instructor_bloc.dart';
import 'package:mi_proyecto_guia4/logic/bloc/Instructor_bloc/instructor_event.dart';
import 'package:mi_proyecto_guia4/logic/bloc/ambiente_bloc/ambiente_bloc.dart';
import 'package:mi_proyecto_guia4/logic/bloc/ambiente_bloc/ambiente_event.dart';
import 'package:mi_proyecto_guia4/logic/bloc/cuentadante_bloc/cuentadante_bloc.dart';
import 'package:mi_proyecto_guia4/logic/bloc/elemento_bloc/elemento_bloc.dart';
import 'package:mi_proyecto_guia4/logic/bloc/elemento_bloc/elemento_event.dart';
import 'package:mi_proyecto_guia4/presentation/auth/iniciar_sesion.dart';
import 'package:mi_proyecto_guia4/presentation/screens/home_screen_bottom_nav.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AmbienteRepository>(
          create: (_) => AmbienteRepository(),
        ),
        RepositoryProvider<InstructorRepository>(
          create: (_) => InstructorRepository(),
        ),
        RepositoryProvider<ElementoRepository>(
          create: (_) => ElementoRepository(),
        ),
        RepositoryProvider<CloudinaryService>(
          create: (_) => CloudinaryService(
            cloudName: 'dyveaqqrf',
            uploadPreset: 'ambientesena',
          ),
        ),
        RepositoryProvider<CuentadanteRepository>(
          create: (_) => CuentadanteRepository(FirebaseFirestore.instance),
        ),
      ],

      child: MultiBlocProvider(
        providers: [
          BlocProvider<AmbienteBloc>(
            create: (ctx) =>
                AmbienteBloc(ctx.read<AmbienteRepository>())
                  ..add(LoadAmbientes()),
          ),
          BlocProvider<InstructorBloc>(
            create: (ctx) =>
                InstructorBloc(ctx.read<InstructorRepository>())
                  ..add(LoadInstructores()),
          ),
          BlocProvider<ElementoBloc>(
            create: (ctx) => ElementoBloc(
              ctx.read<ElementoRepository>(),
              ctx.read<CloudinaryService>(),
            )..add(LoadElementos()),
          ),
          BlocProvider<CuentadanteBloc>(
            create: (ctx) => CuentadanteBloc(ctx.read<CuentadanteRepository>()),
          ),
        ],

        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Gestión de Ambientes Sena',
          theme: ThemeData(primarySwatch: Colors.red),
          home:
              const AuthGate(), // ahora AuthGate solo decide qué pantalla mostrar
        ),
      ),
    );
  }
}

//Este Widget decide si muetra el login o la App (Providers + Home)//
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.I.authStateChanges(),
      builder: (context, snapshot) {
        // Estado de carga inicial de Firebase Auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Si NO hay usuario → Login
        if (!snapshot.hasData) {
          return const IniciarSesionScreen();
        }
        // Si hay usuario: Montamos repositorios, blocs y Home
        return MultiRepositoryProvider(
          providers: [
            RepositoryProvider<AmbienteRepository>(
              create: (_) => AmbienteRepository(),
            ),
            RepositoryProvider<InstructorRepository>(
              create: (_) => InstructorRepository(),
            ),
            RepositoryProvider<ElementoRepository>(
              create: (_) => ElementoRepository(),
            ),
            RepositoryProvider<CloudinaryService>(
              create: (_) => CloudinaryService(
                cloudName: 'dyveaqqrf',
                uploadPreset: 'ambientesena',
              ),
            ),
            RepositoryProvider<CuentadanteRepository>(
              create: (_) => CuentadanteRepository(FirebaseFirestore.instance),
            ),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider<AmbienteBloc>(
                create: (ctx) =>
                    AmbienteBloc(ctx.read<AmbienteRepository>())
                      ..add(LoadAmbientes()),
              ),
              BlocProvider<InstructorBloc>(
                create: (ctx) =>
                    InstructorBloc(ctx.read<InstructorRepository>())
                      ..add(LoadInstructores()),
              ),
              BlocProvider<ElementoBloc>(
                create: (ctx) => ElementoBloc(
                  ctx.read<ElementoRepository>(),
                  ctx.read<CloudinaryService>(),
                )..add(LoadElementos()),
              ),
              BlocProvider<CuentadanteBloc>(
                create: (ctx) =>
                    CuentadanteBloc(ctx.read<CuentadanteRepository>()),
              ),
            ],
            child: const HomeScreenBottomNav(),
          ),
        );
      },
    );
  }
}
