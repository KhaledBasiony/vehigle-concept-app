import 'package:concept_designer/common/globals.dart';
import 'package:concept_designer/views/blocks/block.dart';
import 'package:concept_designer/views/types/type.dart';
import 'package:diagram_editor/diagram_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HDivider extends StatelessWidget {
  const HDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(indent: 10, endIndent: 20);
  }
}

class MaxWidthBox extends StatelessWidget {
  const MaxWidthBox({
    super.key,
    this.child = const Placeholder(),
    this.maxWidth = 250,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    );
  }
}

class LeftText extends StatelessWidget {
  const LeftText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(text),
    );
  }
}

InputDecoration borderDecoration(String text) => InputDecoration(
      labelText: text,
      border: const OutlineInputBorder(),
      focusColor: Globals.myTheme.colorScheme.primary,
      hoverColor: Globals.myTheme.colorScheme.primary,
    );

String? nonEmptyStringValidator(String? text) {
  if (text?.isEmpty ?? true) {
    return 'this cannot be empty';
  }

  if (text?.contains(RegExp(r'\s')) ?? true) {
    return 'cannot contain spaces';
  }
  return null;
}

class DeleteIcon extends StatelessWidget {
  const DeleteIcon({
    super.key,
    required this.onDelete,
  });

  final void Function() onDelete;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onDelete,
      color: Globals.myTheme.colorScheme.error,
      icon: const Icon(Icons.delete_rounded),
    );
  }
}

class Selections {
  const Selections({
    this.block,
    this.type,
    this.componentId,
    this.link,
  });

  final Block? block;
  final DataStruct? type;
  final String? componentId;
  final LinkData? link;
}

class SelectionsNotifier extends StateNotifier<Selections> {
  SelectionsNotifier() : super(const Selections());

  void updateBlock(Block? block) {
    state = Selections(
      block: block,
      type: state.type,
      componentId: state.componentId,
      link: state.link,
    );
  }

  void updateType(DataStruct? type) {
    state = Selections(
      block: state.block,
      type: type,
      componentId: state.componentId,
      link: state.link,
    );
  }

  void updateComponentId(String? componentId) {
    state = Selections(
      block: state.block,
      type: state.type,
      componentId: componentId,
      link: state.link,
    );
  }

  void updateLink(LinkData? link) {
    state = Selections(
      block: state.block,
      type: state.type,
      componentId: state.componentId,
      link: link,
    );
  }
}

Color complementColor(Color color, {int alpha = 255}) => Color.fromARGB(
      alpha,
      255 - color.red,
      255 - color.green,
      255 - color.blue,
    );
