import 'package:json_annotation/json_annotation.dart';

part 'client_model.g.dart';

@JsonSerializable()
class ClientModel {
  final int id;
  final String nombre;
  final String? telefono;
  final String? notas;
  final String? createdAt; // Made nullable
  final String? createdBy; // Made nullable
  final String? updatedAt; // Made nullable
  final String? updatedBy; // Made nullable

  ClientModel({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.notas,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) => _$ClientModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClientModelToJson(this);
}