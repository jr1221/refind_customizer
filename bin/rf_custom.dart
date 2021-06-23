import 'dart:io';
import 'package:rf_custom/rf_custom.dart';
import 'package:args/command_runner.dart';

void main(List<String> args) async {
  exitCode = 0;
  var cRun = CommandRunner('rf-custom', 'Change rEFInd defaults');
  var c = ChangeConf();
  cRun.addCommand(ChangeBoot(c));
  await cRun.run(args);
}

class ChangeBoot extends Command<void> {
  late ChangeConf confChange;

  ChangeBoot(ChangeConf c) {
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
      ..addOption('efi-path',
          abbr: 'p',
          help: 'Specify the path to the EFI directory, defaults to /boot/efi/',
          valueHelp: '/boot/',
          defaultsTo: '/boot/efi/')
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
      ..addFlag('remove-all',
          abbr: 'r',
          help: 'Remove all rules, previously booted OS will be default',
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
    await confChange.readConf(
        argResults!.wasParsed('use-efi'), argResults!['efi-path']);
    if (argResults!['number'] != null) {
      confChange.setDefaultNumberSelection(int.parse(argResults!['number']));
      return;
    }
    if (argResults!['substring'] != null) {
      confChange.setDefaultSubstringSelection(argResults!['substring']);
      return;
    }
    if (argResults!.wasParsed('get')) {
      confChange.readDefaultSelection().forEach((element) {
        stdout.writeln(element);
      });
      return;
    }
    /*  if (argResults!.wasParsed('clear-time')) {
      confChange.clearDefaultSelectionTimes();
      return;
    } */
    if (argResults!.wasParsed('remove-all')) {
      confChange.clearDefaultSelections();
      return;
    }
  }
}
