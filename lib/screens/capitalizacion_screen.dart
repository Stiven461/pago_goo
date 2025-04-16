import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:math';

class CapitalizacionScreen extends StatefulWidget {
  const CapitalizacionScreen({super.key});

  @override
  State<CapitalizacionScreen> createState() => _CapitalizacionScreenState();
}

class _CapitalizacionScreenState extends State<CapitalizacionScreen> {
  final TextEditingController _capitalController = TextEditingController();
  final TextEditingController _tasaController = TextEditingController();
  final TextEditingController _aniosController = TextEditingController();
  final TextEditingController _mesesController = TextEditingController();
  final TextEditingController _diasController = TextEditingController();
  final TextEditingController _resultadoController = TextEditingController();
  final TextEditingController _diferimientoAniosController = TextEditingController();
  final TextEditingController _diferimientoMesesController = TextEditingController();
  final TextEditingController _diferimientoDiasController = TextEditingController();

  String _tipoCapitalizacion = 'Simple';
  String _frecuenciaPeriodica = 'Mensual';
  
  final List<String> _tiposCapitalizacion = [
    'Simple',
    'Compuesta',
    'Continua',
    'Periódica',
    'Anticipada',
    'Diferida'
  ];

  final List<String> _frecuencias = [
    'Diario',
    'Semanal',
    'Quincenal',
    'Mensual',
    'Bimestral',
    'Trimestral',
    'Cuatrimestral',
    'Semestral',
    'Anual'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistemas de Capitalización'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              icon: LucideIcons.info,
              title: '¿Qué es la Capitalización?',
              content: 'La capitalización es el proceso de calcular el valor futuro de un capital aplicando intereses. Diferentes sistemas determinan cómo se acumulan los intereses a lo largo del tiempo.',
            ),
            
            const SizedBox(height: 15),
            
            _buildSectionCard(
              icon: LucideIcons.functionSquare,
              title: 'Capitalización Simple',
              content: 'Los intereses se calculan solo sobre el capital inicial y no se reinvierten.\n\n'
                      'Fórmula:\n'
                      'M = C × (1 + r × t)\n'
                      '• M = Monto final\n'
                      '• C = Capital inicial\n'
                      '• r = Tasa de interés\n'
                      '• t = Tiempo',
              isHighlighted: _tipoCapitalizacion == 'Simple',
            ),
            
            const SizedBox(height: 10),
            
            _buildSectionCard(
              icon: LucideIcons.functionSquare,
              title: 'Capitalización Compuesta',
              content: 'Los intereses generados en cada período se suman al capital y generan nuevos intereses (crecimiento exponencial).\n\n'
                      'Fórmula:\n'
                      'M = C × (1 + r)ᵗ\n'
                      '• M = Monto final\n'
                      '• C = Capital inicial\n'
                      '• r = Tasa de interés periódica\n'
                      '• t = Número de períodos',
              isHighlighted: _tipoCapitalizacion == 'Compuesta',
            ),
            
            const SizedBox(height: 10),
            
            _buildSectionCard(
              icon: LucideIcons.functionSquare,
              title: 'Capitalización Continua',
              content: 'La capitalización ocurre de manera ininterrumpida en todo momento (usa el número "e").\n\n'
                      'Fórmula:\n'
                      'M = C × eʳᵗ\n'
                      '• e ≈ 2.71828 (base del logaritmo natural)\n'
                      '• r = Tasa de interés\n'
                      '• t = Tiempo',
              isHighlighted: _tipoCapitalizacion == 'Continua',
            ),
            
            const SizedBox(height: 10),
            
            _buildSectionCard(
              icon: LucideIcons.functionSquare,
              title: 'Capitalización Periódica',
              content: 'Los intereses se capitalizan en intervalos regulares (ej: mensual, trimestral).\n\n'
                      'Fórmula:\n'
                      'M = C × (1 + r/n)ⁿᵗ\n'
                      '• n = Número de períodos por año\n'
                      '• r = Tasa de interés anual\n'
                      '• t = Tiempo en años',
              isHighlighted: _tipoCapitalizacion == 'Periódica',
            ),
            
            const SizedBox(height: 10),
            
            _buildSectionCard(
              icon: LucideIcons.functionSquare,
              title: 'Capitalización Anticipada',
              content: 'Los intereses se aplican al inicio del período (usado en pagos adelantados).\n\n'
                      'Fórmula:\n'
                      'M = C × (1 + r/n)ⁿ⁽ᵗ⁺¹⁾\n'
                      '• n = Número de períodos por año\n'
                      '• r = Tasa de interés anual\n'
                      '• t = Tiempo en años',
              isHighlighted: _tipoCapitalizacion == 'Anticipada',
            ),
            
            const SizedBox(height: 10),
            
            _buildSectionCard(
              icon: LucideIcons.functionSquare,
              title: 'Capitalización Diferida',
              content: 'Los intereses comienzan a acumularse después de un período de gracia (tiempo de espera).\n\n'
                      'Fórmula:\n'
                      'M = C × (1 + r)ᵗ⁻ᵗ⁰\n'
                      '• t₀ = Tiempo de diferimiento\n'
                      '• r = Tasa de interés\n'
                      '• t = Tiempo total',
              isHighlighted: _tipoCapitalizacion == 'Diferida',
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              '💡 Ingrese los datos para calcular la capitalización:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 15),
            
            DropdownButtonFormField<String>(
              value: _tipoCapitalizacion,
              decoration: InputDecoration(
                labelText: 'Tipo de Capitalización',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.blue.shade50,
              ),
              items: _tiposCapitalizacion.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) => setState(() => _tipoCapitalizacion = value!),
            ),
            
