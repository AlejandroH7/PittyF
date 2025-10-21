// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dessert_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DessertRequestModel _$DessertRequestModelFromJson(Map<String, dynamic> json) =>
    DessertRequestModel(
      nombre: json['nombre'] as String,
      precio: (json['precio'] as num).toDouble(),
      porciones: (json['porciones'] as num).toInt(),
      activo: json['activo'] as bool,
    );

Map<String, dynamic> _$DessertRequestModelToJson(
  DessertRequestModel instance,
) => <String, dynamic>{
  'nombre': instance.nombre,
  'precio': instance.precio,
  'porciones': instance.porciones,
  'activo': instance.activo,
};
