import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import '../models/finance_items.dart';

class BackupImportResult {
  const BackupImportResult({
    required this.installments,
    required this.checks,
    required this.path,
  });

  final List<InstallmentItem> installments;
  final List<CheckItem> checks;
  final String path;
}

class BackupService {
  static Future<String> exportData({
    required List<InstallmentItem> installments,
    required List<CheckItem> checks,
  }) async {
    final installmentsWithMedia = await Future.wait(
      installments.map(_installmentWithEmbeddedMedia),
    );
    final checksWithMedia = await Future.wait(
      checks.map(_checkWithEmbeddedMedia),
    );

    final payload = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'installments': installmentsWithMedia,
      'checks': checksWithMedia,
    };
    final encoder = const JsonEncoder.withIndent('  ');
    final content = encoder.convert(payload);
    final bytes = Uint8List.fromList(utf8.encode(content));

    final fileName =
        'bizto_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';

    // 1) Try direct save in Android Downloads.
    final directPath = await _trySaveInAndroidDownloads(fileName, content);
    if (directPath != null) return directPath;

    // 2) Fallback: system save picker (user can choose Downloads manually).
    final pickedPath = await FilePicker.platform.saveFile(
      dialogTitle: 'ذخیره فایل پشتیبان',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['json'],
      bytes: bytes,
    );
    if (pickedPath != null && pickedPath.isNotEmpty) {
      final file = File(pickedPath);
      if (!await file.exists()) {
        await file.create(recursive: true);
        await file.writeAsBytes(bytes, flush: true);
      }
      return pickedPath;
    }

