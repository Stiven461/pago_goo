import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class AmortizacionScreen extends StatefulWidget {
  const AmortizacionScreen({super.key});

  @override
  State<AmortizacionScreen> createState() => _AmortizacionScreenState();
}

class _AmortizacionScreenState extends State<AmortizacionScreen> {
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _tasaController = TextEditingController();
  final TextEditingController _plazoController = TextEditingController();
  
  String _tipoAmortizacion = 'Francés';
  String _frecuenciaCapitalizacion = 'Mensual';
  List<Map<String, dynamic>> _tablaAmortizacion = [];
  List<FlSpot> _graficoCapital = [];
  List<FlSpot> _graficoIntereses = [];
  double _totalIntereses = 0;
  double _totalPagado = 0;

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
        title: const Text('Sistemas de Amortización'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              icon: LucideIcons.info,
              title: '¿Qué es la Amortización?',
              content: 'La amortización es el proceso de pago gradual de una deuda a través de pagos periódicos que incluyen capital e intereses. Diferentes sistemas determinan cómo se distribuyen estos componentes a lo largo del tiempo.',
            ),
            
            const SizedBox(height: 15),
            
            _buildSectionCard(
              icon: LucideIcons.functionSquare,
              title: 'Sistema Francés (Cuotas Fijas)',
              content: 'El método más común, con pagos constantes donde la proporción de capital e intereses varía en cada período.\n\n'
                      'Fórmula de la cuota:\n'
                      'A = (P × r) / [1 - (1 + r)⁻ⁿ]\n'
                      '• A = Cuota periódica\n'
                      '• P = Capital inicial\n'
                      '• r = Tasa de interés periódica\n'
                      '• n = Número de pagos',
              isHighlighted: _tipoAmortizacion == 'Francés',
            ),
            
            const SizedBox(height: 10),
            
            _buildSectionCard(
              icon: LucideIcons.functionSquare,
              title: 'Sistema Alemán (Cuotas Decrecientes)',
              content: 'Amortización constante de capital con intereses sobre saldo, resultando en pagos decrecientes.\n\n'
                      'Fórmulas:\n'
                      'Amortización fija (A) = P / n\n'
                      'Pago total (Cₜ) = A + Iₜ\n'
                      '• P = Capital inicial\n'
                      '• n = Número de pagos\n'
                      '• Iₜ = Saldo × r (intereses del período)',
              isHighlighted: _tipoAmortizacion == 'Alemán',
            ),
            
            const SizedBox(height: 10),
            
