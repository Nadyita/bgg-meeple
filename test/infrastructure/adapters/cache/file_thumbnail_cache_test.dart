import 'dart:io';

import 'package:bgg_meeple/infrastructure/adapters/cache/file_thumbnail_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  final Directory tempDir;

  _FakePathProvider(this.tempDir);

  @override
  Future<String?> getTemporaryPath() async => tempDir.path;
}

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  group('FileThumbnailCache', () {
    late Directory tempDir;
    late http.Client client;
    late FileThumbnailCache cache;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('thumbnail_test_');
      client = _MockHttpClient();
      PathProviderPlatform.instance = _FakePathProvider(tempDir);
      cache = FileThumbnailCache(httpClient: client);
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('returns null for null or empty url', () async {
      expect(await cache.cache(null), isNull);
      expect(await cache.cache(''), isNull);
    });

    test('downloads and caches image on first call', () async {
      const url = 'https://example.com/thumb.png';
      when(
        () => client.get(Uri.parse(url)),
      ).thenAnswer((_) async => http.Response('image-bytes', 200));

      final path = await cache.cache(url);

      expect(path, isNotNull);
      final file = File(path!);
      expect(file.existsSync(), isTrue);
      expect(file.readAsBytesSync(), 'image-bytes'.codeUnits);
      verify(() => client.get(Uri.parse(url))).called(1);
    });

    test('returns existing file without downloading again', () async {
      const url = 'https://example.com/thumb.png';
      when(
        () => client.get(Uri.parse(url)),
      ).thenAnswer((_) async => http.Response('image-bytes', 200));

      final first = await cache.cache(url);
      final second = await cache.cache(url);

      expect(first, second);
      verify(() => client.get(Uri.parse(url))).called(1);
    });

    test('returns null when download fails', () async {
      const url = 'https://example.com/thumb.png';
      when(
        () => client.get(Uri.parse(url)),
      ).thenAnswer((_) async => http.Response('not found', 404));

      final path = await cache.cache(url);

      expect(path, isNull);
    });

    test('resolve returns existing local path', () async {
      const url = 'https://example.com/thumb.png';
      when(
        () => client.get(Uri.parse(url)),
      ).thenAnswer((_) async => http.Response('image-bytes', 200));

      final cached = await cache.cache(url);
      final resolved = await cache.resolve(url);

      expect(resolved, cached);
    });

    test('resolve returns null when file is missing', () async {
      final resolved = await cache.resolve('https://example.com/missing.png');
      expect(resolved, isNull);
    });

    test('uses file extension from url', () async {
      const url = 'https://example.com/thumb.jpg';
      when(
        () => client.get(Uri.parse(url)),
      ).thenAnswer((_) async => http.Response('image-bytes', 200));

      final path = await cache.cache(url);

      expect(p.extension(path!), '.jpg');
    });
  });
}
