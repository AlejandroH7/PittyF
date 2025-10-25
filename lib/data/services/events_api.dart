import 'package:dio/dio.dart';
import 'package:pittyf/data/models/event_model.dart';
import 'package:pittyf/data/models/event_create_request_model.dart';
import 'package:pittyf/data/models/event_update_request_model.dart';
import 'package:pittyf/core/constants.dart';

class EventsApi {
  final Dio _dio;

  EventsApi({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<EventModel>> getAllEvents() async {
    try {
      final response = await _dio.get('$baseUrl/api/eventos');
      if (response.statusCode == 200) {
        // The backend returns a Page object, the content is in the 'content' field
        final List<dynamic> eventJsonList = response.data['content'];
        return eventJsonList.map((json) => EventModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load events: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<EventModel> createEvent(EventCreateRequestModel event) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/eventos',
        data: event.toJson(),
      );
      if (response.statusCode == 201) {
        return EventModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create event: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to create event: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<EventModel> getEventById(int id) async {
    try {
      final response = await _dio.get('$baseUrl/api/eventos/$id');
      if (response.statusCode == 200) {
        return EventModel.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to load event with ID $id: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Failed to load event with ID $id: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<EventModel> updateEvent(int id, EventUpdateRequestModel event) async {
    try {
      final response = await _dio.put(
        '$baseUrl/api/eventos/$id',
        data: event.toJson(),
      );
      if (response.statusCode == 200) {
        return EventModel.fromJson(response.data);
      } else {
        throw Exception('Failed to update event: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to update event: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> deleteEvent(int id) async {
    try {
      final response = await _dio.delete('$baseUrl/api/eventos/$id');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete event: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to delete event: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
