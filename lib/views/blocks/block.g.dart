// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Block _$BlockFromJson(Map<String, dynamic> json) => Block(
      name: json['name'] as String? ?? '<NAME>',
      attributes: (json['attributes'] as List<dynamic>?)
              ?.map((e) => Attribute.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      methods: (json['methods'] as List<dynamic>?)
              ?.map((e) => Method.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pseudoCode: json['pseudoCode'] as String? ?? '<CODE>',
    );

Map<String, dynamic> _$BlockToJson(Block instance) => <String, dynamic>{
      'name': instance.name,
      'attributes': instance.attributes,
      'methods': instance.methods,
      'pseudoCode': instance.pseudoCode,
    };
