import 'dart:io';
import 'package:yaml/yaml.dart';

Future<void> main() async {
  // pubspec.yaml を読み込む
  final pubspecYaml = await File('pubspec.yaml').readAsString();
  final pubspec = loadYaml(pubspecYaml);

  // pubspec.lock を読み込む
  final pubspecLock = await File('pubspec.lock').readAsString();
  final lockData = loadYaml(pubspecLock);

  // dependencies を更新するためのマップを用意する
  final Map<String, dynamic> updatedDependencies = {};

  // pubspec.yaml から 'any' となっている依存関係を探す
  final dependencies = pubspec['dependencies'] as Map<dynamic, dynamic>;
  dependencies.forEach((key, value) {
    if (value == 'any') {
      final lockedVersion = lockData['packages'][key]['version'];
      if (lockedVersion != null) {
        // 新しいバージョンで更新
        updatedDependencies[key] = '^$lockedVersion';
      }
    } else {
      updatedDependencies[key] = value;
    }
  });

  // 新しい dependencies マップを使用して pubspec.yaml を更新
  final updatedPubspecYaml = pubspecYaml.replaceFirst(
    RegExp('dependencies:\n(.|\n)*\n\n'),
    'dependencies:\n${updatedDependencies.entries.map((e) => '  ${e.key}: ${e.value}').join('\n')}\n\n',
  );

  // 変更をファイルに書き込む
  await File('pubspec.yaml').writeAsString(updatedPubspecYaml);

  print('pubspec.yaml has been updated with locked versions.');
}
