/// Port for caching thumbnail images locally so the app works offline.
abstract class ThumbnailCache {
  /// Downloads [url] (if needed) and stores it locally.
  ///
  /// Returns the local file path, or `null` if caching failed.
  Future<String?> cache(String? url);

  /// Returns the locally cached file path for [url], or `null` if not cached.
  Future<String?> resolve(String? url);
}
