import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();
  final _uuid = const Uuid();

  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    final picked = await _picker.pickImage(
        source: source, maxWidth: 1080, imageQuality: 80);
    if (picked == null) return null;
    return File(picked.path);
  }

  Future<List<File>> pickMultipleImages() async {
    final picked = await _picker.pickMultiImage(
        maxWidth: 1080, imageQuality: 80);
    return picked.map((e) => File(e.path)).toList();
  }

  Future<String> uploadFile(File file, String folder) async {
    final ext = file.path.split('.').last;
    final name = '${_uuid.v4()}.$ext';
    final ref = _storage.ref('$folder/$name');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<List<String>> uploadMultiple(List<File> files, String folder) async {
    final urls = <String>[];
    for (final file in files) {
      final url = await uploadFile(file, folder);
      urls.add(url);
    }
    return urls;
  }

  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }
}