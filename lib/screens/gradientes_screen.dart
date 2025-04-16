import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class GradientesScreen extends StatefulWidget {
  const GradientesScreen({super.key});

  @override
  State<GradientesScreen> createState() => _GradientesScreenState();
}

class _GradientesScreenState extends State<GradientesScreen> {
  final TextEditingController _valorInicialController = TextEditingController();
  final TextEditingController _tasaInteresController = TextEditingController();
  final TextEditingController _gradienteController = TextEditingController();
  final TextEditingController _resultadoController = TextEditingController();
  final TextEditingController _aniosController = TextEditingController();
  final TextEditingController _mesesController = TextEditingController();
  final TextEditingController _diasController = TextEditingController();
  
  String _tipoGradiente = 'Aritmético';
  String _tipoCalculo = 'Valor Presente';
  String _variacion = 'Creciente';
  String _frecuenciaCapitalizacion = 'Mensual';
  String _tipoTasaInteres = 'Anual';
  
  List<FlSpot> _graficoFlujos = [];
  double _resultadoCalculado = 0;

  final List<String> _tiposGradiente = ['Aritmético', 'Geométrico'];
  final List<String> _tiposCalculo = ['Valor Presente', 'Valor Futuro'];
  final List<String> _variaciones = ['Creciente', 'Decreciente'];
  final List<String> _frecuencias = [
    'Diario', 'Semanal', 'Quincenal', 'Mensual', 
    'Bimestral', 'Trimestral', 'Cuatrimestral', 'Semestral', 'Anual'
  ];
  final List<String> _tiposTasaInteres = [
    'Diario', 'Semanal', 'Quincenal', 'Mensual', 
    'Bimestral', 'Trimestral', 'Cuatrimestral', 'Semestral', 'Anual'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Gradientes'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              icon: LucideIcons.info,
              title: '¿Qué son los Gradientes?',
              content: 'Un gradiente es una serie de pagos o flujos de caja que crecen o decrecen de manera '
                  'constante (gradiente aritmético) o porcentual (gradiente geométrico). Se utilizan para '
                  'modelar situaciones donde los flujos de dinero no son uniformes en el tiempo.',
            ),
            
            const SizedBox(height: 15),
            
            _buildSectionCard(
              icon: LucideIcons.functionSquare,
              title: 'Gradiente Aritmético',
              content: 'Los pagos varían en una cantidad constante (G) cada período.\n\n'
                      'Fórmulas Valor Presente:\n'
                      'Creciente: VP = A[(1 - (1 + i)⁻ⁿ)/i] + (G/i)[(1 - (1 + i)⁻ⁿ)/i - n(1 + i)⁻ⁿ]\n'
                      'Decreciente: VP = A[(1 - (1 + i)⁻ⁿ)/i] - (G/i)[(1 - (1 + i)⁻ⁿ)/i - n(1 + i)⁻ⁿ]\n\n'
                      'Fórmulas Valor Futuro:\n'
                      'Creciente: VF = A[((1 + i)ⁿ - 1)/i] + (G/i)[((1 + i)ⁿ - 1)/i - n]\n'
                      'Decreciente: VF = A[((1 + i)ⁿ - 1)/i] - (G/i)[((1 + i)ⁿ - 1)/i - n]',
              isHighlighted: _tipoGradiente == 'Aritmético',
            ),
            
            const SizedBox(height: 10),
            
