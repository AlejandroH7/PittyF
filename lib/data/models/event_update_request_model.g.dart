// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_update_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventUpdateRequestModel _$EventUpdateRequestModelFromJson(
  Map<String, dynamic> json,
) => EventUpdateRequestModel(
  nombre: json['nombre'] as String,
  titulo: json['titulo'] as String,
  fecha: json['fecha'] as String,
  descripcion: json['descripcion'] as String?,
  ubicacion: json['ubicacion'] as String?,
);

Map<String, dynamic> _$EventUpdateRequestModelToJson(
  EventUpdateRequestModel instance,
) => <String, dynamic>{
  'nombre': instance.nombre,
  'titulo': instance.titulo,
  'fecha': instance.fecha,
  'descripcion': instance.descripcion,
  'ubicacion': instance.ubicacion,
};
