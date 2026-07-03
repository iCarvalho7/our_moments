extension StringExt on String {
  bool get isHttpUrl => contains('http');

  // Extracts only the file extension from the path, ignoring query parameters
  // and URL tokens, to avoid false positives from random substrings in tokens.
  String get _fileExtension {
    final pathOnly = contains('?') ? substring(0, indexOf('?')) : this;
    final lastDot = pathOnly.lastIndexOf('.');
    final lastSlash = pathOnly.lastIndexOf('/');
    if (lastDot < 0 || lastDot < lastSlash) return '';
    return pathOnly.substring(lastDot + 1).toLowerCase();
  }

  // For data URLs, trust the declared mime type — scanning the base64 payload
  // for extension substrings would misclassify (e.g. random "mp4" bytes).
  bool get isImage =>
      startsWith('data:') ? startsWith('data:image/') : kImageExt.contains(_fileExtension);

  bool get isVideo =>
      startsWith('data:') ? startsWith('data:video/') : kVideoExt.contains(_fileExtension);

  bool get isEmail => RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(this);
}

const kImageExt = {
  "ase", "art", "bmp", "blp", "cd5", "cit", "cpt", "cr2", "cut", "dds",
  "dib", "djvu", "egt", "exif", "gif", "gpl", "grf", "icns", "ico", "iff",
  "jng", "jpeg", "jpg", "jfif", "jp2", "jps", "lbm", "max", "miff", "mng",
  "msp", "nef", "nitf", "ota", "pbm", "pc1", "pc2", "pc3", "pcf", "pcx",
  "pdn", "pgm", "PI1", "PI2", "PI3", "pict", "pct", "pnm", "pns", "ppm",
  "psb", "psd", "pdd", "psp", "px", "pxm", "pxr", "qfx", "raw", "rle",
  "sct", "sgi", "rgb", "int", "bw", "tga", "tiff", "tif", "vtf", "xbm",
  "xcf", "xpm", "3dv", "amf", "ai", "awg", "cgm", "cdr", "cmx", "dxf",
  "e2d", "eps", "fs", "gbr", "odg", "svg", "stl", "vrml", "x3d", "sxd",
  "v2d", "vnd", "wmf", "emf", "xar", "png", "webp", "jxr", "hdp", "wdp",
  "cur", "ecw", "liff", "nrrd", "pam", "pgf", "rgba", "inta", "sid", "ras",
  "sun", "heic", "heif",
};

const kVideoExt = {
  'webm', 'mkv', 'flv', 'vob', 'ogv', 'ogg', 'rrc', 'gifv', 'mng', 'mov',
  'avi',  'qt',  'wmv', 'yuv', 'rm',  'asf', 'amv', 'mp4', 'm4p', 'm4v',
  'mpg',  'mp2', 'mpeg','mpe', 'mpv', 'svi', '3gp', '3g2', 'mxf', 'roq',
  'nsv',  'f4v', 'f4p', 'f4a', 'f4b', 'mod',
};
