// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventModel _$EventModelFromJson(Map<String, dynamic> json) => EventModel(
  id: (json['id'] as num).toInt(),
  titulo: json['titulo'] as String,
  nombre: json['nombre'] as String,
  fecha: json['fecha'] as String,
  descripcion: json['descripcion'] as String?,
  ubicacion: json['ubicacion'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$EventModelToJson(EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titulo': instance.titulo,
      'nombre': instance.nombre,
      'fecha': instance.fecha,
      'descripcion': instance.descripcion,
      'ubicacion': instance.ubicacion,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
