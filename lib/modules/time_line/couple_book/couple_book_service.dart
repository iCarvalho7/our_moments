import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/utils/string_ext/string_ext.dart';
import '../../core/utils/theme/app_theme.dart';
import '../../moment/domain/entities/moment.dart';
import '../domain/entity/time_line.dart';

/// Builds the couple's whole timeline as a shareable PDF "album" and opens the
/// platform share sheet with it.
///
/// This is the ONLY place that imports `pdf`/`printing`; the rest of the app
/// talks to it through [generateAndShare]. Distinct from the single-moment PNG
/// export — this paginates the entire timeline (cover + one section per moment).
@injectable
class CoupleBookService {
  const CoupleBookService();

  /// Max images embedded per moment, to keep the PDF light and avoid running
  /// out of memory while downloading/decoding photos.
  static const int _maxImagesPerMoment = 4;

  /// Brand coral used for headings/accents in the document.
  static const PdfColor _accent = PdfColor.fromInt(0xFFFF6B7A);
  static const PdfColor _ink = PdfColor.fromInt(0xFF2B2330);
  static const PdfColor _muted = PdfColor.fromInt(0xFF8A8290);

  /// Generates the PDF for [timeline] over [moments] (any order) and shares it.
  Future<void> generateAndShare({
    required TimeLine timeline,
    required List<Moment> moments,
  }) async {
    final bytes = await build(timeline: timeline, moments: moments);
    await Printing.sharePdf(bytes: bytes, filename: 'nossos-momentos.pdf');
  }

