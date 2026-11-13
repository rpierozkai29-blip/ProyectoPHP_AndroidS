import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Controlador para saber qué pantalla mostrar
  int _vistaActual = 0;

  // Variables de filtros globales a nivel de Dashboard
  int? _filtroPeriodoId;
  int? _filtroCategoriaId;
  int? _filtroEventoId;

  List<dynamic> _listaPeriodos = [];
  List<dynamic> _listaCategorias = [];

  final List<String> _titulos = [
    'Resumen General',
    'Análisis de Ventas',
    'Rendimiento de Cursos',
    'Métricas de Clientes',
  ];

  void _cerrarSesion() async {
    await ApiService().logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  // ESTA ES LA FUNCIÓN DEL MODAL (AHORA EN SU LUGAR CORRECTO)
  void _mostrarPanelFiltros(BuildContext context) async {
    if (_listaPeriodos.isEmpty) {
      final filtros = await ApiService().getFiltrosBase();
      if (filtros != null) {
        _listaPeriodos = filtros['periodos'];
        _listaCategorias = filtros['categorias'];
      }
    }

    int? tempPeriodoId = _filtroPeriodoId;
    int? tempCategoriaId = _filtroCategoriaId;
    int? tempEventoId = _filtroEventoId;
    List<dynamic> tempEventos = [];
    bool cargandoEventos = false;

    Future<void> recargarEventos(StateSetter setModalState) async {
      setModalState(() => cargandoEventos = true);
      final ev = await ApiService().getEventosDinamicos(
        periodoId: tempPeriodoId,
        categoriaId: tempCategoriaId,
      );
      setModalState(() {
        tempEventos = ev ?? [];
        cargandoEventos = false;
        if (!tempEventos.any((e) => e['id'] == tempEventoId)) {
          tempEventoId = null;
        }
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filtros Analíticos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Periodo Académico',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: tempPeriodoId,
                    items: _listaPeriodos
                        .map(
                          (p) => DropdownMenuItem<int>(
                            value: int.parse(
                              p['id'].toString(),
                            ), // <- Conversión segura
                            child: Text(p['nombre'].toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setModalState(() => tempPeriodoId = val);
                      recargarEventos(setModalState);
                    },
                  ),
                  SizedBox(height: 16),

                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: tempCategoriaId,
                    items: _listaCategorias
                        .map(
                          (c) => DropdownMenuItem<int>(
                            value: int.parse(
                              c['id'].toString(),
                            ), // <- Conversión segura
                            child: Text(c['nombre'].toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setModalState(() => tempCategoriaId = val);
                      recargarEventos(setModalState);
                    },
                    hint: Text("Seleccionar Categoría"),
                  ),
                  SizedBox(height: 16),

                  cargandoEventos
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        )
                      : DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: 'Curso Específico',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          value: tempEventoId,
                          hint: Text("Todos los cursos"),
                          items: tempEventos
                              .map(
                                (e) => DropdownMenuItem<int>(
                                  value: int.parse(
                                    e['id'].toString(),
                                  ), // <- Conversión segura
                                  child: Text(
                                    e['nombre_evento'].toString(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setModalState(() => tempEventoId = val);
                          },
                        ),

                  SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _filtroPeriodoId = null;
                              _filtroCategoriaId = null;
                              _filtroEventoId = null;
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Limpiar',
                            style: TextStyle(color: AppTheme.primary),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _filtroPeriodoId = tempPeriodoId;
                              _filtroCategoriaId = tempCategoriaId;
                              _filtroEventoId = tempEventoId;
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Aplicar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _construirVistaActual() {
    switch (_vistaActual) {
      case 0:
        return _VistaResumen(
          periodoId: _filtroPeriodoId,
          categoriaId: _filtroCategoriaId,
          eventoId: _filtroEventoId,
        );
      case 1:
        return _VistaVentas(
          periodoId: _filtroPeriodoId,
          categoriaId: _filtroCategoriaId,
          eventoId: _filtroEventoId,
        );
      case 2:
        return _VistaCursos(
          periodoId: _filtroPeriodoId,
          categoriaId: _filtroCategoriaId,
          eventoId: _filtroEventoId,
        );
      case 3:
        return _VistaClientes(periodoId: _filtroPeriodoId);
      default:
        return _VistaResumen(
          periodoId: _filtroPeriodoId,
          categoriaId: _filtroCategoriaId,
          eventoId: _filtroEventoId,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_vistaActual]),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: AppTheme.primary),
            onPressed: () {
              _mostrarPanelFiltros(
                context,
              ); // Ahora sí funciona porque la función está en esta clase
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 60, bottom: 30),
              color: AppTheme.primary,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.analytics_rounded,
                      size: 40,
                      color: AppTheme.primary,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'BI - Escuela EDP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Panel Analítico',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            _crearItemMenu(Icons.dashboard_rounded, 'Resumen', 0),
            _crearItemMenu(Icons.trending_up_rounded, 'Ventas', 1),
            _crearItemMenu(Icons.menu_book_rounded, 'Cursos', 2),
            _crearItemMenu(Icons.people_alt_rounded, 'Clientes', 3),
            Spacer(),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: _cerrarSesion,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      body: _construirVistaActual(),
    );
  }

  Widget _crearItemMenu(IconData icono, String titulo, int indice) {
    bool seleccionado = _vistaActual == indice;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: seleccionado
            ? AppTheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icono,
          color: seleccionado ? AppTheme.primary : AppTheme.textMuted,
        ),
        title: Text(
          titulo,
          style: TextStyle(
            color: seleccionado ? AppTheme.primary : AppTheme.textDark,
            fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() {
            _vistaActual = indice;
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}

// Sub-widget de Resumen
class _VistaResumen extends StatefulWidget {
  final int? periodoId;
  final int? categoriaId;
  final int? eventoId;

  const _VistaResumen({this.periodoId, this.categoriaId, this.eventoId});

  @override
  __VistaResumenState createState() => __VistaResumenState();
}

class __VistaResumenState extends State<_VistaResumen> {
  Map<String, dynamic>? resumenData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void didUpdateWidget(_VistaResumen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.periodoId != widget.periodoId ||
        oldWidget.categoriaId != widget.categoriaId ||
        oldWidget.eventoId != widget.eventoId) {
      _cargarDatos();
    }
  }

  Future<void> _cargarDatos() async {
    final data = await ApiService().getResumen(
      periodoId: widget.periodoId,
      categoriaId: widget.categoriaId,
      eventoId: widget.eventoId,
    );
    if (mounted) {
      setState(() {
        resumenData = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }
    if (resumenData == null) {
      return Center(
        child: Text(
          'Error al cargar datos',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      color: AppTheme.primary,
      child: ListView(
        padding: EdgeInsets.all(20),
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          _buildKpiCard(
            'Ventas del Mes',
            'S/ ${resumenData!['ventas_mes']}',
            Icons.monetization_on_rounded,
          ),
          _buildKpiCard(
            'Nuevos Alumnos',
            '${resumenData!['nuevos_alumnos']}',
            Icons.school_rounded,
          ),
          _buildKpiCard(
            'Cursos Activos',
            '${resumenData!['cursos_activos']}',
            Icons.class_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: AppTheme.primary),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                    ),
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

// Sub-widget Tendencia de Ventas
class _VistaVentas extends StatefulWidget {
  final int? periodoId;
  final int? categoriaId;
  final int? eventoId;

  const _VistaVentas({this.periodoId, this.categoriaId, this.eventoId});

  @override
  __VistaVentasState createState() => __VistaVentasState();
}

class __VistaVentasState extends State<_VistaVentas> {
  List<dynamic>? tendenciaData;
  List<dynamic>? metodosData;
  List<dynamic>? origenesData;
  bool isLoading = true;

  // Paleta de colores para gráficos basada en el Color Vino EDP
  final List<Color> _chartColors = [
    AppTheme.primary,
    Color(0xFFB03A55), // Vino intermedio
    Color(0xFFD65C78), // Rosa/Vino suave
    Color(0xFF2D3436), // Gris oscuro contraste
    Color(0xFF636E72), // Gris claro
  ];

  @override
  void initState() {
    super.initState();
    _cargarTodosLosGraficos();
  }

  @override
  void didUpdateWidget(_VistaVentas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.periodoId != widget.periodoId ||
        oldWidget.categoriaId != widget.categoriaId ||
        oldWidget.eventoId != widget.eventoId) {
      _cargarTodosLosGraficos();
    }
  }

  Future<void> _cargarTodosLosGraficos() async {
    setState(() => isLoading = true);

    // Future.wait ejecuta las peticiones en paralelo para cargar mucho más rápido
    final responses = await Future.wait([
      ApiService().getVentasTendencia(
        periodoId: widget.periodoId,
        categoriaId: widget.categoriaId,
        eventoId: widget.eventoId,
      ),
      ApiService().getVentasPorMetodo(
        periodoId: widget.periodoId,
        categoriaId: widget.categoriaId,
        eventoId: widget.eventoId,
      ),
      ApiService().getVentasPorOrigen(
        periodoId: widget.periodoId,
        categoriaId: widget.categoriaId,
        eventoId: widget.eventoId,
      ),
    ]);

    if (mounted) {
      setState(() {
        tendenciaData = responses[0];
        metodosData = responses[1];
        origenesData = responses[2];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    // ListView permite hacer scroll vertical si la pantalla del celular es pequeña
    return RefreshIndicator(
      onRefresh: _cargarTodosLosGraficos,
      color: AppTheme.primary,
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          _construirGraficoTendencia(),
          SizedBox(height: 24),
          _construirGraficoMetodos(),
          SizedBox(height: 24),
          _construirGraficoOrigenes(),
        ],
      ),
    );
  }

  // --- GRÁFICO 1: LÍNEAS (TENDENCIA) ---
  Widget _construirGraficoTendencia() {
    if (tendenciaData == null || tendenciaData!.isEmpty) {
      return _tarjetaVacia(
        'Tendencia de Ingresos',
        'No hay registros en este periodo.',
      );
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < tendenciaData!.length; i++) {
      spots.add(
        FlSpot(
          i.toDouble(),
          double.parse(tendenciaData![i]['total'].toString()),
        ),
      );
    }

    return _contenedorGrafico(
      titulo: 'Tendencia de Ingresos',
      subtitulo: 'Evolución mensual (S/)',
      alto: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey[200], strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < tendenciaData!.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        tendenciaData![index]['mes'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    );
                  }
                  return Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return Text('');
                  // Simplificar montos grandes (Ej: 15000 -> 15k)
                  String textoY = value >= 1000
                      ? '${(value / 1000).toStringAsFixed(0)}k'
                      : value.toInt().toString();
                  return Text(
                    textoY,
                    style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primary.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- GRÁFICO 2: DONUT (MÉTODOS DE PAGO) ---
  Widget _construirGraficoMetodos() {
    if (metodosData == null || metodosData!.isEmpty) {
      return _tarjetaVacia('Métodos de Pago', 'No hay registros suficientes.');
    }

    return _contenedorGrafico(
      titulo: 'Distribución por Método',
      subtitulo: 'Canales de recaudación',
      alto: 250,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: metodosData!.asMap().entries.map((e) {
                  int index = e.key;
                  var item = e.value;
                  return PieChartSectionData(
                    color: _chartColors[index % _chartColors.length],
                    value: double.parse(item['total'].toString()),
                    title:
                        '', // Ocultamos el título interior para limpieza visual
                    radius: 30,
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: metodosData!.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _chartColors[e.key % _chartColors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.value['metodo_pago'].toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'S/ ${e.value['total']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // --- GRÁFICO 3: BARRAS (ORIGEN DE VENTA) ---
  Widget _construirGraficoOrigenes() {
    if (origenesData == null || origenesData!.isEmpty) {
      return _tarjetaVacia(
        'Rendimiento por Origen',
        'No hay registros suficientes.',
      );
    }

    double maxTotal = 0;
    for (var item in origenesData!) {
      if (double.parse(item['total'].toString()) > maxTotal)
        maxTotal = double.parse(item['total'].toString());
    }

    return _contenedorGrafico(
      titulo: 'Top Orígenes de Venta',
      subtitulo: 'Canales de contacto más rentables',
      alto: 320,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxTotal * 1.2, // Darle aire en la parte superior
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return Text('');
                  String textoY = value >= 1000
                      ? '${(value / 1000).toStringAsFixed(0)}k'
                      : value.toInt().toString();
                  return Text(
                    textoY,
                    style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < origenesData!.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      // Mostrar un texto corto o truncado si es muy largo
                      child: Text(
                        origenesData![index]['origen'].toString().substring(
                          0,
                          origenesData![index]['origen'].toString().length > 7
                              ? 7
                              : origenesData![index]['origen']
                                    .toString()
                                    .length,
                        ),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    );
                  }
                  return Text('');
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.grey[200], strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: origenesData!.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: double.parse(e.value['total'].toString()),
                  color:
                      _chartColors[e.key %
                          _chartColors.length], // Usa colores de la paleta
                  width: 22,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // --- WIDGETS DE APOYO ESTRUCTURAL ---
  Widget _contenedorGrafico({
    required String titulo,
    required String subtitulo,
    required double alto,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        Text(
          subtitulo,
          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
        SizedBox(height: 16),
        Container(
          height: alto,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.cardShadow,
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.only(right: 20, left: 10, top: 30, bottom: 15),
          child: child,
        ),
      ],
    );
  }

  Widget _tarjetaVacia(String titulo, String mensaje) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Center(
            child: Text(mensaje, style: TextStyle(color: AppTheme.textMuted)),
          ),
        ),
      ],
    );
  }
}

// Sub-widget para la vista de Rendimiento de Cursos
class _VistaCursos extends StatefulWidget {
  final int? periodoId;
  final int? categoriaId;
  final int? eventoId;

  const _VistaCursos({this.periodoId, this.categoriaId, this.eventoId});

  @override
  __VistaCursosState createState() => __VistaCursosState();
}

class __VistaCursosState extends State<_VistaCursos> {
  List<dynamic>? cursosTopData;
  List<dynamic>? ocupacionData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarTodosLosGraficos();
  }

  @override
  void didUpdateWidget(_VistaCursos oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.periodoId != widget.periodoId ||
        oldWidget.categoriaId != widget.categoriaId ||
        oldWidget.eventoId != widget.eventoId) {
      _cargarTodosLosGraficos();
    }
  }

  Future<void> _cargarTodosLosGraficos() async {
    setState(() => isLoading = true);

    final responses = await Future.wait([
      ApiService().getCursosTop(
        periodoId: widget.periodoId,
        categoriaId: widget.categoriaId,
        eventoId: widget.eventoId,
      ),
      ApiService().getCursosOcupacion(
        periodoId: widget.periodoId,
        categoriaId: widget.categoriaId,
        eventoId: widget.eventoId,
      ),
    ]);

    if (mounted) {
      setState(() {
        cursosTopData = responses[0];
        ocupacionData = responses[1];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return Center(child: CircularProgressIndicator(color: AppTheme.primary));

    return RefreshIndicator(
      onRefresh: _cargarTodosLosGraficos,
      color: AppTheme.primary,
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          _construirGraficoCursosTop(),
          SizedBox(height: 24),
          _construirGraficoOcupacion(),
        ],
      ),
    );
  }

  // GRÁFICO 1: Barras (Alumnos por Curso)
  Widget _construirGraficoCursosTop() {
    if (cursosTopData == null || cursosTopData!.isEmpty)
      return SizedBox.shrink();

    double maxTotal = 0;
    for (var item in cursosTopData!) {
      if (double.parse(item['total_alumnos'].toString()) > maxTotal) {
        maxTotal = double.parse(item['total_alumnos'].toString());
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Cursos Demandados',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        Text(
          'Volumen de alumnos inscritos',
          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
        SizedBox(height: 16),
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.cardShadow,
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.only(right: 20, left: 10, top: 30, bottom: 15),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxTotal == 0 ? 10 : maxTotal * 1.2,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value == 0 || value % 1 != 0) return Text('');
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textMuted,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < cursosTopData!.length) {
                        String nombreCorto = cursosTopData![index]['curso']
                            .toString();
                        if (nombreCorto.length > 8)
                          nombreCorto = nombreCorto.substring(0, 8) + '...';
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            nombreCorto,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        );
                      }
                      return Text('');
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.grey[200], strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              barGroups: cursosTopData!.asMap().entries.map((e) {
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: double.parse(e.value['total_alumnos'].toString()),
                      color: AppTheme.primary,
                      width: 25,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // GRÁFICO 2: Barras de Progreso Analíticas (Tasa de Ocupación)
  Widget _construirGraficoOcupacion() {
    if (ocupacionData == null || ocupacionData!.isEmpty)
      return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tasa de Ocupación (Aforo)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        Text(
          'Inscritos vs Aforo Máximo Permitido',
          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.cardShadow,
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            children: ocupacionData!.map((item) {
              double inscritos = double.parse(item['inscritos'].toString());
              double aforo = double.parse(item['aforo_total'].toString());
              double porcentaje = aforo > 0 ? (inscritos / aforo) : 0;
              if (porcentaje > 1.0)
                porcentaje =
                    1.0; // Evitar que la barra desborde si hay sobreventa

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['curso'].toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${inscritos.toInt()} / ${aforo.toInt()} alu.',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: porcentaje,
                        minHeight: 10,
                        backgroundColor: AppTheme.primary.withValues(
                          alpha: 0.1,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          porcentaje >= 0.9 ? Colors.green : AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// Sub-widget para la vista de Métricas de Clientes
class _VistaClientes extends StatefulWidget {
  final int? periodoId;
  const _VistaClientes({this.periodoId});

  @override
  __VistaClientesState createState() => __VistaClientesState();
}

class __VistaClientesState extends State<_VistaClientes> {
  List<dynamic>? distritosData;
  List<dynamic>? evolucionData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarTodosLosGraficos();
  }

  @override
  void didUpdateWidget(_VistaClientes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.periodoId != widget.periodoId) {
      _cargarTodosLosGraficos();
    }
  }

  Future<void> _cargarTodosLosGraficos() async {
    setState(() => isLoading = true);

    final responses = await Future.wait([
      ApiService().getClientesPorDistrito(periodoId: widget.periodoId),
      ApiService().getClientesEvolucion(),
    ]);

    if (mounted) {
      setState(() {
        distritosData = responses[0];
        evolucionData = responses[1];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return Center(child: CircularProgressIndicator(color: AppTheme.primary));

    return RefreshIndicator(
      onRefresh: _cargarTodosLosGraficos,
      color: AppTheme.primary,
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          _construirGraficoEvolucion(),
          SizedBox(height: 24),
          _construirGraficoDistritos(),
        ],
      ),
    );
  }

  // GRÁFICO 1: Área (Evolución de Captación)
  Widget _construirGraficoEvolucion() {
    if (evolucionData == null || evolucionData!.isEmpty)
      return SizedBox.shrink();

    List<FlSpot> spots = [];
    for (int i = 0; i < evolucionData!.length; i++) {
      spots.add(
        FlSpot(
          i.toDouble(),
          double.parse(evolucionData![i]['total'].toString()),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evolución de Captación',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        Text(
          'Nuevos alumnos registrados por mes',
          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
        SizedBox(height: 16),
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.cardShadow,
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.only(right: 20, left: 10, top: 30, bottom: 15),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < evolucionData!.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            evolucionData![index]['mes'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        );
                      }
                      return Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    getTitlesWidget: (value, meta) {
                      if (value == 0 || value % 1 != 0) return Text('');
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textMuted,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppTheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: false,
                  ), // Ocultamos los puntos para que se vea como un área suave
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withValues(alpha: 0.3),
                        AppTheme.primary.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // GRÁFICO 2: Barras Horizontales (Top Distritos)
  Widget _construirGraficoDistritos() {
    if (distritosData == null || distritosData!.isEmpty)
      return SizedBox.shrink();

    double maxTotal = 0;
    for (var item in distritosData!) {
      if (double.parse(item['total'].toString()) > maxTotal)
        maxTotal = double.parse(item['total'].toString());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribución Geográfica',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        Text(
          'Top 5 distritos de procedencia',
          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
        ),
        SizedBox(height: 16),
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.cardShadow,
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.only(right: 20, left: 10, top: 30, bottom: 15),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxTotal == 0 ? 10 : maxTotal * 1.2,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value == 0 || value % 1 != 0) return Text('');
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textMuted,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < distritosData!.length) {
                        String nombreCorto = distritosData![index]['distrito']
                            .toString();
                        if (nombreCorto.length > 7)
                          nombreCorto = nombreCorto.substring(0, 7) + '..';
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            nombreCorto,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        );
                      }
                      return Text('');
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.grey[200], strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              barGroups: distritosData!.asMap().entries.map((e) {
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: double.parse(e.value['total'].toString()),
                      color: AppTheme.primary,
                      width: 25,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