            _buildSectionCard(
              icon: LucideIcons.functionSquare,
              title: 'Gradiente Geométrico',
              content: 'Los pagos varían en un porcentaje constante (G%) cada período.\n\n'
                      'Fórmulas Valor Presente:\n'
                      'Creciente: VP = A[1 - ((1 + g)/(1 + i))ⁿ]/(i - g)\n'
                      'Si g = i: VP = A * n / (1 + i)\n'
                      'Decreciente: VP = A[1 - ((1 - g)/(1 + i))ⁿ]/(i + g)\n\n'
                      'Fórmulas Valor Futuro:\n'
                      'Creciente: VF = A[(1 + g)ⁿ - (1 + i)ⁿ]/(g - i)\n'
                      'Si g = i: VF = A * n * (1 + i)ⁿ⁻¹\n'
                      'Decreciente: VF = A[(1 + i)ⁿ - (1 - g)ⁿ]/(i + g)',
              isHighlighted: _tipoGradiente == 'Geométrico',
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              '💡 Ingrese los datos para calcular:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 15),
            
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    value: _tipoGradiente,
                    label: 'Tipo de Gradiente',
                    onChanged: (value) => setState(() => _tipoGradiente = value!),
                    items: _tiposGradiente,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDropdown(
                    value: _tipoCalculo,
                    label: 'Tipo de Cálculo',
                    onChanged: (value) => setState(() => _tipoCalculo = value!),
                    items: _tiposCalculo,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 15),
            
            _buildDropdown(
              value: _variacion,
              label: 'Variación',
              onChanged: (value) => setState(() => _variacion = value!),
              items: _variaciones,
            ),
            
            const SizedBox(height: 15),
            
            _buildInputField(
              _tipoGradiente == 'Aritmético' ? 'Valor inicial (A)' : 'Primer pago (A)',
              _valorInicialController,
              icon: LucideIcons.dollarSign,
            ),
            
            const SizedBox(height: 15),
            
            _buildInputField(
              _tipoGradiente == 'Aritmético' ? 'Variación constante (G)' : 'Variación porcentual (G %)',
              _gradienteController,
              icon: LucideIcons.percent,
            ),
            
            const SizedBox(height: 15),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildInputField(
                    'Tasa de interés (%)',
                    _tasaInteresController,
                    icon: LucideIcons.percent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _buildDropdown(
                    value: _tipoTasaInteres,
                    label: 'Periodicidad',
                    onChanged: (value) => setState(() => _tipoTasaInteres = value!),
                    items: _tiposTasaInteres,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 15),
            
            _buildPeriodoInput(),
            
            const SizedBox(height: 15),
            
            _buildDropdown(
              value: _frecuenciaCapitalizacion,
              label: 'Frecuencia de Capitalización',
              onChanged: (value) => setState(() => _frecuenciaCapitalizacion = value!),
              items: _frecuencias,
            ),
            
            const SizedBox(height: 15),
            
            _buildInputField(
              'Resultado',
              _resultadoController,
              icon: LucideIcons.calculator,
              readOnly: true,
              suffixText: _tipoCalculo == 'Valor Presente' ? 'VP' : 'VF',
            ),
            
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCustomButton(
                  text: 'Calcular',
                  icon: LucideIcons.calculator,
                  onPressed: _calcularGradiente,
                ),
                _buildCustomButton(
                  text: 'Limpiar',
                  icon: LucideIcons.trash2,
                  onPressed: _limpiarCampos,
                ),
              ],
            ),
            
