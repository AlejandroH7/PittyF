import 'package:dio/dio.dart';
import 'package:pittyf/data/models/pedido_model.dart';
import 'package:pittyf/core/constants.dart'; // Assuming constants.dart exists for baseUrl

class PedidosApi {
  final Dio _dio;

  PedidosApi({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<PedidoModel>> getAllPedidos() async {
    try {
      final response = await _dio.get('$baseUrl/api/pedidos');
      if (response.statusCode == 200) {
        final List<dynamic> pedidoJsonList = response.data;
        return pedidoJsonList.map((json) => PedidoModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load pedidos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load pedidos: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<PedidoModel> getPedidoById(int id) async {
    try {
      final response = await _dio.get('$baseUrl/api/pedidos/$id');
      if (response.statusCode == 200) {
        return PedidoModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load pedido with ID $id: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load pedido with ID $id: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}