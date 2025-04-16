import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pago_goo/screens/anualidades_screen.dart';
import 'package:pago_goo/screens/compuesto_interes_screen.dart';
import 'package:pago_goo/screens/interest_rate_screen.dart';
import 'package:pago_goo/screens/login_screen.dart';
import 'package:pago_goo/screens/simple_interes_screen.dart';
import 'package:pago_goo/screens/gradientes_screen.dart';
import 'package:pago_goo/screens/amortizacion_screen.dart';
import 'package:pago_goo/screens/capitalizacion_screen.dart';
import 'package:pago_goo/screens/tir_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora Financiera',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _buildSectionTitle('Herramientas Financieras'),
                const SizedBox(height: 10),
                _buildButtonRow(
                  context,
                  [
                    {'title': 'Tasa de Interés', 'icon': Icons.trending_up, 'screen': const InterestRateScreen()},
                    {'title': 'Interés Simple', 'icon': Icons.calculate, 'screen': const SimpleInterestScreen()},
                  ],
                ),
                _buildButtonRow(
                  context,
                  [
                    {'title': 'Interés Compuesto', 'icon': Icons.attach_money, 'screen': const CompuestoInterestScreen()},
                    {'title': 'Anualidades', 'icon': Icons.timeline, 'screen': const AnualidadesScreen()},
                  ],
                ),
                _buildButtonRow(
                  context,
                  [
                    {'title': 'Gradientes', 'icon': Icons.show_chart, 'screen': const GradientesScreen()},
                    {'title': 'Amortización', 'icon': Icons.pie_chart, 'screen': const AmortizacionScreen()},
                  ],
                ),
                _buildButtonRow(
                  context,
                  [
                    {'title': 'Capitalización', 'icon': Icons.account_balance, 'screen': const CapitalizacionScreen()},
                    {'title': 'TIR', 'icon': Icons.bar_chart, 'screen': const TIRScreen()},
                  ],
                ),
                const SizedBox(height: 30),
                _buildLogoutButton(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0D47A1),
        ),
      ),
    );
  }

  Widget _buildButtonRow(BuildContext context, List<Map<String, dynamic>> buttons) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: buttons.map((button) {
          return _buildOptionButton(
            context,
            button['title'],
            button['icon'],
            button['screen'],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, String title, IconData icon, Widget screen) {
    return Container(
      width: 160,
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E88E5),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFBBDEFB), width: 1),
          ),
          padding: const EdgeInsets.all(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE53935),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AuthScreen()),
          );
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20),
            SizedBox(width: 8),
            Text(
              'Cerrar sesión',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}