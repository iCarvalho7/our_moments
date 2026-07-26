import 'package:flutter/material.dart';

import '../widgets/app_card.dart';
import '../widgets/background_gradient.dart';
import '../widgets/primary_app_bar.dart';
import '../../utils/theme/app_theme.dart';

/// Educational screen that makes the app's privacy model visible: your moments
/// live in timelines that only invited people can see, each member has a clear
/// role, and a moment can be kept private to you alone. Turning an otherwise
/// invisible Settings feature into a stated, trust-building differentiator.
class PrivacyExplainerPage extends StatelessWidget {
  const PrivacyExplainerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        const BackgroundGradient(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PrimaryAppBar(title: 'Sua privacidade'),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: palette.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.shield_rounded, color: palette.primary, size: 34),
                ),
                kSpacerHeight16,
                Text(
                  'Seus momentos são só de quem você escolher',
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                kSpacerHeight8,
                Text(
                  'Cada momento vive dentro de uma história que só as pessoas '
                  'convidadas conseguem ver. Nada é público — você tem o controle.',
                  style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
                ),
                kSpacerHeight24,
                const _RoleCard(
                  icon: Icons.workspace_premium_rounded,
                  title: 'Dono',
                  description:
                      'Convida e remove pessoas, define papéis e pode encerrar a '
                      'história. Toda história começa com você como dono.',
                ),
                kSpacerHeight12,
                const _RoleCard(
                  icon: Icons.edit_rounded,
                  title: 'Editor',
                  description:
                      'Cria e edita momentos. Você decide se cada editor mexe em '
                      'tudo (colaborativo) ou só nos próprios momentos (individual).',
                ),
                kSpacerHeight12,
                const _RoleCard(
                  icon: Icons.visibility_outlined,
                  title: 'Quem vê',
                  description:
                      'Convidados apenas acompanham os momentos, sem poder alterá-los.',
                ),
                kSpacerHeight24,
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lock_rounded, color: palette.primary, size: 22),
                      kSpacerWidth12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Momento privado',
                              style: textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            kSpacerHeight8,
                            Text(
                              'Ao criar um momento, você pode marcá-lo como privado. '
                              'Ele fica visível só para você, mesmo dentro de uma '
                              'história compartilhada.',
                              style: textTheme.bodySmall
                                  ?.copyWith(color: palette.onSurfaceMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: palette.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: palette.primary, size: 20),
          ),
          kSpacerWidth12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                kSpacerHeight8,
                Text(
                  description,
                  style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
