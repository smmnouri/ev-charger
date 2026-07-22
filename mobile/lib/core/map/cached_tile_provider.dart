import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:path_provider/path_provider.dart';

/// Disk-caching tile provider with ordered URL fallback.
///
/// Tile fetch priority:
///   1. Disk cache ({appCacheDir}/map_tiles/{z}_{x}_{y}.png)
///   2. Each URL in [urlTemplates] in order — first success wins
///
/// Cached tiles persist indefinitely so the map renders offline after
/// the first successful fetch.  Suitable for a physical device in Iran
/// where primary CDNs may vary by ISP; multiple providers increase
/// the chance that at least one succeeds.
class CachedFallbackTileProvider extends TileProvider {
  CachedFallbackTileProvider._({
    required this.urlTemplates,
    required Directory cacheDir,
    required Dio dio,
  })  : _cacheDir = cacheDir,
        _dio = dio;

  final List<String> urlTemplates;
  final Directory _cacheDir;
  final Dio _dio;

  static const _subs = ['a', 'b', 'c'];

  static Future<CachedFallbackTileProvider> create({
    required List<String> urlTemplates,
    required String userAgent,
    String cacheKey = 'default',
  }) async {
    final base = await getApplicationCacheDirectory();
    // Directory name includes provider family AND style key so dark/light tiles
    // never share the same cache slot (same z/x/y coords, different imagery).
    final cacheDir = Directory('${base.path}/map_tiles_$cacheKey');
    await cacheDir.create(recursive: true);
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'User-Agent': userAgent},
    ));
    return CachedFallbackTileProvider._(
      urlTemplates: urlTemplates,
      cacheDir: cacheDir,
      dio: dio,
    );
  }

  String _expand(String template, TileCoordinates c) => template
      .replaceAll('{z}', '${c.z}')
      .replaceAll('{x}', '${c.x}')
      .replaceAll('{y}', '${c.y}')
      .replaceAll('{s}', _subs[c.x % _subs.length]);

  File _cacheFile(TileCoordinates c) =>
      File('${_cacheDir.path}/${c.z}_${c.x}_${c.y}.png');

  @override
  ImageProvider<Object> getImage(
      TileCoordinates coordinates, TileLayer options) {
    return _CachedTileImage(
      cacheFile: _cacheFile(coordinates),
      urls: urlTemplates.map((t) => _expand(t, coordinates)).toList(),
      dio: _dio,
    );
  }

  @override
  void dispose() {
    _dio.close(force: true);
    super.dispose();
  }
}

class _CachedTileImage extends ImageProvider<_CachedTileImage> {
  const _CachedTileImage({
    required this.cacheFile,
    required this.urls,
    required this.dio,
  });

  final File cacheFile;
  final List<String> urls;
  final Dio dio;

  @override
  Future<_CachedTileImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
          _CachedTileImage key, ImageDecoderCallback decode) =>
      MultiFrameImageStreamCompleter(
        codec: _load(decode),
        scale: 1.0,
        debugLabel: cacheFile.path,
      );

  Future<ui.Codec> _load(ImageDecoderCallback decode) async {
    // 1. Disk cache hit
    if (await cacheFile.exists()) {
      try {
        final bytes = await cacheFile.readAsBytes();
        if (bytes.isNotEmpty) {
          return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
        }
      } catch (_) {
        // Corrupted cache entry — delete and re-fetch
        try { await cacheFile.delete(); } catch (_) {}
      }
    }

    // 2. Network fallback chain
    for (final url in urls) {
      try {
        final res = await dio.get<Uint8List>(
          url,
          options: Options(responseType: ResponseType.bytes),
        );
        final data = res.data;
        if (res.statusCode == 200 && data != null && data.length > 256) {
          // Write to disk before decoding so cache is warm on next request
          await cacheFile.writeAsBytes(data, flush: true);
          return decode(await ui.ImmutableBuffer.fromUint8List(data));
        }
      } on DioException catch (e) {
        if (e.type == DioExceptionType.cancel) break;
        continue; // try next provider
      } catch (_) {
        continue;
      }
    }

    // 3. All sources failed — surface as image error so TileLayer shows
    //    its built-in error placeholder rather than a white tile.
    throw Exception('tile unavailable: ${cacheFile.path}');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CachedTileImage && cacheFile.path == other.cacheFile.path;

  @override
  int get hashCode => cacheFile.path.hashCode;
}
