import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';

class TIRScreen extends StatefulWidget {
  const TIRScreen({super.key});

  @override
  State<TIRScreen> createState() => _TIRScreenState();
}

class _TIRScreenState extends State<TIRScreen> {
  final TextEditingController _inversionController = TextEditingController();
  final List<TextEditingController> _flujosControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  double? _tirResultado;
  String? _interpretacion;
  List<Map<String, dynamic>> _flujosCalculados = [];
  List<FlSpot> _puntosGrafico = [];

  void _calcularTIR() {
    try {
      final inversion = -double.parse(_inversionController.text);
      final flujos = _flujosControllers
          .where((controller) => controller.text.isNotEmpty)
          .map((controller) => double.parse(controller.text))
          .toList();
      
      if (flujos.isEmpty) throw Exception("Ingrese al menos un flujo de caja");

      final todosFlujos = [inversion, ...flujos];
      _flujosCalculados = _generarTablaFlujos(todosFlujos);
      _puntosGrafico = _generarPuntosGrafico(todosFlujos);
      
      final tir = _calcularTIRNewton(todosFlujos) * 100;
      
      setState(() {
        _tirResultado = tir;
        _interpretacion = tir >= 10 
            ? 'El proyecto es rentable (TIR ≥ 10%)'
            : 'El proyecto no es rentable (TIR < 10%)';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  List<Map<String, dynamic>> _generarTablaFlujos(List<double> flujos) {
    final List<Map<String, dynamic>> tabla = [];
    double acumulado = 0;

    for (int i = 0; i < flujos.length; i++) {
      acumulado += flujos[i];
      tabla.add({
        'año': i,
        'flujo': flujos[i],
        'acumulado': acumulado,
      });
    }

    return tabla;
  }

  List<FlSpot> _generarPuntosGrafico(List<double> flujos) {
    final List<FlSpot> puntos = [];
    double acumulado = 0;

    for (int i = 0; i < flujos.length; i++) {
      acumulado += flujos[i];
      puntos.add(FlSpot(i.toDouble(), acumulado));
    }

    return puntos;
  }

  double _calcularTIRNewton(List<double> flujos) {
    const double precision = 0.00001;
    const int maxIteraciones = 100;
    double tasa = 0.1;
    double diferencia = 1.0;
    int iteracion = 0;

    while (diferencia > precision && iteracion < maxIteraciones) {
      final vpn = _calcularVPN(flujos, tasa);
      final derivada = _calcularDerivadaVPN(flujos, tasa);
      
      if (derivada.abs() < precision) break;
      
      final nuevaTasa = tasa - vpn / derivada;
      diferencia = (nuevaTasa - tasa).abs();
      tasa = nuevaTasa;
      iteracion++;
    }

    return tasa;
  }

  double _calcularVPN(List<double> flujos, double tasa) {
    double vpn = 0.0;
    for (int t = 0; t < flujos.length; t++) {
      vpn += flujos[t] / pow(1 + tasa, t);
    }
    return vpn;
  }

  double _calcularDerivadaVPN(List<double> flujos, double tasa) {
    double derivada = 0.0;
    for (int t = 0; t < flujos.length; t++) {
      derivada -= t * flujos[t] / pow(1 + tasa, t + 1);
    }
    return derivada;
  }

  void _limpiarCampos() {
    _inversionController.clear();
    for (var controller in _flujosControllers) {
      controller.clear();
    }
    setState(() {
      _tirResultado = null;
      _interpretacion = null;
      _flujosCalculados = [];
      _puntosGrafico = [];
    });
  }

  void _agregarFlujo() {
    setState(() {
      _flujosControllers.add(TextEditingController());
    });
  }

  void _removerFlujo(int index) {
    if (_flujosControllers.length > 3) {
      setState(() {
        _flujosControllers.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasa Interna de Retorno (TIR)'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              icon: LucideIcons.info,
              title: '¿Qué es la TIR?',
              content: 'La Tasa Interna de Retorno (TIR) es un indicador financiero que permite medir la rentabilidad de una inversión o proyecto.'
'En otras palabras, representa el porcentaje de ganancia anual promedio que genera un proyecto durante su vida útil.'
'La TIR se interpreta como la tasa de interés que iguala el valor de lo que inviertes al inicio con el valor de los ingresos que recibirás en el futuro.'
,
              
            ),
            
            const SizedBox(height: 15),
            
            _buildFormulaCard(),
            
            const SizedBox(height: 15),
            
            _buildSectionCard(
              icon: LucideIcons.target,
              title: 'Interpretación',
              content: 'Si la TIR es mayor que la tasa mínima requerida (generalmente 10%), el proyecto se considera rentable.',
              isHighlighted: true,
            ),
            
            const SizedBox(height: 20),
            
            _buildInputField(
              'Inversión Inicial (\$)',
              _inversionController,
              icon: LucideIcons.dollarSign,
              helperText: 'Ejemplo: 100000',
            ),
            
            const SizedBox(height: 15),
            
            Row(
              children: [
                const Text(
                  'Flujos de Caja Anuales:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blueAccent),
                  onPressed: _agregarFlujo,
                  tooltip: 'Agregar otro año',
                ),
              ],
            ),
            
            Column(
              children: List.generate(_flujosControllers.length, (index) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        'Año ${index + 1}',
                        _flujosControllers[index],
                        icon: LucideIcons.calendar,
                        
                      ),
                    ),
                    if (_flujosControllers.length > 3)
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                        onPressed: () => _removerFlujo(index),
                        tooltip: 'Eliminar este año',
                      ),
                  ],
                );
              }),
            ),
            
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCustomButton(
                  text: 'Calcular TIR',
                  icon: LucideIcons.calculator,
                  onPressed: _calcularTIR,
                ),
                _buildCustomButton(
                  text: 'Limpiar',
                  icon: LucideIcons.trash,
                  onPressed: _limpiarCampos,
                ),
              ],
            ),
            
            if (_flujosCalculados.isNotEmpty) ...[
              const SizedBox(height: 30),
              _buildTablaFlujos(),
              const SizedBox(height: 20),
              _buildGraficoFlujos(),
            ],
            
            if (_tirResultado != null) ...[
              const SizedBox(height: 20),
              _buildResultCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTablaFlujos() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'FLUJO DE CAJA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.blueAccent.shade100),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('AÑO', 
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('FLUJO', 
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('ACUMULADO', 
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                    ),
                  ],
                ),
                ..._flujosCalculados.map((flujo) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(flujo['año'].toString(), 
                          textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('\$${flujo['flujo'].toStringAsFixed(0)}', 
                          textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('\$${flujo['acumulado'].toStringAsFixed(0)}', 
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: flujo['acumulado'] >= 0 
                                ? Colors.green 
                                : Colors.red,
                          )),
                    ),
                  ],
                )).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraficoFlujos() {
  final valoresAcumulados = _flujosCalculados.map((f) => f['acumulado'] as double).toList();
  
  // Encontrar el valor máximo y mínimo
  final maxValor = valoresAcumulados.reduce(max);
  final minValor = valoresAcumulados.reduce(min);
  
  // Asegurar que el rango del eje Y incluya el 0 y tenga márgenes adecuados
  final maxY = maxValor > 0 ? maxValor * 1.1 : 0.1;
  final minY = minValor < 0 ? minValor * 1.1 : -0.1;
  
  // Calcular intervalos para la cuadrícula
  final double intervalo = ((maxY - minY) / 5).abs();
  
  return Center(
    child: Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'GRÁFICO DE FLUJOS ACUMULADOS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            SizedBox(
              height: 250,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: _puntosGrafico.last.x,
                    minY: minY,
                    maxY: maxY,
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: intervalo,
                      verticalInterval: 1,
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Año ${value.toInt()}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          interval: intervalo,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                '\$${value.toInt()}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _puntosGrafico,
                        isCurved: true,
                        color: Colors.blueAccent,
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true, 
                          color: Colors.blueAccent.withOpacity(0.1)
                        ),
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.blueAccent,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            );
                          },
                        ),
                      ),
                    ],
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              'Año ${spot.x.toInt()}\n\$${spot.y.toStringAsFixed(2)}',
                              const TextStyle(color: Colors.white),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildFormulaCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fórmula TIR:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 18, color: Colors.black87),
                  children: [
                    TextSpan(text: '0 = '),
                    TextSpan(
                      text: '-C₀',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' + '),
                    TextSpan(
                      text: '∑',
                      style: TextStyle(fontSize: 24),
                    ),
                    TextSpan(
                      text: '(Fₜ / (1 + TIR)ᵗ)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Divider(),
            const SizedBox(height: 10),
            _buildSymbolExplanation('C₀', 'Inversión inicial (valor negativo)'),
            _buildSymbolExplanation('Fₜ', 'Flujo de caja en el año t'),
            _buildSymbolExplanation('TIR', 'Tasa Interna de Retorno a calcular'),
            _buildSymbolExplanation('t', 'Período de tiempo (año)'),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Card(
          color: _tirResultado! >= 10 ? Colors.green.shade50 : Colors.orange.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'RESULTADO TIR',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  '${_tirResultado!.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: _tirResultado! >= 10 ? Colors.green : Colors.orange,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    _interpretacion!,
                    style: TextStyle(
                      fontSize: 16,
                      color: _tirResultado! >= 10 ? Colors.green : Colors.orange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSymbolExplanation(String symbol, String meaning) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$symbol: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          Expanded(
            child: Text(meaning),
          ),
        ],
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
                  Text(content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label, 
    TextEditingController controller, {
    IconData? icon,
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          labelStyle: TextStyle(color: Colors.blueGrey.shade700),
          filled: true,
          fillColor: Colors.blueGrey.shade50,
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