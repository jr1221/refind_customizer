import 'dart:io';
import 'dart:typed_data';

import 'package:strings/strings.dart';

class ChangeConf {
  late File defaultsConf;
  late List<String> defaultLines;

  late File prevBoot;
  late String _prevBootStr;

  bool use_efi = false;

  String get prevBootAsString => _prevBootStr;

  Future<void> _setConf() async {
    /*   if (defaultLines.length > 1 ) {
        if (defaultLines.where((element) => !element.contains(':')).length > 1) {
          defaultLines.removeAt(defaultLines.indexWhere((element) => !element.contains(':')));
        }
    } */
    if (defaultLines.length > 1) {
      defaultLines.removeAt(0);
    }
    await defaultsConf.writeAsString(join(defaultLines, '\n'));
  }

  Future<void> readConf(bool to_use_efi, String efi_path) async {
    use_efi = to_use_efi;
    if (!efi_path.endsWith('/')) {
      efi_path += '/';
    }
    if (use_efi) {
      prevBoot = File(efi_path + 'EFI/refind/vars/PreviousBoot');
      _prevBootStr = await prevBoot.readAsString();
    } else {
      var conf = File(efi_path + 'EFI/refind/refind.conf');
      var confLines = await conf.readAsLines();
      if (!(confLines.last == 'include refind-default-selections.conf')) {
        confLines.add('include refind-default-selections.conf');
      }
      await conf.writeAsString(join(confLines, '\n'));
      defaultsConf =
          File(efi_path + 'EFI/refind/refind-default-selections.conf');
      try {
        await defaultsConf.create();
      } catch (e) {
        stderr.writeln('Non-fatal \n$e');
      }
      defaultLines = await defaultsConf.readAsLines();
    }
  }

  void setDefaultSubstringSelection(String s) {
    if (use_efi) {
      var codeUnits = s.codeUnits;
      var byteData = ByteData(codeUnits.length * 2);
      for (var i = 0; i < codeUnits.length; i += 1) {
        byteData.setUint16(i * 2, codeUnits[i], Endian.little);
      }
      var bytes = byteData.buffer.asUint8List();
      prevBoot.writeAsBytes(bytes, flush: true);
    } else {
      defaultLines.add('default_selection "$s"');
      _setConf();
    }
  }

  void setDefaultNumberSelection(int n) {
    if (use_efi) {
      stderr.writeln(
          'use-efi can only be used to set a substring default and get the current substring');
    } else {
      defaultLines.add('default_selection $n');
      _setConf();
    }
  }

  List<String> readDefaultSelection() {
    if (use_efi) {
      return [_prevBootStr];
    }
    return defaultLines.isNotEmpty
        ? defaultLines
        : ['There are no set configurations, defaults to previously booted OS'];
  }

  /* void clearDefaultSelectionTimes() {
    defaultLines.removeWhere((element) =>
        element.startsWith('default_selection') && element.contains(':'));
    _setConf();
  } */

  void clearDefaultSelections() {
    defaultLines.clear();
    _setConf();
  }
}

/*
class Conf {

  // for all bools: false or off or 0 -- true is blank or true or on or 1

  int timeout = 20; // -1 is immediate boot
  int log_level = 0; // 4 is max
  bool shutdown_after_timeout = false;
  bool use_nvram = false;
  int screensaver = 0; // -1 is blank display until timeout reached

  static const List<String> hideui_vals = ['banner', 'label', 'singleuser', 'safemode', 'hwtest', 'arrows', 'hints', 'editor', 'badges', 'all'];
  String hideui = '';


  String icons_dir = 'icons';
  String banner = '';

  static const List<String> banner_scale_vals = ['noscale', 'fillscreen'];
  String banner_scale = banner_scale_vals.first;

  int big_icon_size = 128; // > 32 128 not always default
  int small_icon_size = 48; // > 32 48 not always default
  String selection_big = '';
  String selection_small = '';

  static const List<String> showtools_vals = ['shell', 'memtest', 'gdisk', 'gptsync', 'install', 'bootorder', 'apple_recovery', 'csr_rotate', 'mok_tool', 'fwupdate', 'netboot', 'about', 'hidden_tags', 'exit', 'shutdown', 'reboot', 'firmware'];
  String showtools = 'shell, memtest, gdisk, apple_recovery, windows_recovery, mok_tool, about, hidden_tags, shutdown, reboot, firmware, fwupdate';

  String font = '';
  bool textonly = false;
  int textmode = 1024;
  String resolution = '0 0'; // 'max' possible
  bool enable_touch = false;
  bool enable_mouse = false;
  int mouse_size = 16;
  int mouse_speed = 1;

  static const List<String> use_graphics_for_vals = ['osx', 'linux', 'elilo', 'grub', 'windows'];
  String use_graphics_for = use_graphics_for_vals.first;

  String scan_driver_dirs = '';

  static const List<String> scanfor_vals = ['internal', 'external', 'optical', 'netboot', 'hdbios', 'biosexternal', 'cd', 'manual', 'firmware'];
  String scanfor = ''; // differs on systems

  bool uefi_deep_legacy_scan = false;
  int scan_delay = 0;
  String also_scan_dirs = '';
  String dont_scan_volumes = '';
  String dont_scan_dirs = '';
  String dont_scan_files = '';
  String dont_scan_tools = '';
  String windows_recovery_files = '';
  bool scan_all_linux_kernels = true;
  bool fold_linux_kernels = true;
  String extra_kernel_version_strings = '';
  bool write_systemd_vars = false;
  int max_tags = 0;
  List<String> default_selection = [];
  bool enable_and_lock_vmx = false;
  String spoof_osx_version = '';
  String csr_values = '';
  String include = '';







  Conf();
} */
