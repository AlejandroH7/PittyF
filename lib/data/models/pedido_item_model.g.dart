// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedido_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PedidoItemModel _$PedidoItemModelFromJson(Map<String, dynamic> json) =>
    PedidoItemModel(
      postreId: (json['postreId'] as num).toInt(),
      postreNombre: json['postreNombre'] as String,
      cantidad: (json['cantidad'] as num).toInt(),
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      personalizaciones: json['personalizaciones'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PedidoItemModelToJson(PedidoItemModel instance) =>
    <String, dynamic>{
      'postreId': instance.postreId,
      'postreNombre': instance.postreNombre,
      'cantidad': instance.cantidad,
      'precioUnitario': instance.precioUnitario,
      'subtotal': instance.subtotal,
      'personalizaciones': instance.personalizaciones,
    };
