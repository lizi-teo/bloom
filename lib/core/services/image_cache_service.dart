import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web/web.dart' as web;

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  final Map<String, CachedImage> _memoryCache = {};
  final Map<String, Future<CachedImage?>> _pendingRequests = {};
  
  int _maxMemoryCacheSize = 100;
  int _maxCacheAgeMinutes = 60;
  bool _enableMemoryCache = true;
  bool _enableDiskCache = true;

  void configure({
    int? maxMemoryCacheSize,
    int? maxCacheAgeMinutes,
    bool? enableMemoryCache,
    bool? enableDiskCache,
  }) {
    _maxMemoryCacheSize = maxMemoryCacheSize ?? _maxMemoryCacheSize;
    _maxCacheAgeMinutes = maxCacheAgeMinutes ?? _maxCacheAgeMinutes;
    _enableMemoryCache = enableMemoryCache ?? _enableMemoryCache;
    _enableDiskCache = enableDiskCache ?? _enableDiskCache;
  }

  Future<CachedImage?> getImage(String url, {
    Size? targetSize,
    BoxFit? fit,
    bool forceRefresh = false,
  }) async {
    if (url.isEmpty) return null;

    final cacheKey = _generateCacheKey(url, targetSize);
    
    // Check memory cache first
    if (_enableMemoryCache && !forceRefresh) {
      final cachedImage = _getFromMemoryCache(cacheKey);
      if (cachedImage != null) {
        return cachedImage;
      }
    }

    // Check if request is already in progress
    if (_pendingRequests.containsKey(cacheKey)) {
      return await _pendingRequests[cacheKey];
    }

    // Start new request
    final future = _loadImage(url, cacheKey, targetSize, fit);
    _pendingRequests[cacheKey] = future;
    
    try {
      final result = await future;
      _pendingRequests.remove(cacheKey);
      return result;
    } catch (e) {
      _pendingRequests.remove(cacheKey);
      debugPrint('Failed to load image: $url, error: $e');
      return null;
    }
  }

  Future<CachedImage?> _loadImage(
    String url,
    String cacheKey,
    Size? targetSize,
    BoxFit? fit,
  ) async {
    try {
      // Try to load from disk cache first
      if (_enableDiskCache) {
        final diskCached = await _loadFromDiskCache(cacheKey);
        if (diskCached != null) {
          if (_enableMemoryCache) {
            _addToMemoryCache(cacheKey, diskCached);
          }
          return diskCached;
        }
      }

      // Load from network
      final networkImage = await _loadFromNetwork(url, targetSize, fit);
      if (networkImage != null) {
        // Cache the result
        if (_enableMemoryCache) {
          _addToMemoryCache(cacheKey, networkImage);
        }
        if (_enableDiskCache) {
          _saveToDiskCache(cacheKey, networkImage);
        }
      }
      
      return networkImage;
    } catch (e) {
      debugPrint('Error loading image $url: $e');
      return null;
    }
  }

  Future<CachedImage?> _loadFromNetwork(
    String url,
    Size? targetSize,
    BoxFit? fit,
  ) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        return null;
      }

      final bytes = response.bodyBytes;
      var imageProvider = MemoryImage(bytes);
      
      // Decode and possibly resize image
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: targetSize?.width.toInt(),
        targetHeight: targetSize?.height.toInt(),
      );
      
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      return CachedImage(
        url: url,
        imageProvider: imageProvider,
        image: image,
        bytes: bytes,
        cachedAt: DateTime.now(),
        size: Size(image.width.toDouble(), image.height.toDouble()),
      );
    } catch (e) {
      debugPrint('Network loading failed for $url: $e');
      return null;
    }
  }

  CachedImage? _getFromMemoryCache(String cacheKey) {
    final cached = _memoryCache[cacheKey];
    if (cached == null) return null;
    
    // Check if expired
    final age = DateTime.now().difference(cached.cachedAt).inMinutes;
    if (age > _maxCacheAgeMinutes) {
      _memoryCache.remove(cacheKey);
      return null;
    }
    
    return cached;
  }

  void _addToMemoryCache(String cacheKey, CachedImage image) {
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      _evictOldestFromMemoryCache();
    }
    _memoryCache[cacheKey] = image;
  }

  void _evictOldestFromMemoryCache() {
    if (_memoryCache.isEmpty) return;
    
    var oldestKey = _memoryCache.keys.first;
    var oldestTime = _memoryCache[oldestKey]!.cachedAt;
    
    for (final entry in _memoryCache.entries) {
      if (entry.value.cachedAt.isBefore(oldestTime)) {
        oldestKey = entry.key;
        oldestTime = entry.value.cachedAt;
      }
    }
    
    _memoryCache.remove(oldestKey);
  }

  Future<CachedImage?> _loadFromDiskCache(String cacheKey) async {
    try {
      final storage = web.window.localStorage;
      final cachedData = storage.getItem(cacheKey);
      
      if (cachedData == null) return null;
      
      final parts = cachedData.split('|');
      if (parts.length < 3) return null;
      
      final timestamp = int.tryParse(parts[0]);
      final url = parts[1];
      final base64Data = parts[2];
      
      if (timestamp == null) return null;
      
      final cachedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final age = DateTime.now().difference(cachedAt).inMinutes;
      
      if (age > _maxCacheAgeMinutes) {
        storage.removeItem(cacheKey);
        return null;
      }
      
      // Decode base64 data
      final bytes = _base64ToUint8List(base64Data);
      final imageProvider = MemoryImage(bytes);
      
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      return CachedImage(
        url: url,
        imageProvider: imageProvider,
        image: image,
        bytes: bytes,
        cachedAt: cachedAt,
        size: Size(image.width.toDouble(), image.height.toDouble()),
      );
    } catch (e) {
      debugPrint('Disk cache load failed for $cacheKey: $e');
      return null;
    }
  }

  void _saveToDiskCache(String cacheKey, CachedImage image) {
    try {
      final storage = web.window.localStorage;
      final base64Data = _uint8ListToBase64(image.bytes);
      final cachedData = '${image.cachedAt.millisecondsSinceEpoch}|${image.url}|$base64Data';
      
      storage.setItem(cacheKey, cachedData);
    } catch (e) {
      debugPrint('Failed to save to disk cache: $e');
    }
  }

  String _generateCacheKey(String url, Size? targetSize) {
    var key = url.hashCode.toString();
    if (targetSize != null) {
      key += '_${targetSize.width.toInt()}x${targetSize.height.toInt()}';
    }
    return key;
  }

  String _uint8ListToBase64(Uint8List data) {
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final result = StringBuffer();
    
    for (int i = 0; i < data.length; i += 3) {
      final byte1 = data[i];
      final byte2 = i + 1 < data.length ? data[i + 1] : 0;
      final byte3 = i + 2 < data.length ? data[i + 2] : 0;
      
      final triplet = (byte1 << 16) | (byte2 << 8) | byte3;
      
      result.write(chars[(triplet >> 18) & 63]);
      result.write(chars[(triplet >> 12) & 63]);
      result.write(i + 1 < data.length ? chars[(triplet >> 6) & 63] : '=');
      result.write(i + 2 < data.length ? chars[triplet & 63] : '=');
    }
    
    return result.toString();
  }

  Uint8List _base64ToUint8List(String base64) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final cleanBase64 = base64.replaceAll(RegExp(r'[^A-Za-z0-9+/]'), '');
    
    final result = <int>[];
    
    for (int i = 0; i < cleanBase64.length; i += 4) {
      final char1 = chars.indexOf(cleanBase64[i]);
      final char2 = i + 1 < cleanBase64.length ? chars.indexOf(cleanBase64[i + 1]) : 0;
      final char3 = i + 2 < cleanBase64.length ? chars.indexOf(cleanBase64[i + 2]) : 0;
      final char4 = i + 3 < cleanBase64.length ? chars.indexOf(cleanBase64[i + 3]) : 0;
      
      final triplet = (char1 << 18) | (char2 << 12) | (char3 << 6) | char4;
      
      result.add((triplet >> 16) & 255);
      if (i + 2 < cleanBase64.length) result.add((triplet >> 8) & 255);
      if (i + 3 < cleanBase64.length) result.add(triplet & 255);
    }
    
    return Uint8List.fromList(result);
  }

  void preloadImage(String url, {Size? targetSize}) {
    getImage(url, targetSize: targetSize);
  }

  void preloadImages(List<String> urls, {Size? targetSize}) {
    for (final url in urls) {
      preloadImage(url, targetSize: targetSize);
    }
  }

  void clearCache() {
    _memoryCache.clear();
    try {
      final storage = web.window.localStorage;
      final keysToRemove = <String>[];
      
      for (int i = 0; i < storage.length; i++) {
        final key = storage.key(i);
        if (key != null && key.contains('_image_cache_')) {
          keysToRemove.add(key);
        }
      }
      
      for (final key in keysToRemove) {
        storage.removeItem(key);
      }
    } catch (e) {
      debugPrint('Failed to clear disk cache: $e');
    }
  }

  void clearMemoryCache() {
    _memoryCache.clear();
  }

  CacheStats getStats() {
    final memoryItems = _memoryCache.length;
    final memorySize = _memoryCache.values.fold<int>(
      0,
      (sum, image) => sum + image.bytes.length,
    );
    
    return CacheStats(
      memoryItems: memoryItems,
      memorySizeBytes: memorySize,
      maxMemoryItems: _maxMemoryCacheSize,
      cacheHitRate: 0.0, // Would need to track hits/misses to calculate this
    );
  }
}

