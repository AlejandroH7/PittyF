import 'package:json_annotation/json_annotation.dart';

part 'pedido_completo_update_request_model.g.dart';

@JsonSerializable()
class PedidoCompletoUpdateRequestModel {
  final int clienteId;
  final int postreId;
  final String? nota;
  final int cantidad;
  final double total;
  final String fechaEntrega; // ISO 8601 format

  PedidoCompletoUpdateRequestModel({
    required this.clienteId,
    required this.postreId,
    this.nota,
    required this.cantidad,
    required this.total,
    required this.fechaEntrega,
  });

  factory PedidoCompletoUpdateRequestModel.fromJson(
    Map<String, dynamic> json,
  ) => _$PedidoCompletoUpdateRequestModelFromJson(json);
  Map<String, dynamic> toJson() =>
      _$PedidoCompletoUpdateRequestModelToJson(this);
}
