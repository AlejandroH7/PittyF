import 'package:json_annotation/json_annotation.dart';

part 'client_request_model.g.dart';

@JsonSerializable()
class ClientRequestModel {
  final String nombre;
  final String? telefono; // Nullable as per backend (no @NotBlank)
  final String? notas; // Nullable as per backend (no @NotBlank)

  ClientRequestModel({required this.nombre, this.telefono, this.notas});

  factory ClientRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ClientRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClientRequestModelToJson(this);
}
