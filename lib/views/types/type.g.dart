// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataStruct _$DataStructFromJson(Map<String, dynamic> json) => DataStruct(
      name: json['name'] as String,
      fields: (json['fields'] as List<dynamic>?)
              ?.map((e) => Attribute.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$DataStructToJson(DataStruct instance) =>
    <String, dynamic>{
      'name': instance.name,
      'fields': instance.fields,
    };
