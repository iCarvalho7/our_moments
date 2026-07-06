import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/premium/premium_feature.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/app_card.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/background_gradient.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_app_bar.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_button.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';

import 'package:nossos_momentos/modules/core/premium/premium_service.dart';

import '../../domain/use_case/present_customer_center_use_case.dart';
import '../bloc/premium_bloc.dart';

/// Subscription screen (paywall). Lists the current offering's plans, lets the
/// couple buy or restore, and pops `true` on success so the caller can refresh
/// the timeline (re-binding [PremiumService]).
class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    final highlightFeature = ModalRoute.of(context)?.settings.arguments as PremiumFeature?;
    return BlocProvider(
      create: (_) => getIt<PremiumBloc>()..add(PremiumEventLoadOfferings()),
      child: Builder(
        builder: (context) {
          return Stack(
            children: [
              const BackgroundGradient(),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: const PrimaryAppBar(title: 'Nossos Momentos Premium'),
                body: SafeArea(
                  child: BlocConsumer<PremiumBloc, PremiumState>(
                    listener: _onState,
                    builder: (context, state) =>
                        _buildBody(context, state, highlightFeature),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onState(BuildContext context, PremiumState state) {
    if (state is PremiumStateSuccess) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Premium ativado! Aproveitem 💛')),
        );
      Navigator.of(context).pop(true);
    }

    if (state is PremiumStateError) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  Widget _buildBody(
    BuildContext context,
    PremiumState state,
    PremiumFeature? highlight,
  ) {
    if (state is PremiumStateLoading || state is PremiumStateInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    final storeAvailable = getIt<PremiumService>().isStoreAvailable;
    final busy = state is PremiumStatePurchasing;

    // Hard load failure with nothing to fall back on (only when the store is
    // available — otherwise we show the friendly "unavailable" CTA-less view).
    if (storeAvailable && state is PremiumStateError && state.plans == null) {
      return _ErrorView(message: state.message);
    }

    // The group plan is the only one that unlocks shared-timeline features.
    final groupOnly = highlight?.minTier == PremiumTier.couple;

    void openPaywall(PremiumTier tier) =>
        context.read<PremiumBloc>().add(PremiumEventPresentPaywall(tier));

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _Header(highlight: highlight),
        kSpacerHeight24,
        const _ComparisonCard(),
        kSpacerHeight24,
        if (!storeAvailable)
          kDebugMode ? const _DebugNote() : const _UnavailableNote()
        else ...[
          if (groupOnly) ...[
            Text(
              '${highlight!.label} faz parte do plano do Grupo. '
              'O Solo não inclui esse recurso.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.palette.onSurfaceMuted,
                  ),
            ),
            kSpacerHeight12,
            PrimaryButton(
              label: 'Assinar Grupo',
              onPressed: busy ? null : () => openPaywall(PremiumTier.couple),
            ),
            kSpacerHeight8,
            TextButton(
              onPressed:
                  busy ? null : () => openPaywall(PremiumTier.individual),
              child: const Text('Ver plano Solo mesmo assim'),
            ),
          ] else ...[
            PrimaryButton(
              label: 'Assinar Grupo',
              onPressed: busy ? null : () => openPaywall(PremiumTier.couple),
            ),
            kSpacerHeight8,
            PrimaryButton(
              label: 'Assinar Solo',
              onPressed:
                  busy ? null : () => openPaywall(PremiumTier.individual),
            ),
          ],
          if (busy) ...[
            kSpacerHeight16,
            const Center(child: CircularProgressIndicator()),
          ],
          kSpacerHeight16,
          TextButton(
            onPressed: busy
                ? null
                : () => context.read<PremiumBloc>().add(PremiumEventRestore()),
            child: const Text('Restaurar compras'),
          ),
          TextButton(
            onPressed: busy ? null : () => _openCustomerCenter(context),
            child: const Text('Gerenciar assinatura'),
          ),
        ],
        kSpacerHeight8,
        _LegalNote(),
      ],
    );
  }

  Future<void> _openCustomerCenter(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final result =
        await getIt<PresentCustomerCenterUseCase>().call(NoParams.instance);
    if (result.isError) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o gerenciamento da assinatura.'),
          ),
        );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({this.highlight});

  final PremiumFeature? highlight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [palette.primary, palette.secondaryAccent],
            ),
            shape: BoxShape.circle,
            boxShadow: AppShadows.soft(context),
          ),
          child: const Icon(Icons.workspace_premium_rounded,
              color: Colors.white, size: 36),
        ),
        kSpacerHeight16,
        Text('Escolha o plano de vocês', style: textTheme.headlineMedium),
        kSpacerHeight8,
        Text(
          _subtitleFor(highlight),
          style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
        ),
      ],
    );
  }

  String _subtitleFor(PremiumFeature? feature) {
    if (feature == null) {
      return 'Solo desbloqueia os recursos pessoais. Grupo libera tudo para '
          'todo mundo da timeline — casal, amigos, quem for.';
    }
    if (feature.minTier == PremiumTier.couple) {
      return '${feature.label} faz parte do plano Grupo: qualquer pessoa da '
          'timeline assina e todos aproveitam.';
    }
    return '${feature.label} está disponível nos dois planos. Escolham o que '
        'fizer mais sentido.';
  }
}

