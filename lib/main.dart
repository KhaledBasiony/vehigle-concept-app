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
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Hive.defaultDirectory = '${(await getApplicationDocumentsDirectory()).absolute.path}/diagrams';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void _putIfAbsent<T>(Box<T> box, String key, T obj) {
    if (!box.containsKey(key)) {
      box.put(key, obj);
    }
  }

  void _populateInit() {
    _putIfAbsent(Globals.typesBox, 'void', const DataStruct(name: 'void'));
  }

  @override
  Widget build(BuildContext context) {
    Hive.registerAdapter<Block>('Block', (json) => Block.fromJson(json));
    Hive.registerAdapter<ComponentData>(
      'ComponentData',
      (json) => ComponentData.fromJson(
        json,
        decodeCustomComponentData: ComponentViewData.fromJson,
      ),
    );
    Hive.registerAdapter<DataStruct>('DataStruct', (json) => DataStruct.fromJson(json));
    Hive.registerAdapter<LinkData>(
      'LinkData',
      (json) => LinkData.fromJson(
        json,
        decodeCustomLinkData: BlockLink.fromJson,
      ),
    );

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

    _diagramNameController = TextEditingController();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _diagramNameController.dispose();
    super.dispose();
  }

  List<Block> _updateBlocks() {
    return List<Block>.from(Globals.blocksBox.getAll(Globals.blocksBox.keys));
  }

  List<DataStruct> _updateTypes() {
    return List<DataStruct>.from(Globals.typesBox.getAll(Globals.typesBox.keys));
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

  void _clearDiagram() {
    setState(() {
      Globals.componentsBox.clear();
      Globals.linksBox.clear();
    });
  }

  void _saveDiagram() {
    final components = Globals.componentsBox.getAll(Globals.componentsBox.keys);
    final links = Globals.linksBox.getAll(Globals.linksBox.keys);
    final types = Globals.typesBox.getAll(Globals.typesBox.keys);
    final blocks = Globals.blocksBox.getAll(Globals.blocksBox.keys);

    final fileBytes = utf8.encode(jsonEncode({
      'components': components,
      'links': links,
      'types': types,
      'blocks': blocks,
    }));
    FileSaver().saveFile(name: _diagramNameController.text, bytes: fileBytes, ext: 'json').then(
      (value) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text('Diagram Saved Successfully At: $value'),
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
        _diagramNameController.text = fileName?.substring(0, fileName.length - 5) ?? '';
        final bytes = res.files.singleOrNull?.bytes;
        if (bytes != null) {
          final json = jsonDecode(utf8.decode(bytes));
          // Clear previous data
          Globals.componentsBox.clear();
          Globals.linksBox.clear();

          // Load components
          final components = (json['components'] as List? ?? []).map(
            (element) {
              return ComponentData.fromJson(element, decodeCustomComponentData: ComponentViewData.fromJson);
            },
          ).toList();
          Globals.componentsBox.putAll(Map.fromEntries(components.map((e) => MapEntry(e.id, e)).toList()));

          // Load links
          final links = (json['links'] as List? ?? []).map(
            (element) {
              return LinkData.fromJson(element, decodeCustomLinkData: BlockLink.fromJson);
            },
          ).toList();
          Globals.linksBox.putAll(Map.fromEntries(links.map((e) => MapEntry(e.id, e)).toList()));

          // Load types
          final types = (json['types'] as List? ?? []).map((element) => DataStruct.fromJson(element)).toList();
          Globals.typesBox.putAll(Map.fromEntries(types.map((e) => MapEntry(e.name, e)).toList()));

          // Load blocks
          final blocks = (json['blocks'] as List? ?? []).map((element) => Block.fromJson(element)).toList();
          Globals.blocksBox.putAll(Map.fromEntries(blocks.map((e) => MapEntry(e.name, e)).toList()));

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
              title: TextFormField(
                controller: _diagramNameController,
                decoration: borderDecoration(''),
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
                            stream: Globals.typesBox.watch(),
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
                            stream: Globals.blocksBox.watch(),
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
