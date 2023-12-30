// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataStruct _$DataStructFromJson(Map<String, dynamic> json) => DataStruct(
      name: json['name'] as String,
      fields: json['fields'] == null
          ? const []
          : Globals.attsFromJson(json['fields'] as List),
    );

Map<String, dynamic> _$DataStructToJson(DataStruct instance) =>
    <String, dynamic>{
      'name': instance.name,
      'fields': Globals.attsToJson(instance.fields),
    };
