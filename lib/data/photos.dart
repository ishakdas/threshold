import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../core/day_mode.dart';
import '../platform/native_bridge.dart';

/// "Kilitledim mi?" fotoğrafları: uygulamanın kendi klasöründe, yalnızca
/// telefonda. Kayıtta (CheckSession.photos) yalnızca dosya adı tutulur.
final photosDirProvider = FutureProvider<Directory?>((ref) async {
  final path = await ref.watch(nativeBridgeProvider).photosDir();
  if (path == null) return null;
  return Directory(path)..createSync(recursive: true);
});

/// Fotoğraflar bu kadar gün saklanır.
const keepPhotoDays = 14;

/// Kamerayı açar, çekilen fotoğrafı [dir]'e kaydeder; adını döner.
/// Vazgeçilirse null.
Future<String?> takeCheckPhoto(
  Directory dir,
  DateTime day,
  DayMode mode,
  String itemId,
) async {
  final shot = await ImagePicker().pickImage(
    source: ImageSource.camera,
    maxWidth: 1280,
    imageQuality: 70,
  );
  if (shot == null) return null;
  final name = '${dayKey(day)}_${mode.name}_$itemId.jpg';
  await File(shot.path).copy('${dir.path}/$name');
  try {
    await File(shot.path).delete();
  } on Object catch (_) {}
  return name;
}

/// [keepPhotoDays] günden eski fotoğrafları siler.
Future<void> cleanOldPhotos(Directory dir, DateTime today) async {
  final oldest = today.subtract(const Duration(days: keepPhotoDays));
  try {
    await for (final f in dir.list()) {
      final name = f.uri.pathSegments.last;
      final day = parseDayKey(name.split('_').first);
      if (day != null && day.isBefore(oldest)) await f.delete();
    }
  } on Object catch (e) {
    debugPrint('cleanOldPhotos: $e');
  }
}
