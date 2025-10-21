// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedido_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PedidoModel _$PedidoModelFromJson(Map<String, dynamic> json) => PedidoModel(
  id: (json['id'] as num).toInt(),
  clienteId: (json['clienteId'] as num).toInt(),
  clienteNombre: json['clienteNombre'] as String,
  fechaEntrega: json['fechaEntrega'] as String,
  estado: json['estado'] as String,
  notas: json['notas'] as String?,
  total: (json['total'] as num).toDouble(),
  items:
      (json['items'] as List<dynamic>)
          .map((e) => PedidoItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$PedidoModelToJson(PedidoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'clienteId': instance.clienteId,
      'clienteNombre': instance.clienteNombre,
      'fechaEntrega': instance.fechaEntrega,
      'estado': instance.estado,
      'notas': instance.notas,
      'total': instance.total,
      'items': instance.items,
    };
