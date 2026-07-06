import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/routes.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/background_gradient.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_app_bar.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';
import 'package:nossos_momentos/modules/core/premium/premium_feature.dart';
import 'package:nossos_momentos/modules/core/premium/premium_service.dart';
import 'package:nossos_momentos/modules/core/premium/widget/premium_gate.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/notifications/notification_service.dart';
import 'package:nossos_momentos/modules/premium/domain/use_case/present_customer_center_use_case.dart';
import 'package:nossos_momentos/modules/settings/presentation/bloc/settings_bloc.dart';
import 'package:nossos_momentos/modules/settings/presentation/widget/delete_account_confirmation_sheet.dart';
import 'package:nossos_momentos/modules/settings/presentation/widget/reauth_password_dialog.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  Future<void> _promptReauth(BuildContext context) async {
    final bloc = context.read<SettingsBloc>();
    final password = await showReauthPasswordDialog(context);
    if (password == null) return;
    bloc.add(ReauthenticateAndDeleteAccountEvent(password: password));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>(
      create: (_) => getIt<SettingsBloc>()..add(FetchEmailEvent()),
      child: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsAccountDeleted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoute.login.tag,
              (_) => false,
            );
          } else if (state is SettingsReauthRequired) {
            _promptReauth(context);
          } else if (state is SettingsAccountDeleteError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(
                content: Text('Não foi possível excluir a conta. Tente novamente.'),
              ));
          }
        },
        child: Stack(
          children: [
            const BackgroundGradient(),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: PrimaryAppBar(title: 'Minha conta'),
              body: BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  if (state is SettingsLoading) return const _LoadingPlaceholder();
                  if (state is SettingsSuccess) {
                    return _AccountContent(email: state.email ?? '');
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _AccountContent extends StatelessWidget {
  const _AccountContent({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section(
            icon: Icons.person_outline,
            title: 'Conta',
            subtitle: 'Sua identidade no app',
            child: _EmailRow(email: email),
          ),
          kSpacerHeight16,
          const _Section(
            icon: Icons.notifications_active_outlined,
            title: 'Lembrete "Neste dia"',
            subtitle: 'Receba uma lembrança diária das suas memórias',
            child: _ReminderToggle(),
          ),
          if (getIt<PremiumService>().isStoreAvailable) ...[
            kSpacerHeight16,
            const _Section(
              icon: Icons.workspace_premium_outlined,
              title: 'Gerenciar assinatura',
              subtitle: 'Veja, restaure ou cancele seu plano premium',
              child: _SubscriptionButton(),
            ),
          ],
          kSpacerHeight16,
          const _DangerZone(),
        ],
      ),
    );
  }
}

class _EmailRow extends StatelessWidget {
  const _EmailRow({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: palette.primarySoft,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(Icons.alternate_email_rounded, color: palette.primary, size: 18),
        ),
        kSpacerWidth12,
        Expanded(
          child: Text(
            email,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _ReminderToggle extends StatefulWidget {
  const _ReminderToggle();

  @override
  State<_ReminderToggle> createState() => _ReminderToggleState();
}

class _ReminderToggleState extends State<_ReminderToggle> {
  bool _enabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await getIt<NotificationService>().isReminderEnabled();
    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      _loading = false;
    });
  }

  Future<void> _onChanged(bool value) async {
    final service = getIt<NotificationService>();
    if (value && !getIt<PremiumService>().can(PremiumFeature.onThisDayPush)) {
      final unlocked = await showPremiumPlaceholder(context, PremiumFeature.onThisDayPush);
      if (!unlocked) return;
    }
    if (value) {
      final granted = await service.enableReminder();
      if (!mounted) return;
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ative as notificações nas configurações do aparelho.')),
        );
      }
      setState(() => _enabled = granted);
    } else {
      await service.disableReminder();
      if (!mounted) return;
      setState(() => _enabled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final isPremium = getIt<PremiumService>().can(PremiumFeature.onThisDayPush);

    if (_loading) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lembrança diária às 9h', style: textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(
                isPremium
                    ? 'Toque na notificação para reviver suas memórias.'
                    : 'Recurso premium — desbloqueie para ativar.',
                style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
              ),
            ],
          ),
        ),
        kSpacerWidth12,
        Switch(value: _enabled, onChanged: _onChanged),
      ],
    );
  }
}

class _SubscriptionButton extends StatelessWidget {
  const _SubscriptionButton();

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await getIt<PresentCustomerCenterUseCase>().call(NoParams.instance);
    if (result.isError) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Não foi possível abrir o gerenciamento da assinatura.'),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _open(context),
        icon: const Icon(Icons.settings_outlined, size: 20),
        label: const Text('Abrir gerenciamento'),
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  const _DangerZone();

  Future<void> _openDeleteAccountSheet(BuildContext context) async {
    final bloc = context.read<SettingsBloc>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeleteAccountConfirmationSheet(
        onConfirm: () => bloc.add(DeleteAccountEvent()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final errorColor = Theme.of(context).colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: errorColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: errorColor.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: errorColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.warning_amber_outlined, color: errorColor, size: 22),
              ),
              kSpacerWidth12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Zona de perigo', style: textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      'Ações permanentes e irreversíveis',
                      style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          kSpacerHeight16,
          Text('Excluir conta', style: textTheme.titleSmall),
          const SizedBox(height: 2),
          Text(
            'Apaga sua conta e os dados que pertencem só a você.',
            style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
          ),
          kSpacerHeight12,
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openDeleteAccountSheet(context),
              icon: const Icon(Icons.person_off_outlined, size: 20, color: Colors.white),
              label: const Text('Excluir minha conta', style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                foregroundColor: errorColor,
                side: BorderSide(color: errorColor.withValues(alpha: 0.6)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: palette.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: palette.primary, size: 22),
              ),
              kSpacerWidth12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(subtitle, style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted)),
                  ],
                ),
              ),
            ],
          ),
          kSpacerHeight24,
          child,
        ],
      ),
    );
  }
}
