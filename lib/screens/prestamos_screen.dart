import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class PrestamosScreen extends StatefulWidget {
  const PrestamosScreen({super.key});

  @override
  State<PrestamosScreen> createState() => _PrestamosScreenState();
}

class _PrestamosScreenState extends State<PrestamosScreen> {
  // Datos del usuario
  final String nombreUsuario = "Andres Orozco";
  double saldoDisponible = 40000000; // 40 millones iniciales
  
  // Listas para almacenar datos
  List<Map<String, dynamic>> solicitudesPrestamos = [];
  List<Map<String, dynamic>> prestamosActivos = [];
  List<Map<String, dynamic>> historialTransacciones = [];
  
  // Controladores para formularios
  final TextEditingController montoSolicitudController = TextEditingController();
  final TextEditingController aniosController = TextEditingController();
  final TextEditingController mesesController = TextEditingController();
  final TextEditingController diasController = TextEditingController();
  final TextEditingController tasaInteresController = TextEditingController();
  
  // Variables de estado
  int selectedTabIndex = 0;
  bool mostrarFormularioSolicitud = false;
  int contadorPrestamos = 1;
  
  // Tipos de cálculo disponibles
  final List<String> tiposCalculo = [
    'Interés Simple',
    'Interés Compuesto',
    'Anualidades',
    'Gradiente',
    'Amortización',
    'Capitalización'
  ];
  String? tipoCalculoSeleccionado;

  // Periodicidad de la tasa de interés
  final List<String> periodicidades = [
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
  String? periodicidadSeleccionada = 'Mensual';

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }
  
  void _cargarDatosIniciales() {
    setState(() {
      prestamosActivos = [
        {
          'id': '1',
          'monto': 5000000,
          'plazoMeses': 12,
          'tasa': 1.5,
          'periodicidad': 'Mensual',
          'cuota': 458333,
          'saldoPendiente': 3000000,
          'fechaAprobacion': DateTime.now().subtract(const Duration(days: 30)),
          'plazoDias': 0,
          'tipoCalculo': 'Interés Compuesto',
        }
      ];
      
      historialTransacciones = [
        {
          'tipo': 'ingreso',
          'monto': 5000000,
          'fecha': DateTime.now().subtract(const Duration(days: 30)),
          'descripcion': 'Préstamo aprobado #1',
          'saldoPosterior': 45000000,
        },
        {
          'tipo': 'egreso',
          'monto': 458333,
          'fecha': DateTime.now().subtract(const Duration(days: 15)),
          'descripcion': 'Pago cuota préstamo #1',
          'saldoPosterior': 44541667,
        },
      ];
      
      saldoDisponible = 44541667;
      contadorPrestamos = 2;
    });
  }
  
