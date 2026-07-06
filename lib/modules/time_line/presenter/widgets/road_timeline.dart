import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/app_network_image.dart';
import 'package:nossos_momentos/modules/moment/domain/entities/moment.dart';

/// Timeline rendered as a fixed 3-D perspective road.
///
/// The curved road background is painted once and never scrolls.
/// Only pins, labels and the floating card scroll on top.
/// Slot heights are measured per-moment via TextPainter so longer titles
/// never overlap the following pin.
class RoadTimeline extends StatefulWidget {
  const RoadTimeline({
    super.key,
    required this.moments,
    this.timelineColors = const {},
    this.timelineNames = const {},
    this.onMomentTap,
  });

  final List<Moment> moments;

  /// Accent colour per timeline ID; falls back to MomentType colour.
  final Map<String, Color> timelineColors;

  /// Display name per timeline ID (shown beneath each moment title).
  final Map<String, String> timelineNames;

  /// Called when a pin is first opened.
  final void Function(Moment)? onMomentTap;

  @override
  State<RoadTimeline> createState() => _RoadTimelineState();
}

// ─────────────────────────────────────────────────────────────────────────────

class _RoadTimelineState extends State<RoadTimeline> {
  int? _selectedIndex;
  double _scrollOffset = 0;
  final _scrollCtrl = ScrollController();

  static const double _pinW = 46.0;
  static const double _pinH = 56.0;

  // Label: slim container — no card appearance
  static const double _labelW = 120.0;
  static const double _labelPadV = 4.0;
  static const double _labelPadH = 7.0;

  static const double _cardW = 230.0;
  static const double _arrowH = 9.0;
  static const double _arrowW = 16.0;

  static const _cols = [0.12, 0.30, 0.50, 0.70, 0.88];

  double _pinFraction(int i) => _cols[i % _cols.length];

  // ── Cached per-slot layout ───────────────────────────────────────────────
  List<double>? _slotH;
  List<double>? _slotCY;
  List<double>? _labelH;
  List<_YearMarker>? _yearMarkers;
  double _totalH = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() => setState(() => _scrollOffset = _scrollCtrl.offset);

