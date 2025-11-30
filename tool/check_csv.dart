import 'dart:io';
import 'dart:convert';

void main() async {
  final path = r'c:\Projects\prism\anc_ae_kakeibo_export.csv';
  final file = File(path);

  if (!await file.exists()) {
    print('File not found: $path');
    return;
  }

  final bytes = await file.readAsBytes();
  print('File size: ${bytes.length} bytes');
  print('First 20 bytes: ${bytes.take(20).toList()}');

  try {
    final text = utf8.decode(bytes);
    print('UTF-8 decode success. Length: ${text.length}');
    print('First 100 chars: ${text.substring(0, 100)}');
  } catch (e) {
    print('UTF-8 decode failed: $e');
  }
}