            if (_graficoFlujos.isNotEmpty) ...[
              const SizedBox(height: 30),
              _buildResumenResultados(),
              const SizedBox(height: 20),

            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResumenResultados() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'RESUMEN DE GRADIENTE ${_tipoGradiente.toUpperCase()}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResultItem('Tipo de Cálculo', _tipoCalculo),
                _buildResultItem('Variación', _variacion),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResultItem(
                  'Resultado', 
                  '${_tipoCalculo == 'Valor Presente' ? 'VP' : 'VF'}: \$${_resultadoCalculado.toStringAsFixed(2)}'
                ),
                _buildResultItem(
                  'Primer Pago', 
                  '\$${_valorInicialController.text}'
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Frecuencia: $_frecuenciaCapitalizacion',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  /////////////////////////////////////////////

  Widget _buildPeriodoInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Duración del período',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                'Años',
                _aniosController,
                icon: LucideIcons.calendar,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildInputField(
                'Meses',
                _mesesController,
                icon: LucideIcons.calendar,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildInputField(
                'Días',
                _diasController,
                icon: LucideIcons.calendar,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _calcularGradiente() {
    try {
      if (_valorInicialController.text.isEmpty ||
          _gradienteController.text.isEmpty ||
          _tasaInteresController.text.isEmpty ||
          (_aniosController.text.isEmpty && 
           _mesesController.text.isEmpty && 
           _diasController.text.isEmpty)) {
        throw Exception('Por favor complete todos los campos');
      }

      double A = double.parse(_valorInicialController.text);
      double G = double.parse(_gradienteController.text);
      double tasa = double.parse(_tasaInteresController.text);
      
      int anios = _aniosController.text.isEmpty ? 0 : int.parse(_aniosController.text);
      int meses = _mesesController.text.isEmpty ? 0 : int.parse(_mesesController.text);
      int dias = _diasController.text.isEmpty ? 0 : int.parse(_diasController.text);
      
      if (A <= 0) throw Exception('El valor inicial debe ser positivo');
      if (tasa < 0) throw Exception('La tasa de interés no puede ser negativa');
      if (anios < 0 || meses < 0 || dias < 0) throw Exception('Los períodos no pueden ser negativos');
      if (anios == 0 && meses == 0 && dias == 0) throw Exception('Ingrese al menos un período');
      
      double n = _calcularPeriodosTotales(anios, meses, dias);
      double i = _convertirTasaInteres(tasa, _tipoTasaInteres, _frecuenciaCapitalizacion);
      
      double resultado = 0;
      
      // Generar puntos para el gráfico
      List<FlSpot> puntosGrafico = [];
      
      if (_tipoGradiente == 'Aritmético') {
        double flujoActual = A;
        double variacion = G;
        
        for (int periodo = 1; periodo <= n; periodo++) {
          puntosGrafico.add(FlSpot(periodo.toDouble(), flujoActual));
          
          if (_variacion == 'Creciente') {
            flujoActual += variacion;
          } else {
            flujoActual -= variacion;
          }
        }
        
        if (_tipoCalculo == 'Valor Presente') {
          double factor1 = (1 - pow(1 + i, -n)) / i;
          double factor2 = (factor1 - n * pow(1 + i, -n)) / i;
          
          if (_variacion == 'Creciente') {
            resultado = A * factor1 + G * factor2;
          } else {
            resultado = A * factor1 - G * factor2;
          }
        } else {
          double factor1 = (pow(1 + i, n) - 1) / i;
          double factor2 = (factor1 - n) / i;
          
          if (_variacion == 'Creciente') {
            resultado = A * factor1 + G * factor2;
          } else {
            resultado = A * factor1 - G * factor2;
          }
        }
      } else { 
        double g = G / 100;
        double flujoActual = A;
        
        for (int periodo = 1; periodo <= n; periodo++) {
          puntosGrafico.add(FlSpot(periodo.toDouble(), flujoActual));
          
          if (_variacion == 'Creciente') {
            flujoActual *= (1 + g);
          } else {
            flujoActual *= (1 - g);
          }
        }
        
        if (_tipoCalculo == 'Valor Presente') {
          if (_variacion == 'Creciente') {
            if (g == i) {
              resultado = A * n / (1 + i);
            } else {
              resultado = A * (1 - pow((1 + g)/(1 + i), n)) / (i - g);
            }
          } else {
            resultado = A * (1 - pow((1 - g)/(1 + i), n)) / (i + g);
          }
        } else {
          if (_variacion == 'Creciente') {
            if (g == i) {
              resultado = A * n * pow(1 + i, n - 1);
            } else {
              resultado = A * (pow(1 + g, n) - pow(1 + i, n)) / (g - i);
            }
          } else {
            resultado = A * (pow(1 + i, n) - pow(1 - g, n)) / (i + g);
          }
        }
      }
      
      setState(() {
        _resultadoCalculado = resultado;
        _resultadoController.text = resultado.toStringAsFixed(2);
        _graficoFlujos = puntosGrafico;
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

  double _convertirTasaInteres(double tasa, String tipoTasa, String frecuenciaCapitalizacion) {
    double tasaDiaria;
    
    switch (tipoTasa) {
      case 'Diario':
        tasaDiaria = tasa / 100;
        break;
      case 'Semanal':
        tasaDiaria = tasa / 100 / 7;
        break;
      case 'Quincenal':
        tasaDiaria = tasa / 100 / 15;
        break;
      case 'Mensual':
        tasaDiaria = tasa / 100 / 30;
        break;
      case 'Bimestral':
        tasaDiaria = tasa / 100 / 60;
        break;
      case 'Trimestral':
        tasaDiaria = tasa / 100 / 90;
        break;
      case 'Cuatrimestral':
        tasaDiaria = tasa / 100 / 120;
        break;
      case 'Semestral':
        tasaDiaria = tasa / 100 / 180;
        break;
      case 'Anual':
        tasaDiaria = tasa / 100 / 360;
        break;
      default:
        tasaDiaria = tasa / 100 / 30;
    }
    
    switch (frecuenciaCapitalizacion) {
      case 'Diario':
        return tasaDiaria;
      case 'Semanal':
        return tasaDiaria * 7;
      case 'Quincenal':
        return tasaDiaria * 15;
      case 'Mensual':
        return tasaDiaria * 30;
      case 'Bimestral':
        return tasaDiaria * 60;
      case 'Trimestral':
        return tasaDiaria * 90;
      case 'Cuatrimestral':
        return tasaDiaria * 120;
      case 'Semestral':
        return tasaDiaria * 180;
      case 'Anual':
        return tasaDiaria * 360;
      default:
        return tasaDiaria * 30;
    }
  }

  double _calcularPeriodosTotales(int anios, int meses, int dias) {
    int totalDias = (anios * 360) + (meses * 30) + dias;
    
    switch (_frecuenciaCapitalizacion) {
      case 'Diario': 
        return totalDias.toDouble();
      case 'Semanal': 
        return (totalDias / 7).toDouble();
      case 'Quincenal': 
        return (totalDias / 15).toDouble();
      case 'Mensual': 
        return (totalDias / 30).toDouble();
      case 'Bimestral': 
        return (totalDias / 60).toDouble();
      case 'Trimestral': 
        return (totalDias / 90).toDouble();
      case 'Cuatrimestral': 
        return (totalDias / 120).toDouble();
      case 'Semestral': 
        return (totalDias / 180).toDouble();
      case 'Anual': 
        return (totalDias / 360).toDouble();
      default: 
        return (totalDias / 30).toDouble();
    }
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

  Widget _buildInputField(String label, TextEditingController controller, {IconData? icon, bool readOnly = false, String? suffixText}) {
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
          suffixText: suffixText,
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

  Widget _buildDropdown({
    required String value,
    required String label,
    required Function(String?) onChanged,
    required List<String> items,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blueGrey.shade700),
        filled: true,
        fillColor: Colors.blueGrey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
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

  Widget _buildResultItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _limpiarCampos() {
    _valorInicialController.clear();
    _tasaInteresController.clear();
    _gradienteController.clear();
    _resultadoController.clear();
    _aniosController.clear();
    _mesesController.clear();
    _diasController.clear();
    setState(() {
      _graficoFlujos = [];
      _resultadoCalculado = 0;
    });
  }
}