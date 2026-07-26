import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/loading_effect.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';

/// Standard remote image with shimmer-while-loading, disk-level caching, and
/// a broken-image icon on error. Pass [errorWidget] to override the default.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorWidget,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    // Decode images at (roughly) the size they're displayed instead of at full
    // resolution — a 3000px photo shown in a 240px card otherwise decodes several
    // MB into memory. When a dimension is unbounded (e.g. a full-width carousel),
    // fall back to the screen width so we still cap the decode. Only the in-memory
    // decode is sized: `maxWidthDiskCache` re-encodes/rewrites the cached file and
    // is prone to a PathNotFoundException race, so the disk cache is left intact.
    final screenWidth = MediaQuery.sizeOf(context).width;
    int? decodeSize(double? logical, double fallback) {
      final resolved = (logical != null && logical.isFinite) ? logical : fallback;
      return (resolved * dpr).round();
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: decodeSize(width, screenWidth),
      placeholder: (_, __) => LoadingEffect(
        child: Container(
          width: width,
          height: height,
          color: palette.surfaceAlt,
        ),
      ),
      errorWidget: (_, __, ___) =>
          errorWidget ??
          Container(
            width: width,
            height: height,
            color: palette.surfaceAlt,
            alignment: Alignment.center,
            child: Icon(
              Icons.image_not_supported_outlined,
              color: palette.onSurfaceMuted,
              size: 24,
            ),
          ),
    );
  }
}
