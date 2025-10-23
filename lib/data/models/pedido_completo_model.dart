
import 'package:json_annotation/json_annotation.dart';

part 'pedido_completo_model.g.dart';

@JsonSerializable()
class PedidoCompletoModel {
  final int id;
  final int clienteId;
  final String clienteNombre;
  final int postreId;
  final String postreNombre;
  final String? nota;
  final int cantidad;
  final double total;
  final String fechaEntrega;
  final String createdAt;
  final String? updatedAt;

  PedidoCompletoModel({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.postreId,
    required this.postreNombre,
    this.nota,
    required this.cantidad,
    required this.total,
    required this.fechaEntrega,
    required this.createdAt,
    this.updatedAt,
  });

  factory PedidoCompletoModel.fromJson(Map<String, dynamic> json) => _$PedidoCompletoModelFromJson(json);
  Map<String, dynamic> toJson() => _$PedidoCompletoModelToJson(this);
}
