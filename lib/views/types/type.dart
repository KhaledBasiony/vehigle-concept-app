import 'package:concept_designer/common/attr_input.dart';
import 'package:concept_designer/common/globals.dart';
import 'package:concept_designer/common/misc.dart';
import 'package:concept_designer/views/blocks/attribute.dart';
import 'package:concept_designer/views/base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';

part 'type.g.dart';

@JsonSerializable()
class DataStruct {
  const DataStruct({
    required this.name,
    this.fields = const [],
  });
  final String name;

  @JsonKey(
    toJson: Globals.attsToJson,
    fromJson: Globals.attsFromJson,
  )
  final List<Attribute> fields;

  bool get isPrimitive => fields.isEmpty;

  factory DataStruct.fromJson(Map<String, dynamic> json) => _$DataStructFromJson(json);
  Map<String, dynamic> toJson() => _$DataStructToJson(this);

  @override
  String toString() => name;
}

class DataStructView extends StatelessWidget {
  const DataStructView({
    super.key,
    required this.dataStruct,
    this.isSelected = false,
    this.onDoubleTap,
    this.onTap,
  });

  final DataStruct dataStruct;
  final bool isSelected;
  final void Function()? onDoubleTap;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: BaseView(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        isSelected: isSelected,
        title: dataStruct.name,
        children: dataStruct.isPrimitive
            ? [
                const Center(
                  child: Text('Primitive Type'),
                )
              ]
            : [
                for (final field in dataStruct.fields) AttributeView(attribute: field),
              ],
      ),
    );
  }
}

class DataStructForm extends StatefulWidget {
  const DataStructForm({
    super.key,
    this.type,
    required this.close,
  });

  final DataStruct? type;
  final void Function() close;

  @override
  State<DataStructForm> createState() => _DataStructFormState();
}

class _DataStructFormState extends State<DataStructForm> {
  late final TextEditingController _nameController;
  late final List<AttFieldControllers> _attributesControllers;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.type?.name ?? '');
    _attributesControllers = widget.type?.fields
            .map(
              (att) => AttFieldControllers(
                typeController: TextEditingController(text: att.type),
                nameController: TextEditingController(text: att.name),
              ),
            )
            .toList() ??
        [AttFieldControllers()];
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var element in _attributesControllers) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(width: 500),
        child: Padding(
          padding: const EdgeInsets.all(36.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  'Data Struct Form',
                  style: Globals.myTheme.textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: borderDecoration('Name'),
                validator: nonEmptyStringValidator,
              ),
              AttributesFields(controllers: _attributesControllers),
              Padding(
                padding: const EdgeInsets.all(20.0),
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
                        final struct = DataStruct(
                          name: _nameController.text,
                          fields: _attributesControllers
                              .map(
                                (e) => Attribute(type: e.typeController.text, name: e.nameController.text),
                              )
                              .toList(),
                        );
                        await Db.put(Db.typesBox, struct.name, struct.toJson());
                        widget.close();
                      },
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DataStructsContainer extends ConsumerStatefulWidget {
  const DataStructsContainer({
    super.key,
    required this.types,
    required this.openEditorForm,
  });

  final List<DataStruct> types;
  final void Function(DataStruct) openEditorForm;

  @override
  ConsumerState<DataStructsContainer> createState() => _DataStructsContainerState();
}

class _DataStructsContainerState extends ConsumerState<DataStructsContainer> {
  int? _selectedIndex;
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: List.generate(
        widget.types.length,
        (index) => MaxWidthBox(
          child: DataStructView(
              dataStruct: widget.types[index],
              isSelected: _selectedIndex == index,
              onDoubleTap: () => widget.openEditorForm(widget.types[index]),
              onTap: () {
                setState(() {
                  _selectedIndex = _selectedIndex == index ? null : index;
                });
                ref.read(Globals.selectionsProvider.notifier).updateType(
                      widget.types.elementAtOrNull(
                        _selectedIndex ?? double.maxFinite.floor(),
                      ),
                    );
              }),
        ),
      ),
    );
  }
}
