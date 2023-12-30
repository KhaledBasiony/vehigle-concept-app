// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockLink _$BlockLinkFromJson(Map<String, dynamic> json) => BlockLink(
      from: Globals.blockFromJson(json['from'] as String),
      to: Globals.blockFromJson(json['to'] as String),
      callerMethod:
          BlockLink._innerMethodFromJson(json['callerMethod'] as String?),
      handlerMethod:
          BlockLink._innerMethodFromJson(json['handlerMethod'] as String?),
      type: $enumDecodeNullable(_$LinkTypeEnumMap, json['type']) ??
          LinkType.oneWay,
    );

Map<String, dynamic> _$BlockLinkToJson(BlockLink instance) => <String, dynamic>{
      'from': Globals.blockToJson(instance.from),
      'to': Globals.blockToJson(instance.to),
      'callerMethod': BlockLink._innerMethodToJson(instance.callerMethod),
      'handlerMethod': BlockLink._innerMethodToJson(instance.handlerMethod),
      'type': _$LinkTypeEnumMap[instance.type]!,
    };

const _$LinkTypeEnumMap = {
  LinkType.oneWay: 'oneWay',
  LinkType.twoWay: 'twoWay',
  LinkType.stream: 'stream',
};