  @override
  void didUpdateWidget(RoadTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.moments, widget.moments) || !identical(oldWidget.timelineNames, widget.timelineNames)) {
      _slotH = _slotCY = _labelH = null;
      _yearMarkers = null;
      _totalH = 0;
    }
  }

  @override
  void dispose() {
    _scrollCtrl
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  // ── Layout measurement ────────────────────────────────────────────────────

  void _buildLayout(List<Moment> moments, TextTheme theme) {
    if (_slotH != null) return;

    _slotH = [];
    _slotCY = [];
    _labelH = [];
    _yearMarkers = [];
    double cumY = 0;

    const textW = _labelW - _labelPadH * 2;
    const markerH = 48.0;
    const markerPad = 10.0;

    for (var i = 0; i < moments.length; i++) {
      final m = moments[i];
      final year = m.dateTime.year;

      // Insert a year divider at the first moment and at every year transition
      if (i == 0 || moments[i - 1].dateTime.year != year) {
        cumY += markerPad;
        _yearMarkers!.add(_YearMarker(year, cumY + markerH / 2));
        cumY += markerH + markerPad;
      }

      final tn = widget.timelineNames[m.timelineId] ?? '';
      final sub = tn.isNotEmpty ? '$tn • ${m.dateTimeFormatted}' : m.dateTimeFormatted;

      final h1 = _measure(m.title, _titleStyle(theme), 3, textW);
      final h2 = _measure(sub, _subStyle(theme), 2, textW);

      final lblH = h1 + 4 + h2 + _labelPadV * 2;
      final sh = math.max(115.0, math.max(lblH, _pinH) + 44.0);

      _slotH!.add(sh);
      _slotCY!.add(cumY + sh / 2);
      _labelH!.add(lblH);
      cumY += sh;
    }

    _totalH = cumY;
  }

  double _measure(String text, TextStyle style, int maxLines, double maxW) => (TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: maxLines,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxW)).height;

  // ── Text styles (shared by measurement + rendering) ──────────────────────

  static TextStyle _titleStyle(TextTheme t) => (t.bodySmall ?? const TextStyle()).copyWith(
    color: const Color(0xFF1C1C1C),
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    height: 1.28,
    letterSpacing: 0.05,
  );

  static TextStyle _subStyle(TextTheme t) => (t.labelSmall ?? const TextStyle()).copyWith(
    color: const Color(0xFF606060),
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    height: 1.28,
    letterSpacing: 0.1,
  );

  // ── Road geometry ─────────────────────────────────────────────────────────
  //
  //  Same S-curve style as the original bezier, but wider top so the road
  //  no longer narrows to a cone.
  //
  //    top  0.25w … 0.75w  (50 %)          ← was 0.38 … 0.62 (24 %)
  //    cp1  0.18w … 0.82w  at y = 0.25h
  //    cp2  0.13w … 0.87w  at y = 0.58h
  //    bot  0.07w … 0.93w  (86 %)
  //
  //  Control-point interpolation:
  //    topX(f) = w * (0.25 + f * 0.50)
  //    cp1X(f) = w * (0.18 + f * 0.64)
  //    cp2X(f) = w * (0.13 + f * 0.74)
  //    botX(f) = w * (0.07 + f * 0.86)

  double _roadXAt(double vy, double f, double w, double h) {
    final y = vy.clamp(0.0, h);
    final topX = w * (0.25 + f * 0.50);
    final cp1X = w * (0.18 + f * 0.64); // at y = 0.25h
    final cp2X = w * (0.13 + f * 0.74); // at y = 0.58h
    final botX = w * (0.07 + f * 0.86);

    if (y <= h * 0.25) {
      return topX + (cp1X - topX) * (y / (h * 0.25));
    } else if (y <= h * 0.58) {
      return cp1X + (cp2X - cp1X) * ((y - h * 0.25) / (h * 0.33));
    } else {
      return cp2X + (botX - cp2X) * ((y - h * 0.58) / (h * 0.42));
    }
  }

  double _perspScale(double vy, double sH) => 0.75 + (vy / sH).clamp(0.0, 1.0) * 0.35;

  List<Moment> get _sorted {
    final list = [...widget.moments];
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final moments = _sorted;

    _buildLayout(moments, theme);

    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final contentH = math.max(screenH, _totalH + 40.0);

    final stack = <Widget>[];

    // ── Year dividers (below pins in z-order) ─────────────────────────────
    for (final marker in _yearMarkers!) {
      stack.add(
        Positioned(
          left: 0,
          top: marker.contentY - 24,
          width: screenW,
          child: _YearDivider(year: marker.year),
        ),
      );
    }

    for (var i = 0; i < moments.length; i++) {
      final m = moments[i];
      final pinColor = widget.timelineColors[m.timelineId] ?? m.type.colors(context).bg;
      final tn = widget.timelineNames[m.timelineId] ?? '';
      final isSelected = _selectedIndex == i;

      final cy = _slotCY![i];
      final vy = cy - _scrollOffset;
      final cvY = vy.clamp(0.0, screenH);
      final fraction = _pinFraction(i);
      final pinCx = _roadXAt(cvY, fraction, screenW, screenH);
      final pinLeft = pinCx - _pinW / 2;
      final pinTop = cy - _pinH / 2;
      final pScale = _perspScale(cvY, screenH);

      // ── Label ─────────────────────────────────────────────────────────
      final dOnLeft = fraction > 0.50;
      final lLeft = dOnLeft
          ? (pinLeft - _labelW - 6).clamp(4.0, screenW - _labelW - 4.0)
          : (pinLeft + _pinW + 6).clamp(4.0, screenW - _labelW - 4.0);
      final lTop = (cy - _labelH![i] / 2).clamp(4.0, contentH - 80.0);

      final subtitle = tn.isNotEmpty ? '$tn • ${m.dateTimeFormatted}' : m.dateTimeFormatted;

      // ── Pin ───────────────────────────────────────────────────────────
      stack.add(
        Positioned(
          left: pinLeft,
          top: pinTop,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _selectedIndex = _selectedIndex == i ? null : i),
            child: _Pin(moment: m, color: pinColor, selected: isSelected, perspScale: pScale),
          ),
        ),
      );

      // ── Floating label (hidden when card is open) ──────────────────────
      if (!isSelected) {
        stack.add(
          Positioned(
            left: lLeft,
            top: lTop,
            child: Container(
              constraints: const BoxConstraints(maxWidth: _labelW),
              padding: const EdgeInsets.symmetric(horizontal: _labelPadH, vertical: _labelPadV),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(9),
                border: Border(
                  left: dOnLeft ? BorderSide.none : BorderSide(color: pinColor, width: 3),
                  right: dOnLeft ? BorderSide(color: pinColor, width: 3) : BorderSide.none,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.9), blurRadius: 10, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: dOnLeft ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    m.title,
                    softWrap: true,
                    maxLines: 3,
                    textAlign: dOnLeft ? TextAlign.right : TextAlign.left,
                    style: _titleStyle(theme),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    softWrap: true,
                    maxLines: 2,
                    textAlign: dOnLeft ? TextAlign.right : TextAlign.left,
                    style: _subStyle(theme),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    // ── Floating card (last → always on top) ──────────────────────────────
    if (_selectedIndex != null && _selectedIndex! < moments.length) {
      final i = _selectedIndex!;
      final m = moments[i];
      final pinColor = widget.timelineColors[m.timelineId] ?? m.type.colors(context).bg;
      final tn = widget.timelineNames[m.timelineId];

      final cy = _slotCY![i];
      final vy = cy - _scrollOffset;
      final pinCx = _roadXAt(vy.clamp(0.0, screenH), _pinFraction(i), screenW, screenH);
      final pinTop = cy - _pinH / 2;

      const estCardH = 130.0;
      final arrowBot = vy - _pinH / 2 - estCardH - _arrowH >= 40;
      final cardTop = arrowBot ? pinTop - estCardH - _arrowH - 2 : cy + _pinH / 2 + _arrowH + 2;

      final cardLeft = (pinCx - _cardW / 2).clamp(8.0, screenW - _cardW - 8.0);
      final arrowX = (pinCx - cardLeft).clamp(_arrowW, _cardW - _arrowW);

      stack.add(
        Positioned(
          left: cardLeft,
          top: cardTop,
          width: _cardW,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onMomentTap?.call(m),
            child: _FloatingCard(
              moment: m,
              pinColor: pinColor,
              timelineName: tn,
              arrowBelow: arrowBot,
              arrowX: arrowX,
              arrowH: _arrowH,
              arrowW: _arrowW,
              cardW: _cardW,
              textTheme: theme,
            ),
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _RoadPainter())),
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              child: SizedBox(
                width: screenW,
                height: contentH,
                child: Stack(children: stack),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pin
// ─────────────────────────────────────────────────────────────────────────────

class _Pin extends StatelessWidget {
  const _Pin({required this.moment, required this.color, required this.selected, required this.perspScale});

  final Moment moment;
  final Color color;
  final bool selected;
  final double perspScale;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: perspScale * (selected ? 1.22 : 1.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      alignment: Alignment.center,
      child: SizedBox(
        width: 46,
        height: 56,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 4,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: color.withValues(alpha: 0.38), blurRadius: 12, spreadRadius: 1)],
                ),
              ),
            ),
            Icon(Icons.location_on_rounded, size: 46, color: color),
            Positioned(top: 8, child: Icon(moment.type.icon, size: 16, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating card (tap-to-open detail)
// ─────────────────────────────────────────────────────────────────────────────

class _FloatingCard extends StatelessWidget {
  const _FloatingCard({
    required this.moment,
    required this.pinColor,
    this.timelineName,
    required this.arrowBelow,
    required this.arrowX,
    required this.arrowH,
    required this.arrowW,
    required this.cardW,
    required this.textTheme,
  });

  final Moment moment;
  final Color pinColor;
  final String? timelineName;
  final bool arrowBelow;
  final double arrowX;
  final double arrowH;
  final double arrowW;
  final double cardW;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: cardW,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: pinColor.withValues(alpha: 0.50), width: 1.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: pinColor.withValues(alpha: 0.22), blurRadius: 20, offset: const Offset(0, 6)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Colored top strip ──────────────────────────────────────
            Container(height: 4, color: pinColor),
            // ── Cover photo (when available) ───────────────────────────
            if (moment.uploadedImgList.isNotEmpty)
              _CardPhotoPreview(url: moment.uploadedImgList.first, accentColor: pinColor),
            // ── Content ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    moment.title,
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A)),
                  ),
                  if (timelineName != null && timelineName!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(right: 5),
                          decoration: BoxDecoration(color: pinColor, shape: BoxShape.circle),
                        ),
                        Text(
                          timelineName!,
                          style: textTheme.labelSmall?.copyWith(
                            color: pinColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (moment.body.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      moment.body,
                      style: textTheme.bodySmall?.copyWith(color: const Color(0xFF555555), height: 1.45),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                ],
              ),
            ),
            // ── Footer: date + open CTA ─────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: pinColor.withValues(alpha: 0.07),
                border: Border(top: BorderSide(color: pinColor.withValues(alpha: 0.15), width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    moment.dateTimeFormatted,
                    style: textTheme.labelSmall?.copyWith(color: pinColor, fontWeight: FontWeight.w600, fontSize: 11),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Abrir',
                        style: textTheme.labelSmall?.copyWith(
                          color: pinColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_forward_rounded, size: 13, color: pinColor),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final arrow = SizedBox(
      width: cardW,
      height: arrowH,
      child: CustomPaint(
        painter: _ArrowPainter(color: pinColor, arrowX: arrowX, arrowW: arrowW, pointDown: arrowBelow),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: arrowBelow ? [card, arrow] : [arrow, card],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Arrow painter
// ─────────────────────────────────────────────────────────────────────────────

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter({required this.color, required this.arrowX, required this.arrowW, required this.pointDown});

  final Color color;
  final double arrowX;
  final double arrowW;
  final bool pointDown;

  @override
  void paint(Canvas canvas, Size size) {
    final half = arrowW / 2;
    final x = arrowX.clamp(half + 2, size.width - half - 2);
    canvas.drawPath(_tri(x, half, size.height, 0), Paint()..color = color);
    canvas.drawPath(_tri(x, half - 1.5, size.height, 1.5), Paint()..color = Colors.white);
  }

  Path _tri(double x, double hw, double h, double inset) {
    final p = Path();
    if (pointDown) {
      p
        ..moveTo(x - hw, inset)
        ..lineTo(x + hw, inset)
        ..lineTo(x, h - inset);
    } else {
      p
        ..moveTo(x - hw, h - inset)
        ..lineTo(x + hw, h - inset)
        ..lineTo(x, inset);
    }
    return p..close();
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter o) => o.color != color || o.arrowX != arrowX || o.pointDown != pointDown;
}

// ─────────────────────────────────────────────────────────────────────────────
// Year divider
// ─────────────────────────────────────────────────────────────────────────────

class _YearMarker {
  const _YearMarker(this.year, this.contentY);

  final int year;
  final double contentY; // centre Y in content space
}

/// Horizontal divider that spans the road and displays the year in a centred
/// pill badge — shown every time the timeline crosses a year boundary.
class _YearDivider extends StatelessWidget {
  const _YearDivider({required this.year});

  final int year;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                height: 1.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, const Color(0xFF9B59B6).withValues(alpha: 0.25)],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFEFD6F7), Color(0xFFFBDFEB)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 12, offset: const Offset(0, 3)),
                ],
              ),
              child: Text(
                year.toString(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5B2178),
                  letterSpacing: 3.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 1.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF9B59B6).withValues(alpha: 0.25), Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card photo preview with shimmer loading state
// ─────────────────────────────────────────────────────────────────────────────

class _CardPhotoPreview extends StatelessWidget {
  const _CardPhotoPreview({required this.url, required this.accentColor});

  final String url;
  final Color accentColor;

  static const double _height = 110.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      width: double.infinity,
      child: AppNetworkImage(
        url: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: _height,
        errorWidget: Container(
          height: _height,
          width: double.infinity,
          color: accentColor.withValues(alpha: 0.08),
          alignment: Alignment.center,
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 24,
            color: accentColor.withValues(alpha: 0.40),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Road painter — original style, wider top
// ─────────────────────────────────────────────────────────────────────────────

/// Static background.  Visual style is identical to the well-liked original
/// (pale-rose gradient, near-white lanes, subtle glow + depth lines) but the
/// road is wider at the top (50 % of screen instead of 24 %) so it no longer
/// looks like a vanishing-point motorway.
///
/// Road bezier:
///   left  moveTo(0.25w, 0) → cubicTo(0.18w,0.25h, 0.13w,0.58h, 0.07w,h)
///   right lineTo(0.93w,h) → cubicTo(0.87w,0.58h, 0.82w,0.25h, 0.75w,0)
class _RoadPainter extends CustomPainter {
  _RoadPainter();

  // Same warm-grey / near-white palette as the original
  static const _laneColors = [
    Color(0xFFEDECE9), // outer left  — very slightly warm grey
    Color(0xFFF3F2F0), // inner left
    Color(0xFFFFFFFF), // centre      — pure white
    Color(0xFFF3F2F0), // inner right
    Color(0xFFEDECE9), // outer right
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── 0. Background: lavender → rosé → white ──────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFFEFD6F7), Color(0xFFFBDFEB), Colors.white],
          stops: const [0.0, 0.30, 0.72],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    final road = _roadPath(w, h);

    // ── 1. Soft drop-shadow ───────────────────────────────────────────────────
    canvas.drawPath(
      road,
      Paint()
        ..color = Colors.grey.withValues(alpha: 0.09)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // ── 2. Five curved lane strips ───────────────────────────────────────────
    for (var li = 0; li < 5; li++) {
      canvas.drawPath(_strip(li / 5.0, (li + 1) / 5.0, w, h), Paint()..color = _laneColors[li]);
    }

    // ── 3. Interior effects (clipped to road) ────────────────────────────────
    canvas.save();
    canvas.clipPath(road);

    // Vanishing-point glow
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.0, -0.72),
          radius: 0.48,
          colors: [Colors.white.withValues(alpha: 0.75), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Perspective-spaced depth lines (quadratic → denser at top)
    final horizPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.042)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (var n = 1; n <= 20; n++) {
      final y = h * (n / 20.0) * (n / 20.0);
      canvas.drawLine(Offset(0, y), Offset(w, y), horizPaint);
    }

    canvas.restore();

    // ── 4. Road outline ──────────────────────────────────────────────────────
    canvas.drawPath(
      road,
      Paint()
        ..color = Colors.grey.withValues(alpha: 0.13)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );
  }

  Path _roadPath(double w, double h) => Path()
    ..moveTo(w * 0.25, 0)
    ..cubicTo(w * 0.18, h * 0.25, w * 0.13, h * 0.58, w * 0.07, h)
    ..lineTo(w * 0.93, h)
    ..cubicTo(w * 0.87, h * 0.58, w * 0.82, h * 0.25, w * 0.75, 0)
    ..close();

  Path _strip(double f1, double f2, double w, double h) {
    double topX(double f) => w * (0.25 + f * 0.50);
    double cp1X(double f) => w * (0.18 + f * 0.64); // at y = 0.25h
    double cp2X(double f) => w * (0.13 + f * 0.74); // at y = 0.58h
    double botX(double f) => w * (0.07 + f * 0.86);

    return Path()
      ..moveTo(topX(f1), 0)
      ..cubicTo(cp1X(f1), h * 0.25, cp2X(f1), h * 0.58, botX(f1), h)
      ..lineTo(botX(f2), h)
      ..cubicTo(cp2X(f2), h * 0.58, cp1X(f2), h * 0.25, topX(f2), 0)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _RoadPainter o) => false;
}
