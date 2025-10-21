// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientModel _$ClientModelFromJson(Map<String, dynamic> json) => ClientModel(
  id: (json['id'] as num).toInt(),
  nombre: json['nombre'] as String,
  telefono: json['telefono'] as String?,
  notas: json['notas'] as String?,
  createdAt: json['createdAt'] as String?,
  createdBy: json['createdBy'] as String?,
  updatedAt: json['updatedAt'] as String?,
  updatedBy: json['updatedBy'] as String?,
);

Map<String, dynamic> _$ClientModelToJson(ClientModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nombre': instance.nombre,
      'telefono': instance.telefono,
      'notas': instance.notas,
      'createdAt': instance.createdAt,
      'createdBy': instance.createdBy,
      'updatedAt': instance.updatedAt,
      'updatedBy': instance.updatedBy,
    };
