import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pago_goo/screens/home_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;
  String? _errorMessage;

  Future<void> _authenticate() async {
    try {
      if (_isLogin) {
        var userQuery = await _firestore
            .collection('usuarios')
            .where('cedula', isEqualTo: _cedulaController.text.trim())
            .get();

        if (userQuery.docs.isEmpty) {
          setState(() {
            _errorMessage = 'No existe una cuenta con esta cédula.';
          });
          return;
        }

        String email = userQuery.docs.first['email'];
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: _passwordController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Inicio de sesión exitoso.')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        var existingUser = await _firestore
            .collection('usuarios')
            .where('cedula', isEqualTo: _cedulaController.text.trim())
            .get();

        if (existingUser.docs.isNotEmpty) {
          setState(() {
            _errorMessage = 'Esta cédula ya está registrada.';
          });
          return;
        }

        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await _firestore.collection('usuarios').doc(userCredential.user!.uid).set({
          'cedula': _cedulaController.text.trim(),
          'email': _emailController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cuenta creada con éxito')),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'Ya existe esta cuenta; inicie sesión.';
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'weak-password':
        return 'La contraseña es demasiado débil. Intente con otra más segura.';
      case 'user-not-found':
        return 'No existe una cuenta con esta cédula.';
      case 'wrong-password':
        return 'Contraseña incorrecta. Intente de nuevo.';
      default:
        return 'Error inesperado. Inténtelo de nuevo.';
    }
  }

  Future<void> _resetPassword() async {
    try {
      var userQuery = await _firestore
          .collection('usuarios')
          .where('cedula', isEqualTo: _cedulaController.text.trim())
          .get();

      if (userQuery.docs.isEmpty) {
        setState(() {
          _errorMessage = 'No existe una cuenta con esta cédula.';
        });
        return;
      }

      String email = userQuery.docs.first['email'];
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Se ha enviado un enlace de recuperación a $email')),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Fondo gris claro
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Card(
              elevation: 5, // Sombra del card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0), // Bordes redondeados
              ),
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Bienvenido a PagoGo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Campo de Cédula
                    TextField(
                      controller: _cedulaController,
                      decoration: InputDecoration(
                        labelText: 'Cédula',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    if (!_isLogin) ...[
                      SizedBox(height: 15),
                      // Campo de Correo Electrónico
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Correo electrónico',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: Icon(Icons.email, color: Colors.blue),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ],
                    SizedBox(height: 15),
                    // Campo de Contraseña
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.blue),
                      ),
                      obscureText: true,
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    SizedBox(height: 15),
                    // Checkbox para Remember me
                    Row(
                      children: [
                        // Checkbox(
                        //   value: false, // Cambia esto según tu lógica
                        //   onChanged: (value) {
                        //     // Lógica para recordar la sesión
                        //   },
                        // ),
                        // Text('Remember me'),
                        // Spacer(), // Espacio entre el checkbox y el enlace
                        TextButton(
                          onPressed: _resetPassword,
                          child: Text(
                            'Restablecer Password?',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Botón de Iniciar Sesión o Registrarse
                    ElevatedButton(
                      onPressed: _authenticate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(_isLogin ? 'Iniciar sesión' : 'Registrarse'),
                    ),
                    SizedBox(height: 10),
                    // Botón para cambiar entre Iniciar Sesión y Registrarse
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _errorMessage = null;
                        });
                      },
                      child: Text(
                        _isLogin ? 'Crear una cuenta' : 'Ya tengo una cuenta',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}