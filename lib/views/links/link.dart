import 'package:concept_designer/common/globals.dart';
import 'package:concept_designer/common/misc.dart';
import 'package:concept_designer/views/blocks/block.dart';
import 'package:concept_designer/views/blocks/method.dart';
import 'package:diagram_editor/diagram_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';

part 'link.g.dart';

@JsonSerializable()
class BlockLink {
  BlockLink({
    required this.from,
    required this.to,
    this.callerMethod,
    this.handlerMethod,
    this.type = LinkType.oneWay,
  });
  final Block from;
  final Block to;
  Method? callerMethod;
  Method? handlerMethod;
  LinkType type;

  factory BlockLink.fromJson(Map<String, dynamic> json) => _$BlockLinkFromJson(json);
  Map<String, dynamic> toJson() => _$BlockLinkToJson(this);
}

enum LinkType {
  oneWay,
  twoWay,
  stream,
}

class LinkForm extends ConsumerStatefulWidget {
  const LinkForm({
    super.key,
    required this.link,
    required this.linkData,
    required this.close,
  });

  // The Naming is confusing I know :/
  // this contains the graph data, and a field for my custom data
  final LinkData link;

  // this is my custom data;
  final BlockLink linkData;

  final void Function() close;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LinkFormState();
}

class _LinkFormState extends ConsumerState<LinkForm> {
  final _formKey = GlobalKey<FormState>();

  Method? _fromMethod;
  Method? _toMethod;
  late LinkType _connectionType;

  late final TextEditingController _linkData;

  @override
  void initState() {
    super.initState();
    _fromMethod = widget.linkData.callerMethod;
    _toMethod = widget.linkData.handlerMethod;
    _connectionType = widget.linkData.type;
    _linkData = TextEditingController(text: _toMethod?.returnType.name);
    _linkData.addListener(() {
      setState(() {
        _connectionType = _linkData.text.isNotEmpty ? LinkType.twoWay : LinkType.oneWay;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _linkData.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(36.0),
      child: ListView(
        children: [
          Center(
            child: Text(
              'Link Form',
              style: Globals.myTheme.textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints.tightFor(width: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'From: ',
                          children: [
                            TextSpan(
                              text: widget.linkData.from.name,
                              style: Globals.myTheme.textTheme.bodyLarge!.copyWith(
                                color: Globals.myTheme.colorScheme.primary,
                              ),
                            )
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'To: ',
                          children: [
                            TextSpan(
                              text: widget.linkData.to.name,
                              style: Globals.myTheme.textTheme.bodyLarge!.copyWith(
                                color: Globals.myTheme.colorScheme.primary,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
                  DropdownButtonFormField(
                    decoration: borderDecoration('Calling Method (optional)'),
                    value: _fromMethod,
                    items: widget.linkData.from.methods
                        .map((method) => DropdownMenuItem(
                              value: method,
                              child: Text(method.name),
                            ))
                        .toList(),
                    onChanged: (newVal) {
                      setState(() {
                        _fromMethod = newVal;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField(
                    decoration: borderDecoration('Handler Method (required)'),
                    value: _toMethod,
                    items: widget.linkData.to.methods
                        .map((method) => DropdownMenuItem(
                              value: method,
                              child: Text(method.name),
                            ))
                        .toList(),
                    onChanged: (newVal) {
                      setState(() {
                        _toMethod = newVal;
                        if (_toMethod?.returnType.name == 'void') {
                          _linkData.text = '';
                        } else {
                          _linkData.text = _toMethod?.returnType.name ?? '';
                        }
                      });
                    },
                    validator: (value) => value == null ? 'this cannot be empty' : null,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField(
                    value: _connectionType,
                    items: LinkType.values
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(switch (e) {
                              LinkType.oneWay => 'One Way',
                              LinkType.twoWay => 'Two Way',
                              LinkType.stream => 'Data Stream',
                            }),
                          ),
                        )
                        .toList(),
                    decoration: borderDecoration('Link Connection Type'),
                    onChanged: (newVal) {
                      setState(() {
                        _connectionType = newVal!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _linkData,
                    enabled: false,
                    decoration: borderDecoration('Link Data Type'),
                  ),
                ],
              ),
            ),
          ),
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
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    widget.linkData.callerMethod = _fromMethod;
                    widget.linkData.handlerMethod = _toMethod;

                    Globals.linksBox.put(widget.link.id, widget.link);
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
