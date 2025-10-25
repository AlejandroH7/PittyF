import 'package:json_annotation/json_annotation.dart';

part 'event_model.g.dart';

@JsonSerializable()
class EventModel {
  final int id;
  final String titulo;
  final String nombre;
  final String fecha;
  final String? descripcion;
  final String? ubicacion;
  final String? createdAt;
  final String? updatedAt;

  EventModel({
    required this.id,
    required this.titulo,
    required this.nombre,
    required this.fecha,
    this.descripcion,
    this.ubicacion,
    this.createdAt,
    this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);
  Map<String, dynamic> toJson() => _$EventModelToJson(this);
}
