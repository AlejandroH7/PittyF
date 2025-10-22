import 'package:json_annotation/json_annotation.dart';

part 'event_create_request_model.g.dart';

@JsonSerializable()
class EventCreateRequestModel {
  final String nombre;
  final String titulo;
  final String fecha; // ISO 8601 format
  final String? descripcion;
  final String? ubicacion;

  EventCreateRequestModel({
    required this.nombre,
    required this.titulo,
    required this.fecha,
    this.descripcion,
    this.ubicacion,
  });

  factory EventCreateRequestModel.fromJson(Map<String, dynamic> json) => _$EventCreateRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$EventCreateRequestModelToJson(this);
}
