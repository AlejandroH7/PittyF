import 'package:dio/dio.dart';
import 'package:pittyf/data/models/pedido_completo_model.dart';
import 'package:pittyf/data/models/pedido_completo_create_request_model.dart';
import 'package:pittyf/data/models/pedido_completo_update_request_model.dart';
import 'package:pittyf/core/constants.dart';

class PedidoCompletoApi {
  final Dio _dio;

  PedidoCompletoApi({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<PedidoCompletoModel>> getAllPedidosCompletos() async {
    try {
      final response = await _dio.get('$baseUrl/api/pedido-completos');
      if (response.statusCode == 200) {
        // The backend returns a Page object, the content is in the 'content' field
        final List<dynamic> pedidoJsonList = response.data['content'];
        return pedidoJsonList
            .map((json) => PedidoCompletoModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
          'Failed to load pedidos completos: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to load pedidos completos: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<PedidoCompletoModel> createPedidoCompleto(
    PedidoCompletoCreateRequestModel pedido,
  ) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/pedido-completos',
        data: pedido.toJson(),
      );
      if (response.statusCode == 201) {
        return PedidoCompletoModel.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to create pedido completo: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to create pedido completo: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<PedidoCompletoModel> getPedidoCompletoById(int id) async {
    try {
      final response = await _dio.get('$baseUrl/api/pedido-completos/$id');
      if (response.statusCode == 200) {
        return PedidoCompletoModel.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to load pedido completo with ID $id: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        'Failed to load pedido completo with ID $id: ${e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<PedidoCompletoModel> updatePedidoCompleto(
    int id,
    PedidoCompletoUpdateRequestModel pedido,
  ) async {
    try {
      final response = await _dio.put(
        '$baseUrl/api/pedido-completos/$id',
        data: pedido.toJson(),
      );
      if (response.statusCode == 200) {
        return PedidoCompletoModel.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to update pedido completo: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to update pedido completo: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> deletePedidoCompleto(int id) async {
    try {
      final response = await _dio.delete('$baseUrl/api/pedido-completos/$id');
      if (response.statusCode != 204) {
        throw Exception(
          'Failed to delete pedido completo: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to delete pedido completo: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Aquí se podrían agregar los otros métodos del CRUD (create, update, delete) si fueran necesarios en el futuro.
}
