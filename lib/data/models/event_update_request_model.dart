import 'package:json_annotation/json_annotation.dart';

part 'event_update_request_model.g.dart';

@JsonSerializable()
class EventUpdateRequestModel {
  final String nombre;
  final String titulo;
  final String fecha; // ISO 8601 format
  final String? descripcion;
  final String? ubicacion;

  EventUpdateRequestModel({
    required this.nombre,
    required this.titulo,
    required this.fecha,
    this.descripcion,
    this.ubicacion,
  });

  factory EventUpdateRequestModel.fromJson(Map<String, dynamic> json) => _$EventUpdateRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$EventUpdateRequestModelToJson(this);
}