  void _solicitarNuevoPrestamo() {
    if (tipoCalculoSeleccionado == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tipo de cálculo requerido'),
          content: const Text('Por favor seleccione el tipo de cálculo para el préstamo.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
      return;
    }
    
    if (periodicidadSeleccionada == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Periodicidad requerida'),
          content: const Text('Por favor seleccione la periodicidad de la tasa de interés.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
      return;
    }
    
    final monto = double.tryParse(montoSolicitudController.text) ?? 0;
    final anios = int.tryParse(aniosController.text) ?? 0;
    final meses = int.tryParse(mesesController.text) ?? 0;
    final dias = int.tryParse(diasController.text) ?? 0;
    final tasa = double.tryParse(tasaInteresController.text) ?? 0;
    
    final plazoMeses = anios * 12 + meses + (dias / 30).round();
    final plazoDias = dias % 30;
    
    if (monto > 0 && plazoMeses > 0 && tasa > 0) {
      final nuevaSolicitud = {
        'id': contadorPrestamos.toString(),
        'monto': monto,
        'plazoMeses': plazoMeses,
        'plazoDias': plazoDias,
        'tasa': tasa,
        'periodicidad': periodicidadSeleccionada,
        'fechaSolicitud': DateTime.now(),
        'estado': 'pendiente',
        'tipoCalculo': tipoCalculoSeleccionado,
      };
      
      // Registrar solo la solicitud (no afecta el saldo todavía)
      final transaccion = {
        'tipo': 'solicitud',
        'monto': monto,
        'fecha': DateTime.now(),
        'descripcion': 'Solicitud préstamo #${contadorPrestamos}',
        'saldoPosterior': saldoDisponible,
      };
      
      setState(() {
        solicitudesPrestamos.add(nuevaSolicitud);
        historialTransacciones.insert(0, transaccion);
        contadorPrestamos++;
        mostrarFormularioSolicitud = false;
        montoSolicitudController.clear();
        aniosController.clear();
        mesesController.clear();
        diasController.clear();
        tasaInteresController.clear();
        tipoCalculoSeleccionado = null;
        periodicidadSeleccionada = 'Mensual';
      });
    }
  }
  
  void _aprobarSolicitud(int index) {
    final solicitud = solicitudesPrestamos[index];
    final monto = solicitud['monto'];
    final plazoMeses = solicitud['plazoMeses'];
    double tasa = solicitud['tasa'] / 100; // Convertir a decimal
    
    // Convertir tasa a mensual para cálculos
    switch (solicitud['periodicidad']) {
      case 'Diario':
        tasa = tasa * 30; // Convertir tasa diaria a mensual
        break;
      case 'Semanal':
        tasa = tasa * 4; // Convertir tasa semanal a mensual (aproximación)
        break;
      case 'Quincenal':
        tasa = tasa * 2; // Convertir tasa quincenal a mensual
        break;
      case 'Bimestral':
        tasa = tasa / 2; // Convertir tasa bimestral a mensual
        break;
      case 'Trimestral':
        tasa = tasa / 3; // Convertir tasa trimestral a mensual
        break;
      case 'Cuatrimestral':
        tasa = tasa / 4; // Convertir tasa cuatrimestral a mensual
        break;
      case 'Semestral':
        tasa = tasa / 6; // Convertir tasa semestral a mensual
        break;
      case 'Anual':
        tasa = tasa / 12; // Convertir tasa anual a mensual
        break;
      // Mensual no necesita conversión
    }
    
    // Calcular cuota mensual según el tipo de cálculo seleccionado
    double cuota;
    switch (solicitud['tipoCalculo']) {
      case 'Interés Simple':
        cuota = _calcularInteresSimple(monto, tasa, plazoMeses);
        break;
      case 'Interés Compuesto':
        cuota = _calcularInteresCompuesto(monto, tasa, plazoMeses);
        break;
      case 'Anualidades':
        cuota = _calcularAnualidades(monto, tasa, plazoMeses);
        break;
      case 'Gradiente':
        cuota = _calcularGradiente(monto, tasa, plazoMeses);
        break;
      case 'Amortización':
        cuota = _calcularAmortizacion(monto, tasa, plazoMeses);
        break;
      case 'Capitalización':
        cuota = _calcularCapitalizacion(monto, tasa, plazoMeses);
        break;
      default:
        cuota = _calcularInteresCompuesto(monto, tasa, plazoMeses);
    }
    
    final nuevoPrestamo = {
      'id': solicitud['id'],
      'monto': monto,
      'plazoMeses': plazoMeses,
      'plazoDias': solicitud['plazoDias'],
      'tasa': solicitud['tasa'],
      'periodicidad': solicitud['periodicidad'],
      'cuota': cuota,
      'saldoPendiente': monto,
      'fechaAprobacion': DateTime.now(),
      'tipoCalculo': solicitud['tipoCalculo'],
    };
    
    // Registrar transacción de ingreso (préstamo aprobado)
    final transaccion = {
      'tipo': 'ingreso',
      'monto': monto,
      'fecha': DateTime.now(),
      'descripcion': 'Préstamo aprobado #${solicitud['id']}',
      'saldoPosterior': saldoDisponible + monto,
    };
    
    setState(() {
      prestamosActivos.add(nuevoPrestamo);
      solicitudesPrestamos[index]['estado'] = 'aprobado';
      saldoDisponible += monto; // Aumentar saldo disponible al aprobar
      historialTransacciones.insert(0, transaccion);
      
      // Actualizar la transacción de solicitud en el historial
      final solicitudIndex = historialTransacciones.indexWhere(
        (t) => t['descripcion'] == 'Solicitud préstamo #${solicitud['id']}');
      
      if (solicitudIndex != -1) {
        historialTransacciones[solicitudIndex]['estado'] = 'aprobada';
      }
    });
  }
  
  // Métodos de cálculo (implementaciones básicas)
  double _calcularInteresSimple(double monto, double tasa, int plazo) {
    return (monto * tasa * plazo) / plazo;
  }
  
  double _calcularInteresCompuesto(double monto, double tasa, int plazo) {
    return (monto * tasa) / (1 - pow(1 + tasa, -plazo));
  }
  
  double _calcularAnualidades(double monto, double tasa, int plazo) {
    return monto * (tasa * pow(1 + tasa, plazo)) / (pow(1 + tasa, plazo) - 1);
  }
  
  double _calcularGradiente(double monto, double tasa, int plazo) {
    return (monto * tasa) / (1 - pow(1 + tasa, -plazo));
  }
  
  double _calcularAmortizacion(double monto, double tasa, int plazo) {
    return (monto * tasa) / (1 - pow(1 + tasa, -plazo));
  }
  
  double _calcularCapitalizacion(double monto, double tasa, int plazo) {
    return monto * pow(1 + tasa, plazo) * tasa / (pow(1 + tasa, plazo) - 1);
  }
  
  void _pagarCuota(int prestamoIndex) {
    final prestamo = prestamosActivos[prestamoIndex];
    final cuota = prestamo['cuota'];
    
    if (saldoDisponible >= cuota) {
      final transaccion = {
        'tipo': 'egreso',
        'monto': cuota,
        'fecha': DateTime.now(),
        'descripcion': 'Pago cuota préstamo #${prestamo['id']}',
        'saldoPosterior': saldoDisponible - cuota,
      };
      
      setState(() {
        prestamosActivos[prestamoIndex]['saldoPendiente'] -= cuota;
        saldoDisponible -= cuota;
        historialTransacciones.insert(0, transaccion);
        
        if (prestamosActivos[prestamoIndex]['saldoPendiente'] <= 0) {
          prestamosActivos.removeAt(prestamoIndex);
        }
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Saldo Insuficiente'),
          content: const Text('No tienes suficiente saldo para realizar este pago.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }
  
  Widget _buildPanelSaldo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueAccent.shade400,
              Colors.blueAccent.shade700,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Bienvenido, $nombreUsuario',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Saldo Disponible',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '\$${NumberFormat('#,###').format(saldoDisponible)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSolicitudesPrestamos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Solicitudes de Préstamo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(LucideIcons.plus, size: 16),
              label: const Text('Nueva Solicitud'),
              onPressed: () => setState(() => mostrarFormularioSolicitud = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        
        if (mostrarFormularioSolicitud) ...[
          _buildFormularioSolicitud(),
          const SizedBox(height: 15),
        ],
        
        if (solicitudesPrestamos.isEmpty)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(LucideIcons.fileSearch, size: 40, color: Colors.grey.shade400),
                    const SizedBox(height: 10),
                    const Text(
                      'No hay solicitudes de préstamo',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...List.generate(solicitudesPrestamos.length, (index) {
            final solicitud = solicitudesPrestamos[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Préstamo #${solicitud['id']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Chip(
                          label: Text(
                            solicitud['estado'] == 'pendiente' ? 'Pendiente' : 'Aprobado',
                            style: TextStyle(
                              color: solicitud['estado'] == 'pendiente' 
                                  ? Colors.orange.shade800 
                                  : Colors.green.shade800,
                            ),
                          ),
                          backgroundColor: solicitud['estado'] == 'pendiente' 
                              ? Colors.orange.shade100 
                              : Colors.green.shade100,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tipo de cálculo:', style: TextStyle(color: Colors.grey)),
                        Text(
                          solicitud['tipoCalculo'] ?? 'No especificado',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Periodicidad:', style: TextStyle(color: Colors.grey)),
                        Text(
                          solicitud['periodicidad'] ?? 'No especificada',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Monto:', style: TextStyle(color: Colors.grey)),
                        Text(
                          '\$${NumberFormat('#,###').format(solicitud['monto'])}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Plazo:', style: TextStyle(color: Colors.grey)),
                        Text(
                          '${solicitud['plazoMeses']} meses ${solicitud['plazoDias'] > 0 ? '${solicitud['plazoDias']} días' : ''}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tasa:', style: TextStyle(color: Colors.grey)),
                        Text(
                          '${solicitud['tasa']}% ${solicitud['periodicidad']?.toString().toLowerCase() ?? ''}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (solicitud['estado'] == 'pendiente')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _aprobarSolicitud(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Aprobar Préstamo'),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
  
  Widget _buildFormularioSolicitud() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Nueva Solicitud de Préstamo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            
            // Campo para seleccionar tipo de cálculo
            DropdownButtonFormField<String>(
              value: tipoCalculoSeleccionado,
              decoration: InputDecoration(
                labelText: 'Tipo de cálculo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.blueGrey.shade50,
              ),
              items: tiposCalculo.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  tipoCalculoSeleccionado = newValue;
                });
              },
              validator: (value) => value == null ? 'Seleccione un tipo' : null,
            ),
            const SizedBox(height: 10),
            
            // Tasa de interés y periodicidad en la misma fila (CAMBIO IMPLEMENTADO)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: tasaInteresController,
                    decoration: InputDecoration(
                      labelText: 'Tasa de interés',
                      suffixText: '%',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.blueGrey.shade50,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: periodicidadSeleccionada,
                    decoration: InputDecoration(
                      labelText: 'Periodicidad',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.blueGrey.shade50,
                    ),
                    items: periodicidades.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        periodicidadSeleccionada = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            TextField(
              controller: montoSolicitudController,
              decoration: InputDecoration(
                labelText: 'Monto a solicitar',
                prefixText: '\$',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.blueGrey.shade50,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            
            const Text(
              'Plazo del préstamo',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: aniosController,
                    decoration: InputDecoration(
                      labelText: 'Años',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.blueGrey.shade50,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: mesesController,
                    decoration: InputDecoration(
                      labelText: 'Meses',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.blueGrey.shade50,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: diasController,
                    decoration: InputDecoration(
                      labelText: 'Días',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.blueGrey.shade50,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => setState(() => mostrarFormularioSolicitud = false),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _solicitarNuevoPrestamo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Enviar Solicitud'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPrestamosActivos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Préstamos Activos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        
        if (prestamosActivos.isEmpty)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(LucideIcons.wallet, size: 40, color: Colors.grey.shade400),
                    const SizedBox(height: 10),
                    const Text(
                      'No tienes préstamos activos',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...List.generate(prestamosActivos.length, (index) {
            final prestamo = prestamosActivos[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Préstamo #${prestamo['id']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Chip(
                          label: const Text('Activo'),
                          backgroundColor: Colors.blue.shade100,
                          labelStyle: TextStyle(color: Colors.blue.shade800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildInfoRow('Tipo de cálculo:', prestamo['tipoCalculo'] ?? 'No especificado'),
                    _buildInfoRow('Periodicidad:', prestamo['periodicidad'] ?? 'No especificada'),
                    _buildInfoRow('Monto inicial:', '\$${NumberFormat('#,###').format(prestamo['monto'])}'),
                    _buildInfoRow('Saldo pendiente:', '\$${NumberFormat('#,###').format(prestamo['saldoPendiente'])}'),
                    _buildInfoRow('Plazo:', '${prestamo['plazoMeses']} meses ${prestamo['plazoDias'] > 0 ? '${prestamo['plazoDias']} días' : ''}'),
                    _buildInfoRow('Tasa interés:', '${prestamo['tasa']}% ${prestamo['periodicidad']?.toString().toLowerCase() ?? ''}'),
                    _buildInfoRow('Cuota mensual:', '\$${NumberFormat('#,###').format(prestamo['cuota'])}'),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _pagarCuota(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Pagar Cuota'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  Widget _buildHistorialTransacciones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Historial de Transacciones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        
        if (historialTransacciones.isEmpty)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(LucideIcons.history, size: 40, color: Colors.grey.shade400),
                    const SizedBox(height: 10),
                    const Text(
                      'No hay transacciones registradas',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...List.generate(historialTransacciones.length, (index) {
            final transaccion = historialTransacciones[index];
            final isIngreso = transaccion['tipo'] == 'ingreso';
            final isEgreso = transaccion['tipo'] == 'egreso';
            final isSolicitud = transaccion['tipo'] == 'solicitud';
            
            Color color;
            IconData icono;
            
            if (isIngreso) {
              color = Colors.green;
              icono = LucideIcons.arrowDownCircle;
            } else if (isEgreso) {
              color = Colors.red;
              icono = LucideIcons.arrowUpCircle;
            } else {
              color = Colors.orange;
              icono = LucideIcons.fileText;
            }
            
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(icono, color: color),
                title: Text(transaccion['descripcion']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('dd/MM/yyyy - HH:mm').format(transaccion['fecha'])),
                    if (transaccion['saldoPosterior'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Saldo posterior: \$${NumberFormat('#,###').format(transaccion['saldoPosterior'])}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ],
                ),
                trailing: Text(
                  isSolicitud 
                    ? 'Solicitud' 
                    : '\$${NumberFormat('#,###').format(transaccion['monto'])}',
                  style: TextStyle(
                    color: isSolicitud ? Colors.grey : color,
                    fontWeight: FontWeight.bold,
                    fontSize: isSolicitud ? 12 : 16,
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Préstamos'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildPanelSaldo(),
              const SizedBox(height: 20),
              IndexedStack(
                index: selectedTabIndex,
                children: [
                  _buildSolicitudesPrestamos(),
                  _buildPrestamosActivos(),
                  _buildHistorialTransacciones(),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTabIndex,
        onTap: (index) => setState(() => selectedTabIndex = index),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.fileText),
            label: 'Solicitudes',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.wallet),
            label: 'Mis Préstamos',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.history),
            label: 'Historial',
          ),
        ],
      ),
    );
  }
}