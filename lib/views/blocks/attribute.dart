import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attribute.g.dart';

@JsonSerializable()
class Attribute {
  const Attribute({
    required this.type,
    required this.name,
  });

  final String type;
  final String name;

  factory Attribute.fromJson(Map<String, dynamic> json) => _$AttributeFromJson(json);
  Map<String, dynamic> toJson() => _$AttributeToJson(this);
}

class AttributeView extends StatelessWidget {
  const AttributeView({super.key, required this.attribute});

  final Attribute attribute;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      mouseCursor: MouseCursor.defer,
      title: Text(attribute.name),
      trailing: Text(
        attribute.type,
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
