import 'package:flutter/material.dart';

import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? resumenData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() async {
    final data = await ApiService().getResumen();
    setState(() {
      resumenData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard EDP')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : resumenData == null
          ? Center(
              child: Text(
                'Error al cargar datos',
                style: TextStyle(color: Colors.red),
              ),
            )
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                _crearTarjeta(
                  'Ventas del Mes',
                  'S/ ${resumenData!['ventas_mes']}',
                  Colors.green,
                ),
                _crearTarjeta(
                  'Nuevos Alumnos',
                  '${resumenData!['nuevos_alumnos']}',
                  Colors.blue,
                ),
                _crearTarjeta(
                  'Cursos Activos',
                  '${resumenData!['cursos_activos']}',
                  Colors.orange,
                ),
              ],
            ),
    );
  }

  Widget _crearTarjeta(String titulo, String valor, Color color) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, radius: 10),
        title: Text(
          titulo,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          valor,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ),
    );
  }
}