            _buildSectionCard(
              icon: LucideIcons.functionSquare,
              title: 'Sistema Americano (Pago Final)',
              content: 'Solo se pagan intereses periódicamente y el capital se liquida al final del plazo.\n\n'
                      'Fórmula:\n'
                      'Intereses = P × r\n'
                      '• P = Capital inicial\n'
                      '• r = Tasa de interés periódica\n\n'
                      'Último pago = P + (P × r)',
              isHighlighted: _tipoAmortizacion == 'Americano',
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              '💡 Ingrese los datos para calcular la amortización:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 15),
            
            DropdownButtonFormField<String>(
              value: _tipoAmortizacion,
              decoration: InputDecoration(
                labelText: 'Tipo de Amortización',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.blue.shade50,
              ),
              items: ['Francés', 'Alemán', 'Americano'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) => setState(() => _tipoAmortizacion = value!),
            ),
            
            const SizedBox(height: 15),
            
            _buildInputField('Monto del Préstamo (\$)', _montoController, icon: LucideIcons.dollarSign),
            _buildInputField('Tasa de Interés Anual (%)', _tasaController, icon: LucideIcons.percent),
            _buildInputField('Plazo (Años)', _plazoController, icon: LucideIcons.calendar),
            
            const SizedBox(height: 15),
            
            DropdownButtonFormField<String>(
              value: _frecuenciaCapitalizacion,
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
              onChanged: (value) => setState(() => _frecuenciaCapitalizacion = value!),
            ),
            
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCustomButton(
                  text: 'Calcular',
                  icon: LucideIcons.calculator,
                  onPressed: _calcularAmortizacion,
                ),
                _buildCustomButton(
                  text: 'Limpiar',
                  icon: LucideIcons.trash,
                  onPressed: _limpiarCampos,
                ),
              ],
            ),
            
            if (_tablaAmortizacion.isNotEmpty) ...[
              const SizedBox(height: 30),
              _buildResumenResultados(),
              const SizedBox(height: 20),
              _buildGraficoAmortizacion(),
              const SizedBox(height: 20),
              _buildTablaAmortizacion(),
            ],
          ],
        ),
      ),
    );
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
      default: return 12;
    }
  }

  void _calcularAmortizacion() {
    try {
      double P = double.parse(_montoController.text);
      double tasaAnual = double.parse(_tasaController.text) / 100;
      int anos = int.parse(_plazoController.text);
      
      // Calcular parámetros según frecuencia
      int periodosPorAno = _obtenerPeriodosPorAno(_frecuenciaCapitalizacion);
      double r = tasaAnual / periodosPorAno;
      int n = anos * periodosPorAno;
      
      List<Map<String, dynamic>> tabla = [];
      List<FlSpot> puntosCapital = [];
      List<FlSpot> puntosIntereses = [];
      
      double totalIntereses = 0;
      double saldo = P;
      
      if (_tipoAmortizacion == 'Francés') {
        // Cálculo sistema francés
        double A = (P * r) / (1 - pow(1 + r, -n));
        
        for (int t = 1; t <= n; t++) {
          double intereses = saldo * r;
          double capital = A - intereses;
          saldo -= capital;
          
          tabla.add({
            'periodo': t,
            'cuota': A,
            'capital': capital,
            'intereses': intereses,
            'saldo': saldo,
          });
          
          puntosCapital.add(FlSpot(t.toDouble(), capital));
          puntosIntereses.add(FlSpot(t.toDouble(), intereses));
          totalIntereses += intereses;
        }
      } 
      else if (_tipoAmortizacion == 'Alemán') {
        // Cálculo sistema alemán (CORREGIDO)
        double A = P / n;  // Amortización fija
        
        for (int t = 1; t <= n; t++) {
          double I_t = saldo * r;  // Intereses del período
          double C_t = A + I_t;    // Cuota total del período
          
          tabla.add({
            'periodo': t,
            'cuota': C_t,
            'capital': A,
            'intereses': I_t,
            'saldo': saldo,
          });
          
          puntosCapital.add(FlSpot(t.toDouble(), A));
          puntosIntereses.add(FlSpot(t.toDouble(), I_t));
          totalIntereses += I_t;
          saldo -= A;  // Reducir el saldo por la amortización fija
        }
      } 
      else if (_tipoAmortizacion == 'Americano') {
        // Cálculo sistema americano
        double interesesPeriodicos = P * r;
        
        for (int t = 1; t <= n; t++) {
          double capital = (t == n) ? P : 0;
          double cuota = (t == n) ? P + interesesPeriodicos : interesesPeriodicos;
          
          tabla.add({
            'periodo': t,
            'cuota': cuota,
            'capital': capital,
            'intereses': interesesPeriodicos,
            'saldo': (t == n) ? 0 : P,
          });
          
          puntosCapital.add(FlSpot(t.toDouble(), capital));
          puntosIntereses.add(FlSpot(t.toDouble(), interesesPeriodicos));
          totalIntereses += interesesPeriodicos;
        }
      }
      
      setState(() {
        _tablaAmortizacion = tabla;
        _graficoCapital = puntosCapital;
        _graficoIntereses = puntosIntereses;
        _totalIntereses = totalIntereses;
        _totalPagado = P + totalIntereses;
      });
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              'RESUMEN DE AMORTIZACIÓN ${_tipoAmortizacion.toUpperCase()}',
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
                _buildResultItem('Total Intereses', '\$${_totalIntereses.toStringAsFixed(2)}'),
                _buildResultItem('Total Pagado', '\$${_totalPagado.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildResultItem('Cuota Promedio', '\$${(_totalPagado / _tablaAmortizacion.length).toStringAsFixed(2)}'),
                _buildResultItem('Monto Préstamo', '\$${_montoController.text}'),
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

  Widget _buildGraficoAmortizacion() {
    // Determinar el valor máximo para el eje Y
    double maxYValue = 0;
    if (_graficoCapital.isNotEmpty && _graficoIntereses.isNotEmpty) {
      final maxCapital = _graficoCapital.map((spot) => spot.y).reduce(max);
      final maxInteres = _graficoIntereses.map((spot) => spot.y).reduce(max);
      maxYValue = (maxCapital + maxInteres) * 1.2; // 20% más alto que el máximo
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'EVOLUCIÓN DE PAGOS - ${_tipoAmortizacion.toUpperCase()}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: maxYValue > 0 ? maxYValue / 5 : 1,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: Colors.grey.shade300,
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: (_tablaAmortizacion.length / 5).ceilToDouble(),
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blueGrey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: maxYValue > 0 ? maxYValue / 5 : 1,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blueGrey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  minX: 0,
                  maxX: _tablaAmortizacion.length.toDouble(),
                  minY: 0,
                  maxY: maxYValue,
                  lineBarsData: [
                    // Línea de intereses (naranja)
                    LineChartBarData(
                      spots: _graficoIntereses,
                      isCurved: true,
                      color: const Color(0xFFFFA726), // Naranja claro
                      barWidth: 3,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFFFFA726).withOpacity(0.1),
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: const Color(0xFFFFA726),
                          );
                        },
                      ),
                    ),
                    // Línea de capital (azul)
                    LineChartBarData(
                      spots: _graficoCapital,
                      isCurved: true,
                      color: const Color(0xFF42A5F5), // Azul claro
                      barWidth: 3,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF42A5F5).withOpacity(0.1),
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: const Color(0xFF42A5F5),
                          );
                        },
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blueAccent.withOpacity(0.9),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          final isInteres = spot.barIndex == 0;
                          return LineTooltipItem(
                            '${isInteres ? 'Interés' : 'Capital'} - Periodo ${spot.x.toInt()}\n'
                            'Monto: \$${spot.y.toStringAsFixed(2)}',
                            TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(const Color(0xFFFFA726), 'Intereses'),
                const SizedBox(width: 20),
                _buildLegendItem(const Color(0xFF42A5F5), 'Capital'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTablaAmortizacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'DETALLE DE PAGOS - ${_tipoAmortizacion.toUpperCase()}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Colors.white,
                child: DataTable(
                  columnSpacing: 20,
                  dataRowHeight: 40,
                  headingRowHeight: 45,
                  headingRowColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) => Colors.blueAccent.withOpacity(0.1),
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Período',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Cuota',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        'Capital',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        'Intereses',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text(
                        'Saldo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      numeric: true,
                    ),
                  ],
                  rows: _tablaAmortizacion.map((item) {
                    final bool isLastRow = item['periodo'] == _tablaAmortizacion.length;
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            item['periodo'].toString(),
                            style: const TextStyle(
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '\$${item['cuota'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '\$${item['capital'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF42A5F5), // Azul claro para capital
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '\$${item['intereses'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFFFFA726), // Naranja para intereses
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            '\$${item['saldo'].toStringAsFixed(2)}',
                            style: TextStyle(
                              color: item['saldo'] <= 0 ? Colors.green : Colors.blueGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      color: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (isLastRow) {
                            return Colors.green.withOpacity(0.05);
                          }
                          return item['periodo'] % 2 == 0 
                              ? Colors.blue.shade50.withOpacity(0.3)
                              : Colors.transparent;
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
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
                  Text(content),
                ],
              ),
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

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.blueGrey,
          ),
        ),
      ],
    );
  }

  void _limpiarCampos() {
    _montoController.clear();
    _tasaController.clear();
    _plazoController.clear();
    setState(() {
      _tablaAmortizacion = [];
      _graficoCapital = [];
      _graficoIntereses = [];
      _totalIntereses = 0;
      _totalPagado = 0;
    });
  }
}