    throw const FileSystemException('export_cancelled_or_failed');
  }

  static Future<BackupImportResult?> importFromPicker() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) return null;

    final selected = picked.files.single;
    final path = selected.path;

    String raw;
    if (selected.bytes != null && selected.bytes!.isNotEmpty) {
      raw = utf8.decode(selected.bytes!, allowMalformed: true);
    } else if (path != null && path.isNotEmpty) {
      raw = await File(path).readAsString();
    } else {
      return null;
    }

    if (raw.isNotEmpty && raw.codeUnitAt(0) == 0xFEFF) {
      raw = raw.substring(1);
    }

    final map = _parseBackupMap(raw);

    final rawInstallments = (map['installments'] as List?) ?? const [];
    final rawChecks = (map['checks'] as List?) ?? const [];

    final installments = await _restoreInstallmentsFromBackup(rawInstallments);
    final checks = await _restoreChecksFromBackup(rawChecks);

    return BackupImportResult(
      installments: installments,
      checks: checks,
      path: (path == null || path.isEmpty)
          ? (selected.name.isEmpty ? 'selected_backup.json' : selected.name)
          : path,
    );
  }

  static Map<String, dynamic> _parseBackupMap(String raw) {
    dynamic decoded = _tryDecode(raw);
    if (decoded is String) {
      decoded = _tryDecode(decoded);
    }
    if (decoded is! Map) {
      throw const FormatException('invalid_backup_format');
    }

    final map = Map<String, dynamic>.from(decoded);
    if (map['data'] is Map) {
      final nested = Map<String, dynamic>.from(map['data'] as Map);
      if ((nested['installments'] is List) || (nested['checks'] is List)) {
        return nested;
      }
    }
    return map;
  }

  static dynamic _tryDecode(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      final trimmed = raw.trim();
      return jsonDecode(trimmed);
    }
  }

  static Future<String?> _trySaveInAndroidDownloads(
    String fileName,
    String content,
  ) async {
    if (!Platform.isAndroid) return null;
    try {
      if (!await _ensureAndroidStoragePermission()) {
        return null;
      }

      final dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) return null;
      final file = File('${dir.path}${Platform.pathSeparator}$fileName');
      await file.create(recursive: true);
      await file.writeAsString(content, flush: true);
      return file.path;
    } catch (_) {}
    return null;
  }

  static Future<bool> _ensureAndroidStoragePermission() async {
    if (!Platform.isAndroid) return true;
    try {
      final storage = await Permission.storage.request();
      if (storage.isGranted) return true;
    } catch (_) {}

    try {
      final manage = await Permission.manageExternalStorage.request();
      if (manage.isGranted) return true;
    } catch (_) {}

    return false;
  }

  static Future<Map<String, dynamic>> _installmentWithEmbeddedMedia(
    InstallmentItem item,
  ) async {
    final json = Map<String, dynamic>.from(item.toJson());
    final receiptFiles = <String, dynamic>{};

    for (final entry in item.installmentReceiptPaths.entries) {
      final media = await _encodeFile(entry.value);
      if (media != null) {
        receiptFiles[entry.key] = media;
      }
    }
    if (receiptFiles.isNotEmpty) {
      json['backupReceiptFiles'] = receiptFiles;
    }
    return json;
  }

  static Future<Map<String, dynamic>> _checkWithEmbeddedMedia(
    CheckItem item,
  ) async {
    final json = Map<String, dynamic>.from(item.toJson());
    if (item.imagePath.trim().isNotEmpty) {
      final media = await _encodeFile(item.imagePath);
      if (media != null) {
        json['backupCheckImage'] = media;
      }
    }
    return json;
  }

  static Future<List<InstallmentItem>> _restoreInstallmentsFromBackup(
    List rawInstallments,
  ) async {
    final mediaDir = await _backupMediaDir();
    final result = <InstallmentItem>[];

    for (final raw in rawInstallments.whereType<Map>()) {
      final map = Map<String, dynamic>.from(raw);
      final receiptFiles = (map['backupReceiptFiles'] is Map)
          ? Map<String, dynamic>.from(map['backupReceiptFiles'] as Map)
          : const <String, dynamic>{};

      final restoredPaths = <String, String>{};
      for (final entry in receiptFiles.entries) {
        final restored = await _decodeToFile(
          payload: entry.value,
          outputDir: mediaDir,
          filePrefix: 'installment_receipt_${map['id'] ?? 'item'}_${entry.key}',
        );
        if (restored != null) {
          restoredPaths[entry.key] = restored;
        }
      }

      map['installmentReceiptPaths'] = restoredPaths;
      map.remove('backupReceiptFiles');
      result.add(InstallmentItem.fromJson(map));
    }
    return result;
  }

  static Future<List<CheckItem>> _restoreChecksFromBackup(List rawChecks) async {
    final mediaDir = await _backupMediaDir();
    final result = <CheckItem>[];

    for (final raw in rawChecks.whereType<Map>()) {
      final map = Map<String, dynamic>.from(raw);
      String restoredImagePath = '';

      if (map['backupCheckImage'] != null) {
        restoredImagePath = await _decodeToFile(
              payload: map['backupCheckImage'],
              outputDir: mediaDir,
              filePrefix: 'check_image_${map['id'] ?? 'item'}',
            ) ??
            '';
      }

      if (restoredImagePath.isNotEmpty) {
        map['imagePath'] = restoredImagePath;
      }
      map.remove('backupCheckImage');
      result.add(CheckItem.fromJson(map));
    }
    return result;
  }

  static Future<Map<String, dynamic>?> _encodeFile(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return null;
      return {
        'ext': _safeExt(path),
        'data': base64Encode(bytes),
      };
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _decodeToFile({
    required dynamic payload,
    required Directory outputDir,
    required String filePrefix,
  }) async {
    try {
      if (payload is! Map) return null;
      final map = Map<String, dynamic>.from(payload);
      final data = map['data']?.toString() ?? '';
      if (data.isEmpty) return null;
      final ext = map['ext']?.toString().trim().replaceAll('.', '') ?? 'jpg';
      final bytes = base64Decode(data);
      if (bytes.isEmpty) return null;

      await outputDir.create(recursive: true);
      final name = '${filePrefix}_${DateTime.now().microsecondsSinceEpoch}.$ext';
      final file = File('${outputDir.path}${Platform.pathSeparator}$name');
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  static String _safeExt(String path) {
    final name = path.split('/').last.split('\\').last;
    final dot = name.lastIndexOf('.');
    if (dot == -1 || dot == name.length - 1) return 'jpg';
    final ext = name.substring(dot + 1).toLowerCase();
    if (ext.length > 6) return 'jpg';
    return ext;
  }

  static Future<Directory> _backupMediaDir() async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      return Directory(
        '${docs.path}${Platform.pathSeparator}backup_media',
      );
    } catch (_) {
      return Directory.systemTemp;
    }
  }
}
