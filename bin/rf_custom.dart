import 'dart:io';
import 'package:rf_custom/rf_custom.dart';
import 'package:args/command_runner.dart';

void main(List<String> args) async {
  exitCode = 0;
  var cRun = CommandRunner('rf-custom', 'Change rEFInd defaults')
    ..argParser.addOption('efi-path',
        abbr: 'p',
        help: 'Specify the path to the EFI directory, defaults to /boot/efi/',
        valueHelp: '/boot/',
        defaultsTo: '/boot/efi/');
  cRun
    ..addCommand(ChangeBoot(ChangeBootConf()))
    ..addCommand(ChangeSettings(ChangeSettingsConf()));
  await cRun.run(args);
}

class ChangeBoot extends Command<void> {
  late ChangeBootConf confChange;

  ChangeBoot(ChangeBootConf c) {
    confChange = c;
    argParser
      ..addOption('number',
          abbr: 'n',
          help: 'Default to the nth option in the menu (from left to right)',
          allowed: ['1', '2', '3', '4', '5', '6', '7', '8', '9'])
      ..addOption('substring',
          abbr: 's',
          help:
                'Default to the first matching string of any boot description, separate multiple strings by commas',
          valueHelp: 'boot/vmlinuz-5.8.0-22-generic')
      ..addFlag('get',
          abbr: 'g',
          help: 'Get the current selection configuration',
          defaultsTo: false,
          negatable: false)
      ..addFlag('use-efi',
          abbr: 'e',
          help:
              'Use the EFI variable to boot OS, "use_nvram false" must be in refind.conf to use this method',
          hide: true)
      /*   ..addFlag('clear-time',
          abbr: 'c',
          help: 'Clear all set time rules, leaving other switch rules in place',
          defaultsTo: false,
          negatable: false) */
      ..addFlag('clear-all',
          abbr: 'c',
          help: 'Clear all rules, previously booted OS will be default',
          defaultsTo: false,
          negatable: false);
  }

  @override
  final String description =
      'Switch default OS to boot into if no user action taken during rEFInd timeout.';

  @override
  final String summary = 'Switch default OS to boot into';

  @override
  final String name = 'default';

  @override
  Future<void> run() async {
    assert(argResults != null);
    await confChange.read(
        argResults!.wasParsed('use-efi'), globalResults!['efi-path']);
    if (argResults!['number'] != null) {
      confChange.setDefaultNumberSelection(int.parse(argResults!['number']));
      return;
    }
    if (argResults!['substring'] != null) {
      confChange.setDefaultSubstringSelection(argResults!['substring']);
      return;
    }
    if (argResults!.wasParsed('get')) {
      confChange.get().forEach((element) {
        stdout.writeln(element);
      });
      return;
    }
    /*  if (argResults!.wasParsed('clear-time')) {
      confChange.clearDefaultSelectionTimes();
      return;
    } */
    if (argResults!.wasParsed('clear-all')) {
      confChange.clear();
      return;
    }
  }
}

class ChangeSettings extends Command<void> {
  late ChangeSettingsConf confChange;

  ChangeSettings(ChangeSettingsConf c) {
    confChange = c;
    argParser
      ..addFlag('get',
          abbr: 'g',
          help: 'Get the current selection configuration',
          defaultsTo: false,
          negatable: false)
      ..addFlag('clear-all',
          abbr: 'c',
          help: 'Clear all rules, previously booted OS will be default',
          defaultsTo: false,
          negatable: false);
  }

  @override
  final String description = 'Change rEFInd settings, such as timeout.';

  @override
  final String summary = 'Change rEFInd settings';

  @override
  final String name = 'settings';

  @override
  Future<void> run() async {
    assert(argResults != null);
    await confChange.read(globalResults!['efi-path']);
    if (argResults!.wasParsed('get')) {
      confChange.get().forEach((element) {
        stdout.writeln(element);
      });
      return;
    }
    if (argResults!.wasParsed('clear-all')) {
      confChange.clear();
      return;
    }
  }
}
