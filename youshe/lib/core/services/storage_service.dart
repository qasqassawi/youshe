import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../services/logging_service.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final LoggingService _log = LoggingService();

  Future<String> uploadProductImage(String filePath) async {
    try {
      final file = File(filePath);
      final fileName = 'products/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('\\').last.split('/').last}';
      final ref = _storage.ref().child(fileName);
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      _log.info('Product image uploaded', tag: 'StorageService');
      return url;
    } catch (e) {
      _log.error('Failed to upload product image', tag: 'StorageService', error: e);
      rethrow;
    }
  }

  Future<String> uploadShopImage(String filePath) async {
    try {
      final file = File(filePath);
      final fileName = 'shops/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('\\').last.split('/').last}';
      final ref = _storage.ref().child(fileName);
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      _log.info('Shop image uploaded', tag: 'StorageService');
      return url;
    } catch (e) {
      _log.error('Failed to upload shop image', tag: 'StorageService', error: e);
      rethrow;
    }
  }

  Future<void> deleteImage(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
      _log.info('Image deleted', tag: 'StorageService');
    } catch (e) {
      _log.error('Failed to delete image', tag: 'StorageService', error: e);
    }
  }
}
