// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Block _$BlockFromJson(Map<String, dynamic> json) => Block(
      name: json['name'] as String? ?? '<NAME>',
      attributes: json['attributes'] == null
          ? const []
          : Globals.attsFromJson(json['attributes'] as List),
      methods: json['methods'] == null
          ? const []
          : Globals.methodsFromJson(json['methods'] as List),
      pseudoCode: json['pseudoCode'] as String? ?? '<CODE>',
    );

Map<String, dynamic> _$BlockToJson(Block instance) => <String, dynamic>{
      'name': instance.name,
      'attributes': Globals.attsToJson(instance.attributes),
      'methods': Globals.methodsToJson(instance.methods),
      'pseudoCode': instance.pseudoCode,
    };
