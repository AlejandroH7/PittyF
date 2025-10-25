import 'package:dio/dio.dart';
import 'package:pittyf/data/models/client_model.dart';
import 'package:pittyf/core/constants.dart'; // Assuming constants.dart exists for baseUrl

import 'package:pittyf/data/models/client_request_model.dart';

class ClientsApi {
  final Dio _dio;

  ClientsApi({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<ClientModel>> getAllClients() async {
    try {
      final response = await _dio.get('$baseUrl/api/clientes');
      if (response.statusCode == 200) {
        final List<dynamic> clientJsonList = response.data;
        return clientJsonList
            .map((json) => ClientModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load clients: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load clients: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<ClientModel> createClient(ClientRequestModel client) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/clientes',
        data: client.toJson(),
      );
      if (response.statusCode == 201) {
        // Assuming 201 Created for successful creation
        return ClientModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create client: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to create client: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<ClientModel> getClientById(int id) async {
    try {
      final response = await _dio.get('$baseUrl/api/clientes/$id');
      if (response.statusCode == 200) {
        return ClientModel.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to load client with ID $id: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to load client with ID $id: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<ClientModel> updateClient(int id, ClientRequestModel client) async {
    try {
      final response = await _dio.put(
        '$baseUrl/api/clientes/$id',
        data: client.toJson(),
      );
      if (response.statusCode == 200) {
        // Assuming 200 OK for successful update
        return ClientModel.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to update client with ID $id: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to update client with ID $id: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> deleteClient(int id) async {
    try {
      final response = await _dio.delete('$baseUrl/api/clientes/$id');
      if (response.statusCode != 204) {
        // Assuming 204 No Content for successful deletion
        throw Exception(
          'Failed to delete client with ID $id: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to delete client with ID $id: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
