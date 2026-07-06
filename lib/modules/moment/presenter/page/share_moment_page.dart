import 'package:flutter/material.dart';

import '../../../core/presenter/widgets/primary_button.dart';
import '../../../core/utils/share/capture_and_share.dart';
import '../../../core/utils/theme/app_theme.dart';
import '../../domain/entities/moment.dart';
import '../widget/shareable_moment_card.dart';

/// Previews a shareable image of the moment and shares it (PNG) via share_plus.
class ShareMomentPage extends StatefulWidget {
  const ShareMomentPage({super.key});

  @override
  State<ShareMomentPage> createState() => _ShareMomentPageState();
}

class _ShareMomentPageState extends State<ShareMomentPage> {
  final GlobalKey _cardKey = GlobalKey();
  bool _sharing = false;
  late Moment _moment;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _moment = ModalRoute.of(context)!.settings.arguments as Moment;
  }

  Future<void> _share() async {
    setState(() => _sharing = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await captureAndShare(_cardKey, text: _moment.title);
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
                    child: ShareableMomentCard(moment: _moment),
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
