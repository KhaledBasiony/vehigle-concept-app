import 'package:concept_designer/views/blocks/attribute.dart';
import 'package:concept_designer/views/types/type.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'method.g.dart';

@JsonSerializable()
class Method {
  const Method({
    required this.returnType,
    required this.name,
    required this.params,
  });
  final DataStruct returnType;
  final List<Attribute> params;
  final String name;

  factory Method.fromJson(Map<String, dynamic> json) => _$MethodFromJson(json);
  Map<String, dynamic> toJson() => _$MethodToJson(this);
}

class MethodView extends StatelessWidget {
  const MethodView({super.key, required this.method});

  final Method method;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      mouseCursor: MouseCursor.defer,
      title: Text(method.name),
      trailing: Text(
        method.returnType.name,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      subtitle: Text(
        '(${method.params.map((param) => param.type).join(', ')})',
        textAlign: TextAlign.start,
      ),
    );
  }
}
