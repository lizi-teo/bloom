import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import '../../services/template_service.dart';

class DecorationTape extends StatefulWidget {
  final String? imageUrl;
  final int? sectionId;
  final int? templateId;
  final double itemSize;
  final double spacing;
  final int itemCount;
  final Function(String)? onImageUrlRetrieved;

  const DecorationTape({
    super.key,
    this.imageUrl,
    this.sectionId,
    this.templateId,
    this.itemSize = 60.0,
    this.spacing = 6.0,
    this.itemCount = 6,
    this.onImageUrlRetrieved,
  }) : assert(
          imageUrl != null || sectionId != null || templateId != null,
          'Either imageUrl, sectionId, or templateId must be provided',
        );

  @override
  State<DecorationTape> createState() => _DecorationTapeState();
}

class _DecorationTapeState extends State<DecorationTape> {
  String? _imageUrl;
  Color _backgroundColor = const Color(0xFFF8E503); // Default yellow from Figma
  bool _isLoading = true;
  bool _hasError = false;
  final TemplateService _templateService = TemplateService();

  @override
  void initState() {
    super.initState();
    _initializeImage();
  }

  @override
  void didUpdateWidget(DecorationTape oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl || oldWidget.sectionId != widget.sectionId || oldWidget.templateId != widget.templateId) {
      _initializeImage();
    }
  }

  Future<void> _initializeImage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Get image URL
      String? url = widget.imageUrl;

      // If no direct URL, fetch from database based on sectionId or templateId
      if (url == null && (widget.sectionId != null || widget.templateId != null)) {
        url = await _fetchImageUrlFromDatabase();
      }

      if (url != null && url.isNotEmpty) {
        _imageUrl = url;
        widget.onImageUrlRetrieved?.call(url);
        await _extractDominantColor(url);
      } else {
        // No image available, use default styling
        _imageUrl = null;
        _backgroundColor = const Color(0xFFF8E503);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error initializing decoration tape: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _backgroundColor = const Color(0xFFF8E503);
      });
    }
  }

  Future<String?> _fetchImageUrlFromDatabase() async {
    // Fetch image URL from database based on sectionId or templateId
    if (widget.templateId != null) {
      return await _templateService.getTemplateImageUrl(widget.templateId!);
    } else if (widget.sectionId != null) {
      // For section ID, we fetch through sessions (sessions are sections in this context)
      return await _templateService.getSessionImageUrl(widget.sectionId!);
    }
    return null;
  }

  Future<void> _extractDominantColor(String imageUrl) async {
    try {
      final ImageProvider imageProvider = NetworkImage(imageUrl);
      final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        size: const Size(100, 100), // Small size for faster processing
        maximumColorCount: 5,
      );

      // Try to get vibrant color first, then dominant, then fallback to default
      Color extractedColor = paletteGenerator.vibrantColor?.color ?? paletteGenerator.dominantColor?.color ?? const Color(0xFFF8E503);

      // Adjust color brightness if needed for better visibility
      final hslColor = HSLColor.fromColor(extractedColor);
      if (hslColor.lightness < 0.5) {
        // If color is too dark, lighten it
        extractedColor = hslColor.withLightness(0.6).toColor();
      } else if (hslColor.lightness > 0.9) {
        // If color is too light, darken it slightly
        extractedColor = hslColor.withLightness(0.8).toColor();
      }

      // Increase saturation for more vibrant appearance
      final adjustedHsl = HSLColor.fromColor(extractedColor);
      if (adjustedHsl.saturation < 0.5) {
        extractedColor = adjustedHsl.withSaturation(0.6).toColor();
      }

      setState(() {
        _backgroundColor = extractedColor;
      });
    } catch (e) {
      debugPrint('Error extracting color from image: $e');
      // Keep default color on error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: widget.itemSize + (4.0 * 2),
        color: _backgroundColor.withValues(alpha: 0.3),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: widget.itemSize + (4.0 * 2),
      color: _backgroundColor,
      padding: EdgeInsets.symmetric(
        vertical: 4.0,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate how many items we need to fill the width
          final itemTotalWidth = widget.itemSize + widget.spacing;
          final itemsNeeded = (constraints.maxWidth / itemTotalWidth).ceil() + 1;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: List.generate(
                itemsNeeded,
                (index) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
                  child: _buildImageItem(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageItem() {
    final hasValidImage = _imageUrl != null && !_hasError;
    
    return Container(
      width: widget.itemSize,
      height: widget.itemSize,
      decoration: BoxDecoration(
        color: _backgroundColor.withValues(alpha: hasValidImage ? 0.8 : 0.6),
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.itemSize / 2),
        child: hasValidImage
            ? Image.network(
                _imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading decoration tape image: $error');
                  setState(() {
                    _hasError = true;
                  });
                  return _buildFallbackIcon();
                },
              )
            : _buildFallbackIcon(),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Icon(
      _hasError ? Icons.image_not_supported : Icons.favorite,
      size: widget.itemSize * 0.5,
      color: _hasError 
          ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)
          : Theme.of(context).colorScheme.primary,
    );
  }
}
