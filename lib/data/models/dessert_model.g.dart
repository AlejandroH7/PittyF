// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dessert_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DessertModel _$DessertModelFromJson(Map<String, dynamic> json) => DessertModel(
  id: (json['id'] as num).toInt(),
  nombre: json['nombre'] as String,
  precio: (json['precio'] as num).toDouble(),
  porciones: (json['porciones'] as num).toInt(),
  activo: json['activo'] as bool,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$DessertModelToJson(DessertModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'precio': instance.precio,
      'porciones': instance.porciones,
      'activo': instance.activo,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
