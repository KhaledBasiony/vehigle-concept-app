import 'package:concept_designer/common/misc.dart';
import 'package:concept_designer/views/blocks/block.dart';
import 'package:concept_designer/views/types/type.dart';
import 'package:diagram_editor/diagram_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

abstract class Globals {
  static final myTheme = ThemeData(
    textTheme: Typography.englishLike2021,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  static final blocksBox = Hive.box<Block>(name: 'blocks');
  static final typesBox = Hive.box<DataStruct>(name: 'types');
  static final linksBox = Hive.box<LinkData>(name: 'links');
  static final componentsBox = Hive.box<ComponentData>(name: 'components');

  static final selectionsProvider = StateNotifierProvider<SelectionsNotifier, Selections>((ref) {
    return SelectionsNotifier();
  });
}
