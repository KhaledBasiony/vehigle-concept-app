// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diagram.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComponentViewData _$ComponentViewDataFromJson(Map<String, dynamic> json) =>
    ComponentViewData(
      block: Globals.blockFromJson(json['block'] as String),
    )..isHighlightVisible = json['isHighlightVisible'] as bool;

Map<String, dynamic> _$ComponentViewDataToJson(ComponentViewData instance) =>
    <String, dynamic>{
      'isHighlightVisible': instance.isHighlightVisible,
      'block': Globals.blockToJson(instance.block),
    };
