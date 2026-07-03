import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/loading_effect.dart';
import 'package:nossos_momentos/modules/core/utils/data_url/data_url.dart';
import 'package:nossos_momentos/modules/core/utils/string_ext/string_ext.dart';

/// Renders a photo url wherever it lives: a remote https URL, a local file path
/// (mobile), or an in-memory data URL (web, where picked files have no path).
/// Always falls back to a neutral box instead of throwing on a bad source.
class StoryImage extends StatelessWidget {
  const StoryImage({super.key, required this.url, this.fit = BoxFit.cover});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final provider = storyImageProvider(url);
    if (provider == null) return _fallback();
    return Image(
      image: provider,
      fit: fit,
      errorBuilder: (_, __, ___) => _fallback(),
      loadingBuilder: (_, child, event) {
        if (event == null) return child;
        return LoadingEffect(
          child: Container(color: Colors.black12),
        );
      },
    );
  }

  Widget _fallback() => Container(color: Colors.black12);
}

/// Resolves the right [ImageProvider] for a photo url across platforms, or null
/// when a web data URL can't be decoded. Shared so widgets that need their own
/// `Image` (e.g. to attach load listeners) stay consistent with [StoryImage].
ImageProvider? storyImageProvider(String url) {
  if (url.startsWith('data:')) {
    final bytes = decodeDataUrl(url);
    return bytes == null ? null : MemoryImage(bytes);
  }
  if (url.isHttpUrl) return NetworkImage(url);
  return FileImage(File(url));
}