            const SizedBox(height: 15),
            
            _buildInputField('Capital Inicial (\$)', _capitalController, icon: LucideIcons.dollarSign),
            
            const SizedBox(height: 15),
            
            _buildInputField('Tasa de Interés Anual (%)', _tasaController, icon: LucideIcons.percent),
            
            const SizedBox(height: 15),
            
            const Text('Tiempo:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildInputField('Años', _aniosController, icon: LucideIcons.calendar)),
                const SizedBox(width: 10),
                Expanded(child: _buildInputField('Meses', _mesesController, icon: LucideIcons.calendar)),
                const SizedBox(width: 10),
                Expanded(child: _buildInputField('Días', _diasController, icon: LucideIcons.clock)),
              ],
            ),
            
            if (_tipoCapitalizacion == 'Compuesta' || 
                _tipoCapitalizacion == 'Periódica' || 
                _tipoCapitalizacion == 'Anticipada') ...[
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _frecuenciaPeriodica,
                decoration: InputDecoration(
                  labelText: 'Frecuencia de Capitalización',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: Colors.blue.shade50,
                ),
                items: _frecuencias.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _frecuenciaPeriodica = value!),
              ),
            ],
            
            if (_tipoCapitalizacion == 'Diferida') ...[
              const SizedBox(height: 15),
              const Text('Tiempo de Diferimiento:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildInputField('Años', _diferimientoAniosController, icon: LucideIcons.calendar)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildInputField('Meses', _diferimientoMesesController, icon: LucideIcons.calendar)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildInputField('Días', _diferimientoDiasController, icon: LucideIcons.clock)),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('* El diferimiento se calcula usando el tiempo ingresado', 
                  style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
              ),
            ],
            
            const SizedBox(height: 15),
            _buildInputField('Monto Final (\$)', _resultadoController, 
                icon: LucideIcons.calculator, readOnly: true),
            
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCustomButton(
                  text: 'Calcular',
                  icon: LucideIcons.calculator,
                  onPressed: _calcular,
                ),
                _buildCustomButton(
                  text: 'Limpiar',
                  icon: LucideIcons.trash,
                  onPressed: _limpiarCampos,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _calcular() {
    try {
      double? C = double.tryParse(_capitalController.text);
      double? r = double.tryParse(_tasaController.text);
      int anios = int.tryParse(_aniosController.text) ?? 0;
      int meses = int.tryParse(_mesesController.text) ?? 0;
      int dias = int.tryParse(_diasController.text) ?? 0;
      int difAnios = int.tryParse(_diferimientoAniosController.text) ?? 0;
      int difMeses = int.tryParse(_diferimientoMesesController.text) ?? 0;
      int difDias = int.tryParse(_diferimientoDiasController.text) ?? 0;

      if (C == null || r == null || (anios == 0 && meses == 0 && dias == 0)) {
        throw Exception("Ingrese valores válidos");
      }

      // Convertir todo a años decimales
      double t = anios + (meses / 12) + (dias / 360);
      double M = 0;

      switch (_tipoCapitalizacion) {
        case 'Simple':
          M = C * (1 + (r / 100) * t);
          break;
        case 'Compuesta':
          int n = _obtenerPeriodosPorAno(_frecuenciaPeriodica);
          M = C * pow(1 + (r / 100) / n, n * t);
          break;
        case 'Continua':
          M = C * exp((r / 100) * t);
          break;
        case 'Periódica':
          int n = _obtenerPeriodosPorAno(_frecuenciaPeriodica);
          M = C * pow(1 + (r / 100) / n, n * t);
          break;
        case 'Anticipada':
          int n = _obtenerPeriodosPorAno(_frecuenciaPeriodica);
          M = C * pow(1 + (r / 100) / n, n * (t + 1));
          break;
        case 'Diferida':
          double t0 = difAnios + (difMeses / 12) + (difDias / 360);
          M = C * pow(1 + (r / 100), t - t0);
          break;
      }

      setState(() {
        _resultadoController.text = M.toStringAsFixed(2);
      });

      //
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _obtenerPeriodosPorAno(String frecuencia) {
    switch (frecuencia) {
      case 'Diario': return 360;
      case 'Semanal': return 52;
      case 'Quincenal': return 24;
      case 'Mensual': return 12;
      case 'Bimestral': return 6;
      case 'Trimestral': return 4;
      case 'Cuatrimestral': return 3;
      case 'Semestral': return 2;
      case 'Anual': return 1;
      default: return 1;
    }
  }

  void _limpiarCampos() {
    _capitalController.clear();
    _tasaController.clear();
    _aniosController.clear();
    _mesesController.clear();
    _diasController.clear();
    _resultadoController.clear();
    _diferimientoAniosController.clear();
    _diferimientoMesesController.clear();
    _diferimientoDiasController.clear();
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
                  Text(content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, 
      {IconData? icon, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blueGrey.shade700),
          filled: true,
          fillColor: readOnly ? Colors.grey.shade200 : Colors.blueGrey.shade50,
          prefixIcon: icon != null ? Icon(icon, color: Colors.blueGrey) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
        ),
        keyboardType: TextInputType.number,
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
          borderRadius: BorderRadius.circular(10.0),
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