/// Two-column comparison matrix, derived from [PremiumFeature] so it stays in
/// sync. Individual checks features with `minTier == individual`; Casal checks
/// every feature (it is a superset).
class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with the two tier columns.
          Row(
            children: [
              const Expanded(child: SizedBox()),
              _ColumnLabel(label: 'Solo'),
              kSpacerWidth12,
              _ColumnLabel(label: 'Grupo'),
            ],
          ),
          kSpacerHeight8,
          for (final feature in PremiumFeature.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(feature.label, style: textTheme.bodyMedium),
                  ),
                  _Mark(
                    checked: feature.minTier == PremiumTier.individual,
                  ),
                  kSpacerWidth12,
                  // Couple is a superset: every feature is included.
                  const _Mark(checked: true),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ColumnLabel extends StatelessWidget {
  const _ColumnLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    return SizedBox(
      width: 64,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: palette.primary,
        ),
      ),
    );
  }
}

/// A check (included) or dash (not included) cell in the comparison matrix.
class _Mark extends StatelessWidget {
  const _Mark({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      width: 64,
      child: Center(
        child: checked
            ? Icon(Icons.check_circle_rounded, color: palette.primary, size: 22)
            : Icon(Icons.remove_rounded, color: palette.onSurfaceMuted, size: 20),
      ),
    );
  }
}

/// Shown when the store SDK is unavailable (web/dev/unconfigured): the
/// comparison stays visible but there is nothing to subscribe to here.
class _UnavailableNote extends StatelessWidget {
  const _UnavailableNote();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return AppCard(
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: palette.onSurfaceMuted),
          kSpacerWidth12,
          Expanded(
            child: Text(
              'As assinaturas estão disponíveis no app para Android e iOS.',
              style:
                  textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                size: 48, color: palette.onSurfaceMuted),
            kSpacerHeight16,
            Text(message, textAlign: TextAlign.center, style: textTheme.bodyLarge),
            kSpacerHeight24,
            PrimaryButton(
              label: 'Tentar novamente',
              expand: false,
              onPressed: () =>
                  context.read<PremiumBloc>().add(PremiumEventLoadOfferings()),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebugNote extends StatelessWidget {
  const _DebugNote();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;

    return AppCard(
      child: Row(
        children: [
          Icon(Icons.bug_report_outlined, color: palette.primary),
          kSpacerWidth12,
          Expanded(
            child: Text(
              'Modo debug: premium liberado automaticamente. As compras '
              'ficam disponíveis na build de produção.',
              style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    return Text(
      'Os planos mensais e anuais renovam automaticamente até serem cancelados '
      'na loja. O plano vitalício é uma compra única sem renovação.',
      style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
      textAlign: TextAlign.center,
    );
  }
}
