import 'package:json_annotation/json_annotation.dart';
import 'package:pittyf/data/models/pedido_item_model.dart';

part 'pedido_model.g.dart';

@JsonSerializable()
class PedidoModel {
  final int id;
  final int clienteId;
  final String clienteNombre;
  final String fechaEntrega; // OffsetDateTime in Java maps to String in JSON
  final String estado;
  final String? notas; // Can be null
  final double total; // BigDecimal in Java maps to double in Dart
  final List<PedidoItemModel> items;

  PedidoModel({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.fechaEntrega,
    required this.estado,
    this.notas,
    required this.total,
    required this.items,
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json) => _$PedidoModelFromJson(json);
  Map<String, dynamic> toJson() => _$PedidoModelToJson(this);
}