class CachedImage {
  final String url;
  final ImageProvider imageProvider;
  final ui.Image image;
  final Uint8List bytes;
  final DateTime cachedAt;
  final Size size;

  CachedImage({
    required this.url,
    required this.imageProvider,
    required this.image,
    required this.bytes,
    required this.cachedAt,
    required this.size,
  });
}

class CacheStats {
  final int memoryItems;
  final int memorySizeBytes;
  final int maxMemoryItems;
  final double cacheHitRate;

  CacheStats({
    required this.memoryItems,
    required this.memorySizeBytes,
    required this.maxMemoryItems,
    required this.cacheHitRate,
  });

  String get memorySizeFormatted {
    final kb = memorySizeBytes / 1024;
    final mb = kb / 1024;
    
    if (mb >= 1) {
      return '${mb.toStringAsFixed(1)} MB';
    } else {
      return '${kb.toStringAsFixed(1)} KB';
    }
  }
}

class CachedNetworkImage extends StatefulWidget {
  final String imageUrl;
  final Size? targetSize;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableCache;
  final Duration fadeInDuration;

  const CachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.targetSize,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.enableCache = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
  });

  @override
  State<CachedNetworkImage> createState() => _CachedNetworkImageState();
}

class _CachedNetworkImageState extends State<CachedNetworkImage> {
  CachedImage? _cachedImage;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CachedNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
      _cachedImage = null;
    });

    try {
      final cachedImage = await ImageCacheService().getImage(
        widget.imageUrl,
        targetSize: widget.targetSize,
        fit: widget.fit,
      );

      if (mounted) {
        setState(() {
          _cachedImage = cachedImage;
          _isLoading = false;
          _hasError = cachedImage == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder ?? 
             const Center(child: CircularProgressIndicator());
    }

    if (_hasError || _cachedImage == null) {
      return widget.errorWidget ?? 
             const Center(
               child: Icon(Icons.error, color: Colors.red),
             );
    }

    return AnimatedSwitcher(
      duration: widget.fadeInDuration,
      child: Image(
        image: _cachedImage!.imageProvider,
        fit: widget.fit,
        key: ValueKey(_cachedImage!.url),
      ),
    );
  }
}