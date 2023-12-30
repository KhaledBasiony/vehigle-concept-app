// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'method.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Method _$MethodFromJson(Map<String, dynamic> json) => Method(
      returnType: Globals.typeFromJson(json['returnType'] as String),
      name: json['name'] as String,
      params: Globals.attsFromJson(json['params'] as List),
    );

Map<String, dynamic> _$MethodToJson(Method instance) => <String, dynamic>{
      'returnType': Globals.typeToJson(instance.returnType),
      'params': Globals.attsToJson(instance.params),
      'name': instance.name,
    };
