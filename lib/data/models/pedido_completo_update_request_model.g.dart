// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedido_completo_update_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PedidoCompletoUpdateRequestModel _$PedidoCompletoUpdateRequestModelFromJson(
  Map<String, dynamic> json,
) => PedidoCompletoUpdateRequestModel(
  clienteId: (json['clienteId'] as num).toInt(),
  postreId: (json['postreId'] as num).toInt(),
  nota: json['nota'] as String?,
  cantidad: (json['cantidad'] as num).toInt(),
  total: (json['total'] as num).toDouble(),
  fechaEntrega: json['fechaEntrega'] as String,
);

Map<String, dynamic> _$PedidoCompletoUpdateRequestModelToJson(
  PedidoCompletoUpdateRequestModel instance,
) => <String, dynamic>{
  'clienteId': instance.clienteId,
  'postreId': instance.postreId,
  'nota': instance.nota,
  'cantidad': instance.cantidad,
  'total': instance.total,
  'fechaEntrega': instance.fechaEntrega,
};
