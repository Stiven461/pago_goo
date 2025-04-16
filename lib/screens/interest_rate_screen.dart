import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class InterestRateScreen extends StatelessWidget {
  const InterestRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasa de Interés'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              icon: Icons.info_outline,
              title: '¿Qué es la tasa de interés?',
              content:
                  'La tasa de interés es el porcentaje que se cobra o se paga por el uso de una cantidad de dinero durante un período determinado.',
            ),
            const SizedBox(height: 15),
            _buildSectionCard(
              icon: LucideIcons.calculator,
              title: '¿Cómo se calcula?',
              content:
                  'Se calcula como un porcentaje sobre la cantidad prestada, invertida o depositada. Se consideran los gastos administrativos y otros factores.',
            ),
            const SizedBox(height: 15),
            _buildSectionCard(
              icon: LucideIcons.banknote,
              title: '¿Cómo se aplica?',
              content:
                  'El Banco de la República establece la tasa de referencia, afectando los productos financieros como préstamos e inversiones.',
            ),
            const SizedBox(height: 15),
            _buildSectionCard(
              icon: LucideIcons.trendingUp,
              title: '¿Cómo influye en la economía?',
              content:
                  'Una tasa de interés alta incentiva el ahorro, mientras que una baja fomenta el consumo y la inversión.',
            ),
            const SizedBox(height: 15),
            _buildSectionCard(
              icon: LucideIcons.wallet,
              title: '¿Cómo afecta a tus finanzas?',
              content:
                  'Comprender la tasa de interés te ayudará a tomar mejores decisiones al ahorrar o pedir un préstamo.',
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              icon: LucideIcons.functionSquare,
              title: 'Fórmula de la tasa de interés',
              content: 'Interés = Capital × Tasa de interés × Tiempo',
              isHighlighted: true,
            ),
            const SizedBox(height: 15),
            _buildSectionCard(
              icon: LucideIcons.book,
              title: 'Explicación de la fórmula',
              content:
                  '''- Capital: Es la cantidad de dinero inicial.
- Tasa de interés: Es el porcentaje aplicado.
- Tiempo: Es el período en el que se calcula el interés.''',
            ),
          ],
        ),
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
}
