import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kaffee_begleiter/app/app_services.dart';
import 'package:kaffee_begleiter/core/files/file_transfer.dart';
import 'package:kaffee_begleiter/core/files/save_outcome.dart';
import 'package:kaffee_begleiter/core/rules/rule_source.dart';
import 'package:kaffee_begleiter/features/settings/data/rule_sources_loader.dart';
import 'package:material_ui/material_ui.dart';

import '../../form_helpers.dart';
import '../../helpers.dart';
import '../brews/brew_test_helpers.dart';

class FakeTransfer implements FileTransfer {
  String? savedName;
  String? savedContent;
  String? toPick;
  SaveOutcome outcome = SaveOutcome.downloaded;

  @override
  bool get canPick => true;

  @override
  Future<SaveOutcome> save(String fileName, String content) async {
    savedName = fileName;
    savedContent = content;
    return outcome;
  }

  @override
  Future<String?> pickText() async => toPick;
}

class DiskRules implements RuleSource {
  @override
  Future<String> loadString(String assetName) async =>
      File(assetName).readAsString();
}

void main() {
  late FakeTransfer transfer;
  setUp(() => transfer = FakeTransfer());

  Future<BrewSeed> open(WidgetTester tester, {Locale? locale}) async {
    final s = await seedBrewData();
    await pumpApp(
      tester,
      data: s.data,
      height: tallViewport,
      locale: locale ?? const Locale('en'),
      services: AppServices(
        transfer: transfer,
        sources: RuleSourcesLoader(DiskRules()),
      ),
    );
    await goTo(tester, '/settings');
    return s;
  }

  Future<void> pasteImport(WidgetTester tester, String text) async {
    await tapKey(tester, 'settings-import-paste');
    await tester.enterText(find.byKey(const Key('import-json-field')), text);
    await tester.tap(find.byKey(const Key('import-json-confirm')));
    await tester.pumpAndSettle();
  }

  testWidgets('export hands the dated JSON file to the platform', (
    tester,
  ) async {
    await open(tester);
    await tapKey(tester, 'settings-export');
    expect(transfer.savedName, 'coffee-export-2026-11-16.json');
    final root = jsonDecode(transfer.savedContent!) as Map;
    expect(root['schemaVersion'], 1);
    expect(find.textContaining('coffee-export-2026-11-16.json'), findsWidgets);
  });

  testWidgets('a shared export is announced as shared', (tester) async {
    transfer.outcome = SaveOutcome.shared;
    await open(tester);
    await tapKey(tester, 'settings-export');
    expect(
      find.text('Export shared: coffee-export-2026-11-16.json'),
      findsOneWidget,
    );
  });

  testWidgets('UC9: delete all data, then import brings the bean back', (
    tester,
  ) async {
    final s = await open(tester);
    final json = s.data.exportJson();
    await tapKey(tester, 'settings-delete-all');
    expect(find.text('Delete all data?'), findsOneWidget);
    await tapKey(tester, 'delete-all-confirm');
    expect(s.data.beans, isEmpty);
    await pasteImport(tester, json);
    expect(s.data.beans.single.name, 'Kenya AA');
    expect(find.textContaining('records imported'), findsOneWidget);
  });

  testWidgets('cancelling delete-all keeps the data', (tester) async {
    final s = await open(tester);
    await tapKey(tester, 'settings-delete-all');
    await tapKey(tester, 'delete-all-cancel');
    expect(s.data.beans, hasLength(1));
  });

  testWidgets('unknown schemaVersion shows the message and changes nothing', (
    tester,
  ) async {
    final s = await open(tester);
    final root = jsonDecode(s.data.exportJson()) as Map<String, Object?>
      ..['schemaVersion'] = 2;
    await pasteImport(tester, jsonEncode(root));
    expect(find.text('File version not supported'), findsOneWidget);
    expect(s.data.beans, hasLength(1));
  });

  testWidgets('skipped records are reported', (tester) async {
    final s = await open(tester);
    final root = jsonDecode(s.data.exportJson()) as Map<String, Object?>;
    await s.data.clearAll();
    root['beans'] = <Object?>[];
    await pasteImport(tester, jsonEncode(root));
    expect(find.textContaining('1 records skipped'), findsOneWidget);
  });

  testWidgets('invalid text is rejected (de)', (tester) async {
    await open(tester, locale: const Locale('de'));
    await pasteImport(tester, 'kein json');
    expect(find.text('Datei ungültig'), findsOneWidget);
  });

  testWidgets('the sources list shows entries without a source', (
    tester,
  ) async {
    await tester.runAsync(() => open(tester));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings-sources')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Default without source').first,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Default without source'), findsWidgets);
  });
}
