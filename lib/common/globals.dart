import 'package:concept_designer/common/misc.dart';
import 'package:concept_designer/views/blocks/attribute.dart';
import 'package:concept_designer/views/blocks/block.dart';
import 'package:concept_designer/views/blocks/method.dart';
import 'package:concept_designer/views/diagrams/diagram.dart';
import 'package:concept_designer/views/links/link.dart';
import 'package:concept_designer/views/types/type.dart';
import 'package:diagram_editor/diagram_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

abstract class Globals {
  static final myTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  static LinkData linkDataFromJson(Map<String, dynamic> json) => LinkData.fromJson(
        json,
        decodeCustomLinkData: BlockLink.fromJson,
      );

  static ComponentData componentDataFromJson(Map<String, dynamic> json) => ComponentData.fromJson(
        json,
        decodeCustomComponentData: ComponentViewData.fromJson,
      );

  static String typeToJson(DataStruct e) => e.name;
  static DataStruct typeFromJson(String e) => Db.get(Db.typesBox, DataStruct.fromJson, e) ?? DataStruct(name: e);

  static List<Map<String, dynamic>> attsToJson(List<Attribute> e) => e.map((e) => e.toJson()).toList();
  static List<Attribute> attsFromJson(Iterable e) => e.map((e) => Attribute.fromJson(e)).toList();

  static List<Map<String, dynamic>> methodsToJson(List<Method> e) => e.map((e) => e.toJson()).toList();
  static List<Method> methodsFromJson(Iterable e) => e.map((e) => Method.fromJson(e)).toList();

  static String blockToJson(Block e) => e.name;
  static Block blockFromJson(String e) => Db.get(Db.blocksBox, Block.fromJson, e) ?? Block(name: e);

  static final selectionsProvider = StateNotifierProvider<SelectionsNotifier, Selections>((ref) {
    return SelectionsNotifier();
  });
}

abstract class Db {
  static late final Database blocksBox;
  static late final Database typesBox;
  static late final Database linksBox;
  static late final Database componentsBox;
  static final store = stringMapStoreFactory.store();

  static Future<void> open() async {
    final DatabaseFactory factory;
    if (kIsWeb) {
      factory = databaseFactoryWeb;
    } else {
      factory = databaseFactoryIo;
    }
    blocksBox = await factory.openDatabase('blocks.db');
    typesBox = await factory.openDatabase('types.db');
    linksBox = await factory.openDatabase('links.db');
    componentsBox = await factory.openDatabase('components.db');
  }

  static Future<void> put(Database db, String key, Map<String, dynamic> value) async {
    await store.record(key).put(db, value);
  }

  static Future<void> putAll(Database db, Map<String, Map<String, dynamic>> entries) async {
    await store.records(entries.keys).put(db, entries.values.toList());
  }

  static T? get<T>(
    Database db,
    T Function(Map<String, dynamic>) fromJson,
    String key,
  ) {
    final json = store.record(key).getSync(db);
    if (json == null) {
      return null;
    } else {
      return fromJson(json);
    }
  }

  static List<T?> getAll<T>(
    Database db,
    T Function(Map<String, dynamic>) fromJson, [
    List<String>? keys,
  ]) {
    final results = store.records(keys ?? store.findKeysSync(db)).getSync(db);
    return results.map((e) => e == null ? null : fromJson(e)).toList();
  }

  static Future<void> clearAll(Database db, [List<String>? keys]) async {
    await store.records(keys ?? store.findKeysSync(db)).delete(db);
  }

  static Stream watch(Database db) {
    return store.stream(db);
  }
}
