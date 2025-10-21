import 'package:json_annotation/json_annotation.dart';

part 'pedido_item_model.g.dart';

@JsonSerializable()
class PedidoItemModel {
  final int postreId;
  final String postreNombre;
  final int cantidad;
  final double precioUnitario; // BigDecimal in Java maps to double in Dart
  final double subtotal;     // BigDecimal in Java maps to double in Dart
  final Map<String, dynamic>? personalizaciones; // JsonNode in Java maps to Map<String, dynamic>

  PedidoItemModel({
    required this.postreId,
    required this.postreNombre,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
    this.personalizaciones,
  });

  factory PedidoItemModel.fromJson(Map<String, dynamic> json) => _$PedidoItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$PedidoItemModelToJson(this);
}