import 'package:concept_designer/common/attr_input.dart';
import 'package:concept_designer/common/globals.dart';
import 'package:concept_designer/common/method_input.dart';
import 'package:concept_designer/common/misc.dart';
import 'package:concept_designer/views/blocks/attribute.dart';
import 'package:concept_designer/views/base.dart';
import 'package:concept_designer/views/blocks/method.dart';
import 'package:concept_designer/views/types/type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';

part 'block.g.dart';

@JsonSerializable()
class Block {
  const Block({
    this.name = '<NAME>',
    this.attributes = const [],
    this.methods = const [],
    this.pseudoCode = '<CODE>',
  });

  final String name;

  @JsonKey(
    toJson: Globals.attsToJson,
    fromJson: Globals.attsFromJson,
  )
  final List<Attribute> attributes;

  @JsonKey(
    toJson: Globals.methodsToJson,
    fromJson: Globals.methodsFromJson,
  )
  final List<Method> methods;

  final String pseudoCode;

  factory Block.fromJson(Map<String, dynamic> json) => _$BlockFromJson(json);
  Map<String, dynamic> toJson() => _$BlockToJson(this);

  @override
  String toString() => name;
}

class BlockView extends StatelessWidget {
  const BlockView({
    super.key,
    required this.block,
    this.onDoubleTap,
    this.onTap,
    this.isSelected = false,
  });

  final Block block;
  final void Function()? onDoubleTap;
  final void Function()? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return BaseView(
      onDoubleTap: onDoubleTap,
      onTap: onTap,
      isSelected: isSelected,
      title: block.name,
      children: [
        const LeftText(text: 'Attributes'),
        for (final att in block.attributes) AttributeView(attribute: att),
        const HDivider(),
        const LeftText(text: 'Methods'),
        for (final method in block.methods) MethodView(method: method)
      ],
    );
  }
}

class BlockForm extends StatefulWidget {
  const BlockForm({
    super.key,
    this.block,
    required this.close,
  });

  final Block? block;
  final void Function() close;

  @override
  State<BlockForm> createState() => _BlockFormState();
}

class _BlockFormState extends State<BlockForm> {
  late final TextEditingController _nameController;
  late final List<AttFieldControllers> _attributesControllers;
  late final List<MethodFieldControllers> _methodsControllers;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.block?.name ?? '');

    _attributesControllers = List.generate(
      widget.block?.attributes.length ?? 1,
      (attIndex) => AttFieldControllers(
        typeController: TextEditingController(text: widget.block?.attributes[attIndex].type),
        nameController: TextEditingController(text: widget.block?.attributes[attIndex].name),
      ),
    );

    _methodsControllers = List.generate(
      widget.block?.methods.length ?? 1,
      (methIndex) {
        final method = widget.block?.methods[methIndex];
        return MethodFieldControllers(
          returnTypeController: TextEditingController(text: method?.returnType.name),
          nameController: TextEditingController(text: method?.name),
          parametersControllers: List.generate(
            method?.params.length ?? 0,
            (paramIndex) => AttFieldControllers(
              typeController: TextEditingController(text: method?.params[paramIndex].type),
              nameController: TextEditingController(text: method?.params[paramIndex].name),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final element in _attributesControllers) {
      element.dispose();
    }
    for (final element in _methodsControllers) {
      element.dispose();
    }
    super.dispose();
  }

  Future<DataStruct> _resolveType(String typeName) async {
    final existingType = Db.get(Db.typesBox, DataStruct.fromJson, typeName);
    if (existingType != null) {
      return existingType;
    }

    final newType = DataStruct(name: typeName);
    await Db.put(Db.typesBox, newType.name, newType.toJson());
    return newType;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(36.0),
      child: ListView(
        children: [
          Center(
            child: Text(
              'New Data Struct',
              style: Globals.myTheme.textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: MaxWidthBox(
              maxWidth: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: borderDecoration('Name'),
                    validator: nonEmptyStringValidator,
                  ),
                  MethodsFields(
                    controllers: _methodsControllers,
                  ),
                  AttributesFields(
                    controllers: _attributesControllers,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: widget.close,
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    final blockName = _nameController.text;

                    final blockAtts = _attributesControllers.map(
                      (attFields) {
                        _resolveType(attFields.typeController.text);
                        return Attribute(
                          type: attFields.typeController.text,
                          name: attFields.nameController.text,
                        );
                      },
                    ).toList();

                    final blockMethods = await Future.wait(_methodsControllers.map(
                      (methodFields) async {
                        return Method(
                          returnType: await _resolveType(methodFields.returnTypeController.text),
                          name: methodFields.nameController.text,
                          params: methodFields.parametersControllers.map(
                            (paramFields) {
                              _resolveType(paramFields.typeController.text);
                              return Attribute(
                                type: paramFields.typeController.text,
                                name: paramFields.nameController.text,
                              );
                            },
                          ).toList(),
                        );
                      },
                    ).toList());
                    final block = Block(
                      name: blockName,
                      attributes: blockAtts,
                      methods: blockMethods,
                    );

                    await Db.put(Db.blocksBox, block.name, block.toJson());
                    widget.close();
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BlocksContainer extends ConsumerStatefulWidget {
  const BlocksContainer({
    super.key,
    required this.blocks,
    required this.openEditorForm,
  });

  final List<Block> blocks;
  final void Function(Block) openEditorForm;

  @override
  ConsumerState<BlocksContainer> createState() => _BlocksContainerState();
}

class _BlocksContainerState extends ConsumerState<BlocksContainer> {
  @override
  Widget build(BuildContext context) {
    final selectedBlock = ref.watch(Globals.selectionsProvider.select((value) => value.block));
    return ListView(
      scrollDirection: Axis.horizontal,
      children: List.generate(
        widget.blocks.length,
        (index) {
          final isSelected = selectedBlock == widget.blocks[index];
          return MaxWidthBox(
            child: BlockView(
              block: widget.blocks[index],
              isSelected: isSelected,
              onDoubleTap: () => widget.openEditorForm(widget.blocks[index]),
              onTap: () {
                ref.read(Globals.selectionsProvider.notifier).updateBlock(isSelected ? null : widget.blocks[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
