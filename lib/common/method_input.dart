import 'package:concept_designer/common/attr_input.dart';
import 'package:concept_designer/common/globals.dart';
import 'package:flutter/material.dart';

import 'misc.dart';

class MethodFieldControllers {
  final TextEditingController returnTypeController;
  final TextEditingController nameController;
  final List<AttFieldControllers> parametersControllers;

  MethodFieldControllers({
    TextEditingController? returnTypeController,
    TextEditingController? nameController,
    List<AttFieldControllers>? parametersControllers,
  })  : returnTypeController = returnTypeController ?? TextEditingController(),
        nameController = nameController ?? TextEditingController(),
        parametersControllers = parametersControllers ?? [];

  void dispose() {
    returnTypeController.dispose();
    nameController.dispose();
    for (final element in parametersControllers) {
      element.dispose();
    }
  }
}

class MethodsFields extends StatefulWidget {
  const MethodsFields({
    super.key,
    required this.controllers,
  });

  final List<MethodFieldControllers> controllers;

  @override
  State<MethodsFields> createState() => _MethodsFieldsState();
}

class _MethodsFieldsState extends State<MethodsFields> {
  void _addField() {
    setState(() {
      widget.controllers.add(MethodFieldControllers());
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
      (index) => Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                key: ValueKey(widget.controllers[index]),
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: widget.controllers[index].returnTypeController,
                      decoration: borderDecoration('Return Type'),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: AttributesFields(
                  title: 'Parameters',
                  controllers: widget.controllers[index].parametersControllers,
                ),
              ),
            ],
          ),
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
            const Text('Methods'),
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
