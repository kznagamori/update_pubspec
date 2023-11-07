import 'dart:io';
import 'package:yaml/yaml.dart';

Future<void> main() async {
  // pubspec.yaml ��ǂݍ���
  final pubspecYaml = await File('pubspec.yaml').readAsString();
  final pubspec = loadYaml(pubspecYaml);

  // pubspec.lock ��ǂݍ���
  final pubspecLock = await File('pubspec.lock').readAsString();
  final lockData = loadYaml(pubspecLock);

  // dependencies ���X�V���邽�߂̃}�b�v��p�ӂ���
  final Map<String, dynamic> updatedDependencies = {};

  // pubspec.yaml ���� 'any' �ƂȂ��Ă���ˑ��֌W��T��
  final dependencies = pubspec['dependencies'] as Map<dynamic, dynamic>;
  dependencies.forEach((key, value) {
    if (value == 'any') {
      final lockedVersion = lockData['packages'][key]['version'];
      if (lockedVersion != null) {
        // �V�����o�[�W�����ōX�V
        updatedDependencies[key] = '^$lockedVersion';
      }
    } else {
      updatedDependencies[key] = value;
    }
  });

  // �V���� dependencies �}�b�v���g�p���� pubspec.yaml ���X�V
  final updatedPubspecYaml = pubspecYaml.replaceFirst(
    RegExp('dependencies:\n(.|\n)*\n\n'),
    'dependencies:\n${updatedDependencies.entries.map((e) => '  ${e.key}: ${e.value}').join('\n')}\n\n',
  );

  // �ύX���t�@�C���ɏ�������
  await File('pubspec.yaml').writeAsString(updatedPubspecYaml);

  print('pubspec.yaml has been updated with locked versions.');
}
