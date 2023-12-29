import 'package:concept_designer/common/globals.dart';
import 'package:flutter/material.dart';

import 'misc.dart';

class AttFieldControllers {
  final TextEditingController typeController;
  final TextEditingController nameController;

  AttFieldControllers({
    TextEditingController? typeController,
    TextEditingController? nameController,
  })  : typeController = typeController ?? TextEditingController(),
        nameController = nameController ?? TextEditingController();

  void dispose() {
    typeController.dispose();
    nameController.dispose();
  }
}

class AttributesFields extends StatefulWidget {
  const AttributesFields({
    super.key,
    required this.controllers,
    this.title = 'Attributes',
  });

  final String title;
  final List<AttFieldControllers> controllers;

  @override
  State<AttributesFields> createState() => _AttributesFieldsState();
}

class _AttributesFieldsState extends State<AttributesFields> {
  void _addField() {
    setState(() {
      widget.controllers.add(AttFieldControllers());
    });
  }

  void _deleteField(int index) {
    setState(() {
      widget.controllers.removeAt(index);
    });
  }

  List<Widget> _buildFields() {
    return List.generate(
      widget.controllers.length,
      (index) => Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Row(
          key: ValueKey(widget.controllers[index]),
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.controllers[index].typeController,
                decoration: borderDecoration('Type'),
                validator: nonEmptyStringValidator,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: TextFormField(
                controller: widget.controllers[index].nameController,
                decoration: borderDecoration('Name'),
                validator: nonEmptyStringValidator,
              ),
            ),
            DeleteIcon(onDelete: () => _deleteField(index)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(widget.title),
            const Expanded(child: HDivider()),
            IconButton(
              onPressed: _addField,
              color: Globals.myTheme.colorScheme.primary,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        ..._buildFields(),
      ],
    );
  }
}
