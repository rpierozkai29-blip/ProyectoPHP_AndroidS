import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Reemplaza los X con tu IP local real
  static const String baseUrl = 'http://10.13.210.182:8000/api';

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

  Future<Map<String, dynamic>?> getResumen() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/dashboard/resumen'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error de red: $e');
      return null;
    }
  }
}
