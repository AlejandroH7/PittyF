import 'package:json_annotation/json_annotation.dart';

part 'dessert_model.g.dart';

@JsonSerializable()
class DessertModel {
  final int id;
  final String nombre;
  final double precio; // BigDecimal in Java maps to double in Dart
  final int porciones;
  final bool activo;
  final String? createdAt; // OffsetDateTime in Java maps to String in JSON
  final String? updatedAt; // OffsetDateTime in Java maps to String in JSON

  DessertModel({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.porciones,
    required this.activo,
    this.createdAt,
    this.updatedAt,
  });

  factory DessertModel.fromJson(Map<String, dynamic> json) => _$DessertModelFromJson(json);
  Map<String, dynamic> toJson() => _$DessertModelToJson(this);
}