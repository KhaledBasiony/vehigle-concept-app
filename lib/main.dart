import 'dart:convert';

import 'package:concept_designer/common/globals.dart';
import 'package:concept_designer/common/misc.dart';
import 'package:concept_designer/views/diagrams/diagram.dart';
import 'package:concept_designer/views/links/link.dart';
import 'package:concept_designer/views/types/type.dart';
import 'package:concept_designer/views/blocks/block.dart';
import 'package:diagram_editor/diagram_editor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Db.open();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void _populateInit() {
    if (Db.get(Db.typesBox, DataStruct.fromJson, 'void') != null) {
      Db.put(Db.typesBox, 'void', const DataStruct(name: 'void').toJson());
    }
  }

  @override
  Widget build(BuildContext context) {
    _populateInit();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Globals.myTheme,
      home: const ProviderScope(child: MyHomePage()),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> with SingleTickerProviderStateMixin {
  bool _isTypesVisible = false;
  bool _isBlocksVisible = false;
  late TextEditingController _diagramNameController;
  final _optionsFormKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _sizeAnimation;

  Widget _endDrawerChild = const Placeholder();

  @override
  void initState() {
    super.initState();

    _updateTypes();
    _updateBlocks();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _sizeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _diagramNameController = TextEditingController(text: 'tmp');
  }

  @override
  void dispose() {
    _animationController.dispose();
    _diagramNameController.dispose();
    super.dispose();
  }

  List<Block> _updateBlocks() {
    return List<Block>.from(Db.getAll(Db.blocksBox, Block.fromJson));
  }

  List<DataStruct> _updateTypes() {
    return List<DataStruct>.from(Db.getAll(Db.typesBox, DataStruct.fromJson));
  }

  void _showTypeEditor([DataStruct? type]) {
    setState(() {
      _endDrawerChild = DataStructForm(
        type: type,
        close: _hideEditor,
      );
    });
    _animationController.forward();
  }

  void _showBlockEditor([Block? block]) {
    setState(() {
      _endDrawerChild = BlockForm(
        block: block,
        close: _hideEditor,
      );
    });
    _animationController.forward();
  }

  void _showLinkEditor(LinkData link) {
    setState(() {
      _endDrawerChild = LinkForm(
        link: link,
        linkData: link.data as BlockLink,
        close: _hideEditor,
      );
    });
    _animationController.forward();
  }

  void _hideEditor() {
    _animationController.reverse().then((_) {
      setState(() {
        _endDrawerChild = const Placeholder();
      });
    });
  }

  void _clearDiagram() async {
    await Db.clearAll(Db.componentsBox);
    await Db.clearAll(Db.linksBox);
    final selectionNotifier = ref.read(Globals.selectionsProvider.notifier);
    selectionNotifier.updateBlock(null);
    selectionNotifier.updateComponentId(null);
    selectionNotifier.updateLink(null);
    selectionNotifier.updateType(null);
    setState(() {});
  }

  void _saveDiagram() {
    if (!_optionsFormKey.currentState!.validate()) {
      return;
    }
    final components = Db.getAll(Db.componentsBox, Globals.componentDataFromJson);
    final links = Db.getAll(Db.linksBox, Globals.linkDataFromJson);
    final types = Db.getAll(Db.typesBox, DataStruct.fromJson);
    final blocks = Db.getAll(Db.blocksBox, Block.fromJson);

    final fileBytes = utf8.encode(jsonEncode({
      'components': components,
      'links': links,
      'types': types,
      'blocks': blocks,
    }));

    FileSaver.instance.saveFile(name: _diagramNameController.text, bytes: fileBytes, ext: 'json').then(
      (path) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text('Diagram Saved Successfully At: $path'),
          ),
        );
      },
    );
  }

  void _loadDiagram() async {
    final value = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning!'),
        content: const Text('Any unsaved changes will be lost!\n'
            'Make Sure to save your changes before continuing.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (value ?? false) {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (res != null) {
        final fileName = res.files.singleOrNull?.name;

        // sets diagram name to file name after removing '.json' extension
        _diagramNameController.text = fileName?.substring(0, fileName.length - 5).replaceAll(RegExp(r'\s'), '_') ?? '';
        final bytes = res.files.singleOrNull?.bytes;
        if (bytes != null) {
          final json = jsonDecode(utf8.decode(bytes));
          // Clear previous data
          Db.clearAll(Db.componentsBox);
          Db.clearAll(Db.linksBox);

          // Load types
          final types = (json['types'] as List? ?? []).map((element) => DataStruct.fromJson(element)).toList();
          await Db.putAll(Db.typesBox, Map.fromEntries(types.map((e) => MapEntry(e.name, e.toJson())).toList()));

          // Load blocks
          final blocks = (json['blocks'] as List? ?? []).map((element) => Block.fromJson(element)).toList();
          await Db.putAll(Db.blocksBox, Map.fromEntries(blocks.map((e) => MapEntry(e.name, e.toJson())).toList()));

          // Load components
          final components = (json['components'] as List? ?? [])
              .map(
                (element) => Globals.componentDataFromJson(element),
              )
              .toList();
          await Db.putAll(
              Db.componentsBox, Map.fromEntries(components.map((e) => MapEntry(e.id, e.toJsonMod())).toList()));

          // Load links
          final links = (json['links'] as List? ?? [])
              .map(
                (element) => Globals.linkDataFromJson(element),
              )
              .toList();
          await Db.putAll(Db.linksBox, Map.fromEntries(links.map((e) => MapEntry(e.id, e.toJson())).toList()));

          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Globals.myTheme.colorScheme.inversePrimary,
        title: const Text('Vehigle App Conecpt Creator'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton.extended(
              elevation: 0,
              // backgroundColor: Globals.myTheme.colorScheme.inversePrimary,
              onPressed: () => setState(() {}),
              label: const Text('Refresh'),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              child: Container(
                decoration: BoxDecoration(
                  color: Globals.myTheme.colorScheme.inversePrimary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(70),
                    bottomRight: Radius.circular(70),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: const Center(
                  child: Text('Vehigle App Concept Creator'),
                ),
              ),
            ),
            const ListTile(
              title: Text('Diagram Name:'),
            ),
            ListTile(
              title: Form(
                key: _optionsFormKey,
                child: TextFormField(
                  controller: _diagramNameController,
                  decoration: borderDecoration(''),
                  validator: nonEmptyStringValidator,
                ),
              ),
            ),
            const ListTile(
              title: Text('Options:'),
            ),
            ListTile(
              leading: const Icon(Icons.save_rounded),
              title: const Text('Save Current Diagram'),
              onTap: _saveDiagram,
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever_rounded),
              title: const Text('Clear Current Diagram'),
              onTap: _clearDiagram,
            ),
            ListTile(
              leading: const Icon(Icons.open_in_new_rounded),
              title: const Text('Load Diagram'),
              onTap: _loadDiagram,
            ),
            const ListTile(),
          ],
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          ref.listen(
            Globals.selectionsProvider.select((value) => value.link),
            (previous, next) {
              if (next == null) {
                _hideEditor();
                return;
              }
              if (previous != next) {
                _showLinkEditor(next);
              }
            },
          );
          return child!;
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _showTypeEditor(),
                          icon: const Icon(Icons.add),
                        ),
                        IconButton(
                          onPressed: () => setState(() {
                            _updateTypes();
                            _isTypesVisible = !_isTypesVisible;
                          }),
                          icon: _isTypesVisible
                              ? const Icon(Icons.arrow_downward_rounded)
                              : const Icon(Icons.arrow_forward_rounded),
                        ),
                        const Text('Types'),
                        const Expanded(child: HDivider()),
                      ],
                    ),
                    Visibility(
                      visible: _isTypesVisible,
                      child: Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StreamBuilder(
                            stream: Db.watch(Db.typesBox),
                            builder: (context, snapshot) {
                              final types = _updateTypes();
                              return DataStructsContainer(
                                types: types,
                                openEditorForm: _showTypeEditor,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _showBlockEditor,
                          icon: const Icon(Icons.add),
                        ),
                        IconButton(
                          onPressed: () => setState(() {
                            _updateBlocks();
                            _isBlocksVisible = !_isBlocksVisible;
                          }),
                          icon: _isBlocksVisible
                              ? const Icon(Icons.arrow_downward_rounded)
                              : const Icon(Icons.arrow_forward_rounded),
                        ),
                        const Text('Blocks'),
                        const Expanded(child: HDivider()),
                      ],
                    ),
                    Visibility(
                      visible: _isBlocksVisible,
                      child: Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StreamBuilder(
                            stream: Db.watch(Db.blocksBox),
                            builder: (context, snapshot) {
                              final blocks = _updateBlocks();
                              return BlocksContainer(
                                blocks: blocks,
                                openEditorForm: _showBlockEditor,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4 + (_isBlocksVisible ? 0 : 2) + (_isTypesVisible ? 0 : 1),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DiagramView(),
                      ),
                    ),
                  ],
                ),
              ),
              SizeTransition(
                axis: Axis.horizontal,
                sizeFactor: _sizeAnimation,
                child: Column(
                  children: [
                    Expanded(
                      child: MaxWidthBox(
                        maxWidth: 500,
                        child: _endDrawerChild,
                      ),
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
