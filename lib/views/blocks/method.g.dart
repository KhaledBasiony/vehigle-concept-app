// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'method.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Method _$MethodFromJson(Map<String, dynamic> json) => Method(
      returnType:
          DataStruct.fromJson(json['returnType'] as Map<String, dynamic>),
      name: json['name'] as String,
      params: (json['params'] as List<dynamic>)
          .map((e) => Attribute.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MethodToJson(Method instance) => <String, dynamic>{
      'returnType': instance.returnType,
      'params': instance.params,
      'name': instance.name,
    };
