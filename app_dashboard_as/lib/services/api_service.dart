import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Reemplaza los X con tu IP local real
  static const String baseUrl = 'http://10.13.210.225:8000/api';

  Future<bool> login(String usuario, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'usuario': usuario, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['access_token'];

        // Guarda el token de Sanctum de forma segura en el celular
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        return true;
      }
      return false;
    } catch (e) {
      print('Error de red: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getResumen({
    int? periodoId,
    int? categoriaId,
    int? eventoId,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      if (token == null) return null;

      // Construir URL con parámetros
      String url = '$baseUrl/dashboard/resumen?';
      if (periodoId != null) url += 'periodo_id=$periodoId&';
      if (categoriaId != null) url += 'categoria_id=$categoriaId&';
      if (eventoId != null) url += 'evento_id=$eventoId&';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); // Borra el token de Sanctum
  }

  Future<List<dynamic>?> getVentasTendencia({
    int? periodoId,
    int? categoriaId,
    int? eventoId,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      if (token == null) return null;

      String url = '$baseUrl/dashboard/ventas-tendencia?';
      if (periodoId != null) url += 'periodo_id=$periodoId&';
      if (categoriaId != null) url += 'categoria_id=$categoriaId&';
      if (eventoId != null) url += 'evento_id=$eventoId&';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>?> getVentasPorMetodo({
    int? periodoId,
    int? categoriaId,
    int? eventoId,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      String url = '$baseUrl/dashboard/ventas-metodos?';
      if (periodoId != null) url += 'periodo_id=$periodoId&';
      if (categoriaId != null) url += 'categoria_id=$categoriaId&';
      if (eventoId != null) url += 'evento_id=$eventoId&';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>?> getVentasPorOrigen({
    int? periodoId,
    int? categoriaId,
    int? eventoId,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      String url = '$baseUrl/dashboard/ventas-origenes?';
      if (periodoId != null) url += 'periodo_id=$periodoId&';
      if (categoriaId != null) url += 'categoria_id=$categoriaId&';
      if (eventoId != null) url += 'evento_id=$eventoId&';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getFiltrosBase() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/filtros/base'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>?> getEventosDinamicos({
    int? periodoId,
    int? categoriaId,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      String url = '$baseUrl/dashboard/filtros/eventos?';
      if (periodoId != null) url += 'periodo_id=$periodoId&';
      if (categoriaId != null) url += 'categoria_id=$categoriaId&';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } catch (e) {
      return null;
    }
  }
}
