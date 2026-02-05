import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._privateConstructor();
  static final AuthService _instance = AuthService._privateConstructor();
  static AuthService get I => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Stream del usuario autenticado (null si no hay sesión)
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  //Usuario actual (puede ser null)
  User? get currentUser => _auth.currentUser;

  //UID del usuario actual (o null si no hay sesión)
  String? get uid => _auth.currentUser?.uid;

  //Metodo Registrar usuario con email y contraseña
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credenciales = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credenciales;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (_) {
      throw const AuthException('Ocurrió un error inesperado al registrar.');
    }
  }

  //Metodo Iniciar sesión con email y contraseña
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credenciales = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credenciales;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (_) {
      throw const AuthException(
        'Ocurrió un error inesperado al iniciar sesión.',
      );
    }
  }

  //Metodo Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {
      throw const AuthException(
        'No se pudo cerrar la sesión. Intenta de nuevo.',
      );
    }
  }

  //Metodo Enviar correo para restablecer contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (_) {
      throw const AuthException(
        'No se pudo enviar el correo de restablecimiento.',
      );
    }
  }

  //Metodo para Mapear errores comunes a mensajes amigables
  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'El correo no tiene un formato válido.';
      case 'user-disabled':
        return 'Este usuario está deshabilitado.';
      case 'user-not-found':
        return 'No existe un usuario con ese correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 caracteres).';
      case 'operation-not-allowed':
        return 'El método de autenticación no está habilitado.';
      default:
        return e.message ?? 'Error de autenticación.';
    }
  }
}

//Clase AuthExcepción para mostrar mensajes claros en UI
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}
