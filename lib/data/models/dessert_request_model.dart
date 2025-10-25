import 'package:json_annotation/json_annotation.dart';

part 'dessert_request_model.g.dart';

@JsonSerializable()
class DessertRequestModel {
  final String nombre;
  final double precio; // BigDecimal in Java maps to double in Dart
  final int porciones;
  final bool activo;

  DessertRequestModel({
    required this.nombre,
    required this.precio,
    required this.porciones,
    required this.activo,
  });

  factory DessertRequestModel.fromJson(Map<String, dynamic> json) =>
      _$DessertRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$DessertRequestModelToJson(this);
}
