// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagram.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComponentViewData _$ComponentViewDataFromJson(Map<String, dynamic> json) =>
    ComponentViewData(
      block: Block.fromJson(json['block'] as Map<String, dynamic>),
    )..isHighlightVisible = json['isHighlightVisible'] as bool;

Map<String, dynamic> _$ComponentViewDataToJson(ComponentViewData instance) =>
    <String, dynamic>{
      'isHighlightVisible': instance.isHighlightVisible,
      'block': instance.block,
    };
