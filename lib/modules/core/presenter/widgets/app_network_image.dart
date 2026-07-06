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
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
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
