import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class AnualidadesScreen extends StatefulWidget {
  const AnualidadesScreen({super.key});

  @override
  _AnualidadesScreenState createState() => _AnualidadesScreenState();
}

class _AnualidadesScreenState extends State<AnualidadesScreen> {
  final TextEditingController pagoController = TextEditingController();
  final TextEditingController tasaController = TextEditingController();
  final TextEditingController periodosAnualesController = TextEditingController();
  final TextEditingController valorFuturoController = TextEditingController();
  final TextEditingController valorPresenteController = TextEditingController();
  
  // Frecuencias
  String frecuenciaPago = 'Trimestral';
  String frecuenciaCapitalizacion = 'Mensual';
  
  final List<String> frecuencias = [
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

  // Datos para el gráfico
  List<FlSpot> puntosGraficoVF = [];
  List<FlSpot> puntosGraficoVA = [];
  double maxY = 0;
  double maxX = 0;
  bool showChart = false;
  String tipoCalculo = 'VF'; // 'VF' o 'VA'

  // Obtener número de períodos por año según frecuencia
  int _obtenerPeriodosPorAno(String frecuencia) {
    switch (frecuencia) {
      case 'Diario':    return 360;
      case 'Semanal':   return 52;
      case 'Quincenal': return 24;
      case 'Mensual':   return 12;
      case 'Bimestral': return 6;
      case 'Trimestral': return 4;
      case 'Cuatrimestral': return 3;
      case 'Semestral': return 2;
      case 'Anual':     return 1;
      default:          return 1;
    }
  }

  // Convertir tasa nominal anual a tasa por período de capitalización
  double convertirTasa(double tasaNominalAnual, String frecuenciaCap) {
    final periodosPorAno = _obtenerPeriodosPorAno(frecuenciaCap);
    return tasaNominalAnual / periodosPorAno;
  }

  // Calcular número total de períodos de capitalización
  double calcularPeriodosTotales(double anos, String frecuenciaCap) {
    final capitalizacionesPorAno = _obtenerPeriodosPorAno(frecuenciaCap);
    return anos * capitalizacionesPorAno;
  }

  // Generar datos para el gráfico de Valor Futuro (SIMPLIFICADO - sin subperíodos)
  void generarDatosGraficoVF(double pago, double i, double n, double k) {
    puntosGraficoVF = [];
    double acumulado = 0;
    final totalPagos = (n / k).ceil();
    
    // Punto inicial
    puntosGraficoVF.add(FlSpot(0, 0));
    
    for (int periodo = 1; periodo <= totalPagos; periodo++) {
      // Aplicar capitalizaciones y pago
      acumulado = acumulado * pow(1 + i, k) + pago;
      
      // Solo agregamos el punto final del período
      puntosGraficoVF.add(FlSpot(periodo.toDouble(), acumulado));
    }
    
    maxY = acumulado * 1.2;
    maxX = totalPagos.toDouble();
  }

  // Generar datos para el gráfico de Valor Presente
  void generarDatosGraficoVA(double pago, double i, double n, double k) {
    puntosGraficoVA = [];
    double valorActual = 0;
    final totalPagos = (n / k).ceil();
    
    // Empezamos desde el final hacia atrás
    for (int periodo = totalPagos; periodo >= 0; periodo--) {
      if (periodo < totalPagos) {
        valorActual = (valorActual + pago) / pow(1 + i, k);
      }
      puntosGraficoVA.add(FlSpot(periodo.toDouble(), valorActual));
    }
    
    puntosGraficoVA = puntosGraficoVA.reversed.toList();
    maxY = valorActual * 1.5;
    maxX = totalPagos.toDouble();
  }

  void calcularValorFuturo() {
    double? pago = double.tryParse(pagoController.text);
    double? tasaNominalAnual = double.tryParse(tasaController.text);
    double? anos = double.tryParse(periodosAnualesController.text);

    if (pago != null && tasaNominalAnual != null && anos != null && anos > 0) {
      double i = convertirTasa(tasaNominalAnual, frecuenciaCapitalizacion) / 100;
      double n = calcularPeriodosTotales(anos, frecuenciaCapitalizacion);
      
      final pagosPorAno = _obtenerPeriodosPorAno(frecuenciaPago);
      final capPorAno = _obtenerPeriodosPorAno(frecuenciaCapitalizacion);
      final k = capPorAno / pagosPorAno;
      
      double vf = pago * ((pow(1 + i, n) - 1) / (pow(1 + i, k) - 1));
      
      generarDatosGraficoVF(pago, i, n, k);
      
      setState(() {
        valorFuturoController.text = vf.toStringAsFixed(2);
        valorPresenteController.clear();
        showChart = true;
        tipoCalculo = 'VF';
      });
    }
  }

  void calcularValorPresente() {
    double? pago = double.tryParse(pagoController.text);
    double? tasaNominalAnual = double.tryParse(tasaController.text);
    double? anos = double.tryParse(periodosAnualesController.text);

    if (pago != null && tasaNominalAnual != null && anos != null && anos > 0) {
      double i = convertirTasa(tasaNominalAnual, frecuenciaCapitalizacion) / 100;
      double n = calcularPeriodosTotales(anos, frecuenciaCapitalizacion);
      
      final pagosPorAno = _obtenerPeriodosPorAno(frecuenciaPago);
      final capPorAno = _obtenerPeriodosPorAno(frecuenciaCapitalizacion);
      final k = capPorAno / pagosPorAno;
      
      double va = pago * ((1 - pow(1 + i, -n)) / (pow(1 + i, k) - 1));
      
      generarDatosGraficoVA(pago, i, n, k);
      
      setState(() {
        valorPresenteController.text = va.toStringAsFixed(2);
        valorFuturoController.clear();
        showChart = true;
        tipoCalculo = 'VA';
      });
    }
  }

  void limpiarCampos() {
    pagoController.clear();
    tasaController.clear();
    periodosAnualesController.clear();
    valorFuturoController.clear();
    valorPresenteController.clear();
    setState(() {
      puntosGraficoVF = [];
      puntosGraficoVA = [];
      showChart = false;
    });
  }

  Widget _buildGrafico() {
    final puntos = tipoCalculo == 'VF' ? puntosGraficoVF : puntosGraficoVA;
    final titulo = tipoCalculo == 'VF' ? 'VALOR FUTURO (VF)' : 'VALOR PRESENTE (VA)';
    final resultado = tipoCalculo == 'VF' 
        ? valorFuturoController.text 
        : valorPresenteController.text;

    if (puntos.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Text(
          'Realice un cálculo para ver el gráfico',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value == value.toInt()) {
                          return Text(
                            'P${value.toInt()}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.blueGrey,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.blueGrey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.blueAccent.withOpacity(0.9),
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${tipoCalculo == 'VF' ? 'Periodo' : 'Pago'} ${spot.x.toStringAsFixed(2)}\n'
                          'Valor: \$${spot.y.toStringAsFixed(2)}',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: puntos,
                    isCurved: false,
                    color: Colors.blueAccent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: false),
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
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        Text(
          '\$$resultado',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anualidades'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              icon: LucideIcons.info,
              title: '¿Qué son las anualidades?',
              content:
                  'Las anualidades son pagos periódicos iguales realizados durante un tiempo determinado. Se usan en préstamos, seguros y planes de retiro. Tipos de anualidades incluyen: Ordinarias (pagos al final del período), Anticipadas (pagos al inicio) y Diferidas (pagos comienzan después de un tiempo).',
            ),
            const SizedBox(height: 15),
            _buildSectionCard(
              icon: LucideIcons.calculator,
              title: 'Fórmulas de Anualidades',
              content: 'Valor Futuro: VF = A × [(1 + i)ⁿ - 1] / [(1 + i)ᵏ - 1]\n'
                      'Valor Presente: VA = A × [1 - (1 + i)⁻ⁿ] / [(1 + i)ᵏ - 1]\n'
                      'Donde k = capitalizaciones por período de pago',
              isHighlighted: true,
            ),
            const SizedBox(height: 20),
            const Text(
              '💡 Ingrese los valores y deje en blanco el campo a calcular:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildInputField('Pago Periódico (A)', pagoController, icon: LucideIcons.dollarSign),
            _buildInputField('Tasa Nominal Anual (%)', tasaController, icon: LucideIcons.percent),
            _buildInputField('Años', periodosAnualesController, icon: LucideIcons.calendar),
            
            const SizedBox(height: 15),
            _buildDropdown(
              value: frecuenciaPago,
              label: 'Frecuencia de Pago',
              onChanged: (value) => setState(() => frecuenciaPago = value!),
            ),
            const SizedBox(height: 15),
            _buildDropdown(
              value: frecuenciaCapitalizacion,
              label: 'Frecuencia de Capitalización',
              onChanged: (value) => setState(() => frecuenciaCapitalizacion = value!),
            ),
            
            const SizedBox(height: 20),
            _buildInputField('Valor Futuro (VF)', valorFuturoController, icon: LucideIcons.trendingUp),
            _buildInputField('Valor Presente (VA)', valorPresenteController, icon: LucideIcons.trendingDown),
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCustomButton(
                  text: 'Calcular VF',
                  icon: LucideIcons.calculator,
                  onPressed: calcularValorFuturo,
                ),
                _buildCustomButton(
                  text: 'Calcular VA',
                  icon: LucideIcons.calculator,
                  onPressed: calcularValorPresente,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center( // Botón centrado
              child: _buildCustomButton(
                text: 'Limpiar Campos',
                icon: LucideIcons.trash,
                onPressed: limpiarCampos,
              ),
            ),
            
            if (showChart) ...[
              const SizedBox(height: 30),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildGrafico(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        filled: true,
        fillColor: Colors.blueGrey.shade50,
      ),
      items: frecuencias.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
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