import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SimpleInterestScreen extends StatefulWidget {
  const SimpleInterestScreen({super.key});

  @override
  _SimpleInterestScreenState createState() => _SimpleInterestScreenState();
}

class _SimpleInterestScreenState extends State<SimpleInterestScreen> {
  final TextEditingController capitalController = TextEditingController();
  final TextEditingController tasaController = TextEditingController();
  final TextEditingController aniosController = TextEditingController();
  final TextEditingController mesesController = TextEditingController();
  final TextEditingController diasController = TextEditingController();
  final TextEditingController montoController = TextEditingController();

  void calcularInteres() {
    double? capital = double.tryParse(capitalController.text);
    double? tasa = double.tryParse(tasaController.text);
    double? anios = double.tryParse(aniosController.text) ?? 0;
    double? meses = double.tryParse(mesesController.text) ?? 0;
    double? dias = double.tryParse(diasController.text) ?? 0;

    double tiempo = anios + (meses / 12) + (dias / 360);

    if (capital != null && tasa != null) {
      double interes = capital * (tasa / 100) * tiempo;
      setState(() {
        montoController.text = interes.toStringAsFixed(2);
      });
    }
  }

  void calcularCapital() {
    double? interes = double.tryParse(montoController.text);
    double? tasa = double.tryParse(tasaController.text);
    double? anios = double.tryParse(aniosController.text) ?? 0;
    double? meses = double.tryParse(mesesController.text) ?? 0;
    double? dias = double.tryParse(diasController.text) ?? 0;

    double tiempo = anios + (meses / 12) + (dias / 360);

    if (interes != null && tasa != null && tiempo > 0) {
      double capital = interes / ((tasa / 100) * tiempo);
      setState(() {
        capitalController.text = capital.toStringAsFixed(2);
      });
    }
  }

  void calcularTasa() {
    double? interes = double.tryParse(montoController.text);
    double? capital = double.tryParse(capitalController.text);
    double? anios = double.tryParse(aniosController.text) ?? 0;
    double? meses = double.tryParse(mesesController.text) ?? 0;
    double? dias = double.tryParse(diasController.text) ?? 0;

    double tiempo = anios + (meses / 12) + (dias / 360);

    if (interes != null && capital != null && tiempo > 0) {
      double tasa = (interes / (capital * tiempo)) * 100;
      setState(() {
        tasaController.text = tasa.toStringAsFixed(2);
      });
    }
  }

  void calcularTiempo() {
    double? interes = double.tryParse(montoController.text);
    double? capital = double.tryParse(capitalController.text);
    double? tasa = double.tryParse(tasaController.text);

    if (interes != null && capital != null && tasa != null && tasa > 0) {
      double tiempo = interes / (capital * (tasa / 100));
      setState(() {
        aniosController.text = tiempo.toStringAsFixed(2);
      });
    }
  }

  void limpiarCampos() {
    capitalController.clear();
    tasaController.clear();
    aniosController.clear();
    mesesController.clear();
    diasController.clear();
    montoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interés Simple'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              icon: Icons.info_outline,
              title: '¿Qué es el interés simple?',
              content:
                  'El interés simple se calcula solo sobre el capital inicial, sin acumular intereses.',
            ),
            const SizedBox(height: 15),
            _buildSectionCard(
              icon: LucideIcons.calculator,
              title: 'Fórmula del interés simple',
              content: 'I = C × i × t',
              isHighlighted: true,
            ),
            const SizedBox(height: 20),
            _buildInputField('Capital Inicial (C)', capitalController, icon: LucideIcons.dollarSign),
            _buildInputField('Tasa de Interés (%)', tasaController, icon: LucideIcons.percent),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildInputField('Años', aniosController, icon: LucideIcons.calendar),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInputField('Meses', mesesController, icon: LucideIcons.calendar),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInputField('Días', diasController, icon: LucideIcons.timer),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildInputField('Interés (I)', montoController, icon: LucideIcons.calculator),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCustomButton(
                  text: 'Calcular Interés',
                  icon: LucideIcons.calculator,
                  onPressed: calcularInteres,
                ),
                _buildCustomButton(
                  text: 'Calcular Capital',
                  icon: LucideIcons.dollarSign,
                  onPressed: calcularCapital,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCustomButton(
                  text: 'Calcular Tasa',
                  icon: LucideIcons.percent,
                  onPressed: calcularTasa,
                ),
                _buildCustomButton(
                  text: 'Calcular Tiempo',
                  icon: LucideIcons.clock,
                  onPressed: calcularTiempo,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCustomButton(
                  text: 'Limpiar Campos',
                  icon: LucideIcons.trash,
                  onPressed: limpiarCampos,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueGrey.shade700),
          filled: true,
          fillColor: Colors.blueGrey.shade50,
          prefixIcon: icon != null ? Icon(icon, color: Colors.blueGrey) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String content,
    bool isHighlighted = false,
  }) {
    return Card(
      elevation: isHighlighted ? 6 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: isHighlighted ? Colors.blueAccent.shade100 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: Colors.blueAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}