// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedido_completo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PedidoCompletoModel _$PedidoCompletoModelFromJson(Map<String, dynamic> json) =>
    PedidoCompletoModel(
      id: (json['id'] as num).toInt(),
      clienteId: (json['clienteId'] as num).toInt(),
      clienteNombre: json['clienteNombre'] as String,
      postreId: (json['postreId'] as num).toInt(),
      postreNombre: json['postreNombre'] as String,
      nota: json['nota'] as String?,
      cantidad: (json['cantidad'] as num).toInt(),
      total: (json['total'] as num).toDouble(),
      fechaEntrega: json['fechaEntrega'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$PedidoCompletoModelToJson(
  PedidoCompletoModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'clienteId': instance.clienteId,
  'clienteNombre': instance.clienteNombre,
  'postreId': instance.postreId,
  'postreNombre': instance.postreNombre,
  'nota': instance.nota,
  'cantidad': instance.cantidad,
  'total': instance.total,
  'fechaEntrega': instance.fechaEntrega,
  'createdAt': instance.createdAt,
};
