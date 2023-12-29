// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockLink _$BlockLinkFromJson(Map<String, dynamic> json) => BlockLink(
      from: Block.fromJson(json['from'] as Map<String, dynamic>),
      to: Block.fromJson(json['to'] as Map<String, dynamic>),
      callerMethod: json['callerMethod'] == null
          ? null
          : Method.fromJson(json['callerMethod'] as Map<String, dynamic>),
      handlerMethod: json['handlerMethod'] == null
          ? null
          : Method.fromJson(json['handlerMethod'] as Map<String, dynamic>),
      type: $enumDecodeNullable(_$LinkTypeEnumMap, json['type']) ??
          LinkType.oneWay,
    );

Map<String, dynamic> _$BlockLinkToJson(BlockLink instance) => <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'callerMethod': instance.callerMethod,
      'handlerMethod': instance.handlerMethod,
      'type': _$LinkTypeEnumMap[instance.type]!,
    };

const _$LinkTypeEnumMap = {
  LinkType.oneWay: 'oneWay',
  LinkType.twoWay: 'twoWay',
  LinkType.stream: 'stream',
};
