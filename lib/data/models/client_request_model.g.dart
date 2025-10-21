// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientRequestModel _$ClientRequestModelFromJson(Map<String, dynamic> json) =>
    ClientRequestModel(
      nombre: json['nombre'] as String,
      telefono: json['telefono'] as String?,
      notas: json['notas'] as String?,
    );

Map<String, dynamic> _$ClientRequestModelToJson(ClientRequestModel instance) =>
    <String, dynamic>{
      'nombre': instance.nombre,
      'telefono': instance.telefono,
      'notas': instance.notas,
    };