  /// Builds the document bytes. Moments are sorted by date ascending; each photo
  /// URL is downloaded over HTTP into a [pw.MemoryImage]. Videos and non-image
  /// items are skipped; a failed image download is skipped (never breaks the PDF).
  Future<Uint8List> build({
    required TimeLine timeline,
    required List<Moment> moments,
  }) async {
    final ordered = [...moments]
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final doc = pw.Document(
      title: 'Nossos Momentos',
      author: Strings.appName,
    );

    final coverImage = timeline.coverPhotoUrl.isNotEmpty
        ? await _tryFetchImage(timeline.coverPhotoUrl)
        : null;

    final theme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 40, 36, 48),
      buildBackground: (_) => pw.SizedBox(),
    );

    // Cover page (no footer).
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => _buildCover(timeline, ordered, coverImage),
      ),
    );

    // One multi-page section per moment, with a footer (page number + brand).
    for (final moment in ordered) {
      final images = await _fetchMomentImages(moment);
      doc.addPage(
        pw.MultiPage(
          pageTheme: theme,
          footer: _buildFooter,
          build: (_) => _buildMomentContent(moment, images),
        ),
      );
    }

    return doc.save();
  }

  // --- Page builders -------------------------------------------------------

  pw.Widget _buildCover(
    TimeLine timeline,
    List<Moment> ordered,
    pw.MemoryImage? coverImage,
  ) {
    final title = timeline.name.trim().isNotEmpty
        ? timeline.name.trim()
        : Strings.appName;
    final period = _periodLabel(ordered);

    return pw.Stack(
      children: [
        if (coverImage != null)
          pw.Positioned.fill(
            child: pw.Image(coverImage, fit: pw.BoxFit.cover),
          ),
        // Translucent veil so the title is legible over any cover photo.
        if (coverImage != null)
          pw.Positioned.fill(
            child: pw.Container(
              color: const PdfColor(0, 0, 0, 0.45),
            ),
          ),
        pw.Container(
          padding: const pw.EdgeInsets.all(48),
          alignment: pw.Alignment.bottomLeft,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                'Nosso álbum',
                style: pw.TextStyle(
                  fontSize: 16,
                  color: coverImage != null ? PdfColors.white : _muted,
                  letterSpacing: 2,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 38,
                  fontWeight: pw.FontWeight.bold,
                  color: coverImage != null ? PdfColors.white : _ink,
                ),
              ),
              pw.SizedBox(height: 16),
              if (period.isNotEmpty)
                pw.Text(
                  period,
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: coverImage != null ? PdfColors.white : _muted,
                  ),
                ),
              pw.SizedBox(height: 4),
              pw.Text(
                _momentCountLabel(ordered.length),
                style: pw.TextStyle(
                  fontSize: 14,
                  color: coverImage != null ? PdfColors.white : _muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<pw.Widget> _buildMomentContent(
    Moment moment,
    List<pw.MemoryImage> images,
  ) {
    return [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(width: 4, height: 44, color: _accent),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  moment.dateTimeFormatted,
                  style: pw.TextStyle(fontSize: 11, color: _muted),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  moment.title.isNotEmpty ? moment.title : 'Sem título',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),
          _typeChip(moment),
        ],
      ),
      pw.SizedBox(height: 14),
      if (moment.body.trim().isNotEmpty) ...[
        pw.Text(
          moment.body.trim(),
          style: pw.TextStyle(fontSize: 12, color: _ink, lineSpacing: 3),
        ),
        pw.SizedBox(height: 16),
      ],
      ..._buildImageGrid(images),
    ];
  }

  List<pw.Widget> _buildImageGrid(List<pw.MemoryImage> images) {
    if (images.isEmpty) return [];

    final rows = <pw.Widget>[];
    for (var i = 0; i < images.length; i += 2) {
      final left = images[i];
      final right = i + 1 < images.length ? images[i + 1] : null;
      rows.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(child: _photo(left)),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: right != null ? _photo(right) : pw.SizedBox(),
              ),
            ],
          ),
        ),
      );
    }
    return rows;
  }

  pw.Widget _photo(pw.MemoryImage image) {
    return pw.ClipRRect(
      horizontalRadius: 10,
      verticalRadius: 10,
      child: pw.Container(
        height: 200,
        child: pw.Image(image, fit: pw.BoxFit.cover),
      ),
    );
  }

  pw.Widget _typeChip(Moment moment) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFFFE9EC),
        borderRadius: pw.BorderRadius.circular(999),
      ),
      child: pw.Text(
        moment.type.label,
        style: pw.TextStyle(
          fontSize: 10,
          color: _accent,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(top: 12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            Strings.appName,
            style: pw.TextStyle(fontSize: 9, color: _muted),
          ),
          pw.Text(
            '${context.pageNumber} / ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 9, color: _muted),
          ),
        ],
      ),
    );
  }

  // --- Helpers -------------------------------------------------------------

  /// Period covered, smallest → largest moment date.
  String _periodLabel(List<Moment> ordered) {
    if (ordered.isEmpty) return '';
    final format = DateFormat('MMMM yyyy', 'pt_BR');
    final first = format.format(ordered.first.dateTime);
    final last = format.format(ordered.last.dateTime);
    return first == last ? first : '$first — $last';
  }

  String _momentCountLabel(int total) {
    return total == 1 ? '1 momento' : '$total momentos';
  }

  /// Downloads up to [_maxImagesPerMoment] photos for [moment], skipping videos
  /// and any URL that fails to download.
  Future<List<pw.MemoryImage>> _fetchMomentImages(Moment moment) async {
    final urls = moment.downloadUrlList
        .where((url) => url.isHttpUrl && url.isImage && !url.isVideo)
        .take(_maxImagesPerMoment)
        .toList();

    final images = <pw.MemoryImage>[];
    for (final url in urls) {
      final image = await _tryFetchImage(url);
      if (image != null) images.add(image);
    }
    return images;
  }

  /// Fetches a single image URL into a [pw.MemoryImage], returning null on any
  /// failure (network error, non-200, empty body) so it can be skipped.
  Future<pw.MemoryImage?> _tryFetchImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        return null;
      }
      return pw.MemoryImage(response.bodyBytes);
    } catch (_) {
      return null;
    }
  }
}
