import 'package:dio/dio.dart';
import 'package:pittyf/data/models/dessert_model.dart';
import 'package:pittyf/core/constants.dart'; // Assuming constants.dart exists for baseUrl

import 'package:pittyf/data/models/dessert_request_model.dart';

class DessertsApi {
  final Dio _dio;

  DessertsApi({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<DessertModel>> getAllDesserts() async {
    try {
      final response = await _dio.get('$baseUrl/api/postres');
      if (response.statusCode == 200) {
        final List<dynamic> dessertJsonList = response.data;
        return dessertJsonList.map((json) => DessertModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load desserts: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load desserts: ${e.message}');
    }
  }

  Future<DessertModel> createDessert(DessertRequestModel dessert) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/postres',
        data: dessert.toJson(),
      );
      if (response.statusCode == 201) { // Assuming 201 Created for successful creation
        return DessertModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create dessert: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to create dessert: ${e.message}');
    }
  }

  Future<DessertModel> getDessertById(int id) async {
    try {
      final response = await _dio.get('$baseUrl/api/postres/$id');
      if (response.statusCode == 200) {
        return DessertModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load dessert with ID $id: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load dessert with ID $id: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> deleteDessert(int id) async {
    try {
      final response = await _dio.delete('$baseUrl/api/postres/$id');
      if (response.statusCode != 204) { // Assuming 204 No Content for successful deletion
        throw Exception('Failed to delete dessert with ID $id: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to delete dessert with ID $id: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<DessertModel> updateDessert(int id, DessertRequestModel dessert) async {
    try {
      final response = await _dio.put(
        '$baseUrl/api/postres/$id',
        data: dessert.toJson(),
      );
      if (response.statusCode == 200) { // Assuming 200 OK for successful update
        return DessertModel.fromJson(response.data);
      } else {
        throw Exception('Failed to update dessert with ID $id: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to update dessert with ID $id: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}