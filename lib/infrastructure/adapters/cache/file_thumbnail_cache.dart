import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../domain/ports/thumbnail_cache.dart';

/// File-system based thumbnail cache.
///
/// Stores downloaded thumbnails in the app's temporary directory so they
/// survive restarts and remain available offline.
class FileThumbnailCache implements ThumbnailCache {
  FileThumbnailCache({http.Client? httpClient})
    : _client = httpClient ?? http.Client();

  final http.Client _client;

  @override
  Future<String?> cache(String? url) async {
    if (url == null || url.isEmpty) {
      return null;
    }

    final localPath = await _localPathFor(url);
    final file = File(localPath);
    if (await file.exists()) {
      return localPath;
    }

    try {
      final response = await _client.get(Uri.parse(url));
      if (response.statusCode != 200) {
        return null;
      }
      await file.create(recursive: true);
      await file.writeAsBytes(response.bodyBytes);
      return localPath;
    } on Exception {
      return null;
    }
  }

  @override
  Future<String?> resolve(String? url) async {
    if (url == null || url.isEmpty) {
      return null;
    }

    final localPath = await _localPathFor(url);
    final file = File(localPath);
    return await file.exists() ? localPath : null;
  }

  Future<String> _localPathFor(String url) async {
    final directory = await getTemporaryDirectory();
    final hash = url.hashCode.toRadixString(16);
    final extension = p.extension(Uri.parse(url).path);
    return p.join(directory.path, 'thumbnails', '$hash$extension');
  }
}
