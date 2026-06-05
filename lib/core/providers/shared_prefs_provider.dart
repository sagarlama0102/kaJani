import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kajani/core/services/storage/storage_service.dart';

/// Must be overridden in main.dart before runApp()
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('storageServiceProvider must be overriden');
});
