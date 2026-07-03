import 'dart:convert';
import 'dart:typed_data';

/// Helpers for `data:` URLs — the self-contained `data:<mime>;base64,<payload>`
/// strings used to carry picked media on web, where there is no file system and
/// thus no file path. The rest of the photo pipeline already keys local-vs-remote
/// off the URL string, so embedding bytes as a data URL lets web reuse it.

/// Decodes the bytes of a base64 data URL, or null if it isn't one / is invalid.
Uint8List? decodeDataUrl(String value) {
  final comma = value.indexOf(',');
  if (!value.startsWith('data:') || comma == -1) return null;
  try {
    return base64Decode(value.substring(comma + 1));
  } catch (_) {
    return null;
  }
}

/// The mime type declared in a data URL (e.g. `image/jpeg`), or '' if absent.
String dataUrlMime(String value) {
  if (!value.startsWith('data:')) return '';
  final semicolon = value.indexOf(';');
  final comma = value.indexOf(',');
  final end = semicolon == -1 ? comma : semicolon;
  if (end <= 5) return '';
  return value.substring(5, end);
}

/// A file extension (with leading dot) for a data URL's mime, defaulting to
/// `.jpg` for images and `.mp4` for unknown video types.
String dataUrlExtension(String value) {
  switch (dataUrlMime(value)) {
    case 'image/jpeg':
      return '.jpg';
    case 'image/png':
      return '.png';
    case 'image/gif':
      return '.gif';
    case 'image/webp':
      return '.webp';
    case 'image/heic':
      return '.heic';
    case 'image/bmp':
      return '.bmp';
    case 'video/mp4':
      return '.mp4';
    case 'video/quicktime':
      return '.mov';
    case 'video/webm':
      return '.webm';
    default:
      return dataUrlMime(value).startsWith('video/') ? '.mp4' : '.jpg';
  }
}
