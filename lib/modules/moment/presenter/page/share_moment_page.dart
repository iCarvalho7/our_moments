import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/presenter/widgets/primary_button.dart';
import '../../../core/utils/theme/app_theme.dart';
import '../../domain/entities/moment.dart';
import '../widget/shareable_moment_card.dart';

/// Previews a shareable image of the moment and shares it (PNG) via share_plus.
class ShareMomentPage extends StatefulWidget {
  const ShareMomentPage({super.key, required this.moment});

  final Moment moment;

  @override
  State<ShareMomentPage> createState() => _ShareMomentPageState();
}

class _ShareMomentPageState extends State<ShareMomentPage> {
  final GlobalKey _cardKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share() async {
    setState(() => _sharing = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final boundary = _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final Uint8List bytes = byteData.buffer.asUint8List();

      await Share.shareXFiles(
        [XFile.fromData(bytes, mimeType: 'image/png', name: 'momento.png')],
        text: widget.moment.title,
      );
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Não foi possível gerar a imagem.')));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Compartilhar'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: ShareableMomentCard(moment: widget.moment),
                  ),
                ),
              ),
              kSpacerHeight16,
              PrimaryButton(
                label: 'Compartilhar',
                icon: Icons.ios_share_rounded,
                onPressed: _sharing ? null : _share,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
