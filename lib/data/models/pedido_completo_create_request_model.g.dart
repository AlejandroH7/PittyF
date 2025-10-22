// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedido_completo_create_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PedidoCompletoCreateRequestModel _$PedidoCompletoCreateRequestModelFromJson(
  Map<String, dynamic> json,
) => PedidoCompletoCreateRequestModel(
  clienteId: (json['clienteId'] as num).toInt(),
  postreId: (json['postreId'] as num).toInt(),
  nota: json['nota'] as String?,
  cantidad: (json['cantidad'] as num).toInt(),
  total: (json['total'] as num).toDouble(),
  fechaEntrega: json['fechaEntrega'] as String,
);

Map<String, dynamic> _$PedidoCompletoCreateRequestModelToJson(
  PedidoCompletoCreateRequestModel instance,
) => <String, dynamic>{
  'clienteId': instance.clienteId,
  'postreId': instance.postreId,
  'nota': instance.nota,
  'cantidad': instance.cantidad,
  'total': instance.total,
  'fechaEntrega': instance.fechaEntrega,
};
