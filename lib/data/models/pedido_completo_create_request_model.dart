import 'package:json_annotation/json_annotation.dart';

part 'pedido_completo_create_request_model.g.dart';

@JsonSerializable()
class PedidoCompletoCreateRequestModel {
  final int clienteId;
  final int postreId;
  final String? nota;
  final int cantidad;
  final double total;
  final String fechaEntrega; // ISO 8601 format

  PedidoCompletoCreateRequestModel({
    required this.clienteId,
    required this.postreId,
    this.nota,
    required this.cantidad,
    required this.total,
    required this.fechaEntrega,
  });

  factory PedidoCompletoCreateRequestModel.fromJson(
    Map<String, dynamic> json,
  ) => _$PedidoCompletoCreateRequestModelFromJson(json);
  Map<String, dynamic> toJson() =>
      _$PedidoCompletoCreateRequestModelToJson(this);
}
