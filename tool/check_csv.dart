// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final path = r'c:\Projects\prism\anc_ae_kakeibo_export.csv';
  final file = File(path);

  if (!file.existsSync()) {
    print('File not found: $path');
    return;
  }

  final bytes = file.readAsBytesSync();
  print('File size: ${bytes.length} bytes');
  print('First 20 bytes: ${bytes.take(20).toList()}');

  try {
    final text = utf8.decode(bytes);
    print('UTF-8 decode success. Length: ${text.length}');
    print('First 100 chars: ${text.substring(0, 100)}');
  } on FormatException catch (e) {
    print('UTF-8 decode failed: $e');
  }
}
