import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class MediaService {
  MediaService({required this.companyId});
  final String companyId;
  Directory? _baseDir;
  Future<Directory> _ensureBaseDir() async {
    if (_baseDir != null && _baseDir!.existsSync()) return _baseDir!;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'myfnt_media', companyId));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return _baseDir = dir;
  }
  Future<String> saveFile({required String key, required List<int> bytes, required String extension}) async {
    final dir = await _ensureBaseDir();
    final safeKey = key.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    final file = File(p.join(dir.path, '$safeKey.$extension'));
    await file.writeAsBytes(bytes);
    return file.path;
  }
  Future<List<int>?> readFile(String path) async { final file = File(path); return file.existsSync() ? file.readAsBytes() : null; }
  Future<bool> deleteFile(String path) async { final file = File(path); if (!file.existsSync()) return false; await file.delete(); return true; }
  bool fileExists(String path) => File(path).existsSync();
  Future<int> fileSize(String path) async { final file = File(path); return file.existsSync() ? file.length() : 0; }
  Future<void> clearAll() async { final dir = await _ensureBaseDir(); if (dir.existsSync()) { await dir.delete(recursive: true); _baseDir = null; } }
}
