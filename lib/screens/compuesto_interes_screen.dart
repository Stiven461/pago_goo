import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:math';

class CompuestoInterestScreen extends StatefulWidget {
  const CompuestoInterestScreen({super.key});

  @override
  _CompuestoInterestScreenState createState() => _CompuestoInterestScreenState();
}

class _CompuestoInterestScreenState extends State<CompuestoInterestScreen> {
  final TextEditingController valorPresenteController = TextEditingController();
  final TextEditingController tasaInteresController = TextEditingController();
  final TextEditingController valorFuturoController = TextEditingController();
  final TextEditingController aniosController = TextEditingController();
  final TextEditingController mesesController = TextEditingController();
  final TextEditingController diasController = TextEditingController();
  String periodoCapitalizacion = 'Mensual';

  void calcular() {
    double? vp = double.tryParse(valorPresenteController.text);
    double? i = double.tryParse(tasaInteresController.text);
    double? vf = double.tryParse(valorFuturoController.text);
    int anios = int.tryParse(aniosController.text) ?? 0;
    int meses = int.tryParse(mesesController.text) ?? 0;
    int dias = int.tryParse(diasController.text) ?? 0;

    double n = calcularPeriodos(anios, meses, dias);

    if (vf == null && vp != null && i != null && n > 0) {
      vf = vp * pow(1 + (i / 100), n);
      setState(() {
        valorFuturoController.text = vf!.toStringAsFixed(2);
      });
    } else if (vp == null && vf != null && i != null && n > 0) {
      vp = vf / pow(1 + (i / 100), n);
      setState(() {
        valorPresenteController.text = vp!.toStringAsFixed(2);
      });
    } else if (i == null && vp != null && vf != null && n > 0) {
      i = (pow(vf / vp, 1 / n) - 1) * 100;
      setState(() {
        tasaInteresController.text = i!.toStringAsFixed(2);
      });
    } else if (n == 0 && vp != null && vf != null && i != null) {
      n = log(vf / vp) / log(1 + (i / 100));
      setState(() {
        aniosController.text = n.toStringAsFixed(2);
      });
    }
  }

  double calcularPeriodos(int anios, int meses, int dias) {
    switch (periodoCapitalizacion) {
      case 'Diario':
        return (anios * 360 + meses * 30 + dias).toDouble();
      case 'Mensual':
        return anios * 12 + meses + dias / 30;
      case 'Trimestral':
        return anios * 4 + meses / 3 + dias / 90;
      case 'Cuatrimestral':
        return anios * 3 + meses / 4 + dias / 120;
      case 'Semestral':
        return anios * 2 + meses / 6 + dias / 180;
      case 'Anual':
        return anios + meses / 12 + dias / 360;
      default:
        return anios + meses / 12 + dias / 360;
    }
  }

  void limpiarCampos() {
    valorPresenteController.clear();
    tasaInteresController.clear();
    valorFuturoController.clear();
    aniosController.clear();
    mesesController.clear();
    diasController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interés Compuesto'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              icon: Icons.info_outline,
              title: '¿Qué es el interés compuesto?',
              content:
                  'El interés compuesto es aquel en el que los intereses generados se suman al capital inicial para el cálculo de intereses futuros. A diferencia del interés simple, aquí los intereses se capitalizan periódicamente.',
            ),
            const SizedBox(height: 15),
            _buildSectionCard(
              icon: LucideIcons.calculator,
              title: 'Fórmula del interés compuesto',
              content: 'VF = VP × (1 + i) ^ n',
              isHighlighted: true,
            ),
            const SizedBox(height: 15),
            _buildSectionCard(
              icon: LucideIcons.book,
              title: 'Explicación de la fórmula',
              content: '''
- VF: Valor futuro (monto después de los intereses).
- VP: Valor presente (capital inicial).
- i: Tasa de interés por período (expresada en decimal, ej. 5% = 0.05).
- N: Número de períodos (años, meses, etc.).
              '''
            ),
            const SizedBox(height: 20),
            const Text(
              '💡 Ingrese los valores y deje en blanco el campo a calcular:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildInputField('Valor Presente (VP)', valorPresenteController, icon: LucideIcons.dollarSign),
            _buildInputField('Tasa de Interés (%)', tasaInteresController, icon: LucideIcons.percent),
            _buildTimeInputFields(),
            _buildInputField('Valor Futuro (VF)', valorFuturoController, icon: LucideIcons.calculator),
            const SizedBox(height: 10),
            _buildPeriodoCapitalizacionDropdown(),
            const SizedBox(height: 20),
            _buildButtonRow(),
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

  Widget _buildTimeInputFields() {
    return Row(
      children: [
        Expanded(child: _buildInputField('Años', aniosController, icon: LucideIcons.calendar)),
        const SizedBox(width: 10),
        Expanded(child: _buildInputField('Meses', mesesController, icon: LucideIcons.calendar)),
        const SizedBox(width: 10),
        Expanded(child: _buildInputField('Días', diasController, icon: LucideIcons.timer)),
      ],
    );
  }

  Widget _buildPeriodoCapitalizacionDropdown() {
    return DropdownButton<String>(
      value: periodoCapitalizacion,
      onChanged: (String? newValue) {
        setState(() {
          periodoCapitalizacion = newValue!;
        });
      },
      items: <String>['Diario', 'Mensual', 'Trimestral', 'Cuatrimestral', 'Semestral', 'Anual']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildButtonRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCustomButton(
          text: 'Calcular',
          icon: LucideIcons.calculator,
          onPressed: calcular,
        ),
        _buildCustomButton(
          text: 'Limpiar',
          icon: LucideIcons.trash,
          onPressed: limpiarCampos,
        ),
      ],
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