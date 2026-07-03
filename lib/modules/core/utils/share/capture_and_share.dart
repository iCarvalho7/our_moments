import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

/// Renders the widget wrapped by the [RepaintBoundary] identified by [boundaryKey]
/// to a PNG and opens the platform share sheet with it.
///
/// Shared by the moment share card and the "year in review" summary so the
/// capture pipeline lives in one place.
Future<void> captureAndShare(
  GlobalKey boundaryKey, {
  String? text,
  String fileName = 'momento.png',
  double pixelRatio = 3.0,
}) async {
  final boundary =
      boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) return;
  final Uint8List bytes = byteData.buffer.asUint8List();

  await Share.shareXFiles(
    [XFile.fromData(bytes, mimeType: 'image/png', name: fileName)],
    text: text,
  );
}
