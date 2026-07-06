import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/premium/premium_feature.dart';
import 'package:nossos_momentos/modules/core/premium/premium_service.dart';
import 'package:nossos_momentos/modules/core/premium/widget/premium_gate.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/app_network_image.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/loading_effect.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_app_bar.dart';
import 'package:nossos_momentos/modules/core/utils/data_url/data_url.dart';
import 'package:nossos_momentos/modules/login/presentation/widget/login_text_field.dart';
import 'package:nossos_momentos/modules/notifications/notification_service.dart';
import 'package:nossos_momentos/modules/core/use_case/use_case.dart';
import 'package:nossos_momentos/modules/photos/domain/repository/photos_repository.dart';
import 'package:nossos_momentos/modules/premium/domain/use_case/present_customer_center_use_case.dart';
import 'package:nossos_momentos/modules/settings/presentation/bloc/settings_bloc.dart';
import 'package:nossos_momentos/modules/settings/presentation/widget/delete_account_confirmation_sheet.dart';
import 'package:nossos_momentos/modules/settings/presentation/widget/leave_timeline_sheet.dart';
import 'package:nossos_momentos/modules/settings/presentation/widget/reauth_password_dialog.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/timeline_permissions.dart';
import 'package:nossos_momentos/modules/time_line/presenter/widgets/delete_timeline_confirmation_sheet.dart';

import '../../../core/presenter/routes.dart';
import '../../../core/presenter/widgets/background_gradient.dart';
import '../../../core/utils/theme/app_theme.dart';

const List<Color> _kAccentColors = [
  Color(0xFFFF6B7A), // coral
  Color(0xFFE84D8A), // rose
  Color(0xFF8B5CF6), // violet
  Color(0xFF6366F1), // indigo
  Color(0xFF3B82F6), // blue
  Color(0xFF14B8A6), // teal
  Color(0xFF22C55E), // green
  Color(0xFFF59E0B), // amber
  Color(0xFFFB7185), // pink
  Color(0xFF64748B), // slate
];

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final usernameController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  /// Reauthentication is required before deleting the account. Prompts for the
  /// password and, on confirmation, retries the deletion through the bloc.
  Future<void> _promptReauth(BuildContext context) async {
    final bloc = context.read<SettingsBloc>();
    final password = await showReauthPasswordDialog(context);
    if (password == null) return;
    bloc.add(ReauthenticateAndDeleteAccountEvent(password: password));
  }

  @override
  Widget build(BuildContext context) {
    final timeLineId = ModalRoute.of(context)?.settings.arguments as String;

    return BlocProvider<SettingsBloc>(
      create: (context) => getIt<SettingsBloc>()..add(FetchEmailEvent(timeLineId: timeLineId)),
      child: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsTimeLineDeleted) {
            Navigator.of(context).pushNamedAndRemoveUntil(AppRoute.newSelectTimeLine.tag, (_) => false);
          } else if (state is SettingsAccountDeleted) {
            Navigator.of(context).pushNamedAndRemoveUntil(AppRoute.login.tag, (_) => false);
          } else if (state is SettingsReauthRequired) {
            _promptReauth(context);
          } else if (state is SettingsAccountDeleteError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text('Não foi possível excluir a conta. Tente novamente.')));
          }
        },
        child: Stack(
          children: [
            const BackgroundGradient(),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: PrimaryAppBar(title: 'Gerenciar acesso'),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) {
                    if (state is SettingsSuccess) {
                      return _SuccessContent(
                        timeline: state.timeLine!,
                        usernameController: usernameController,
                        state: state,
                      );
                    }
                    if (state is SettingsLoading) {
                      return const _LoadingContent();
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    final surface = context.palette.surface;
    BoxDecoration deco() => BoxDecoration(color: surface, borderRadius: BorderRadius.circular(AppRadii.card));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoadingEffect(
            child: Container(width: MediaQuery.of(context).size.width, height: 260, decoration: deco()),
          ),
          const SizedBox(height: 16),
          LoadingEffect(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 3,
              decoration: deco(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({required this.state, required this.timeline, required this.usernameController});

  final TimeLine timeline;
  final TextEditingController usernameController;
  final SettingsState state;

  @override
  Widget build(BuildContext context) {
    final emails = timeline.emailsUserFirst(state.email!);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsSection(
            icon: Icons.palette_outlined,
            title: 'Personalizar',
            subtitle: 'Nome e cor da sua linha do tempo',
            child: _TimelineDetailsSection(timeline: timeline),
          ),
          kSpacerHeight16,
          _SettingsSection(
            icon: Icons.group_outlined,
            title: 'Quem tem acesso',
            subtitle: emails.length == 1 ? '1 pessoa' : '${emails.length} pessoas',
            child: _AccessList(emails: emails, state: state, usernameController: usernameController),
          ),
          if (emails.length > 1) ...[
            kSpacerHeight16,
            _SettingsSection(
              icon: Icons.security_outlined,
              title: 'Níveis de acesso',
              subtitle: 'Defina quem pode editar ou apenas visualizar',
              child: _AccessLevelSection(timeline: timeline, emails: emails, currentEmail: state.email!),
            ),
          ],
          if (TimelinePermissions.isDeletionPending(timeline) &&
              TimelinePermissions.isOwner(timeline, state.email!)) ...[
            kSpacerHeight16,
            _SettingsSection(
              icon: Icons.hourglass_top_outlined,
              title: 'Deleção pendente',
              subtitle: 'A exclusão precisa da aprovação de todos os donos',
              child: _PendingDeletionSection(timeline: timeline, currentEmail: state.email!),
            ),
          ],
          kSpacerHeight16,
          _SettingsSection(
            icon: Icons.photo_filter_outlined,
            title: 'Capa e apelidos',
            subtitle: 'Personalize a capa e os apelidos do casal',
            child: _CoupleHeaderSection(timeline: timeline, emails: emails),
          ),
          kSpacerHeight16,
          _SettingsSection(
            icon: Icons.event_busy_outlined,
            title: 'Data de término',
            subtitle: 'Impede novos momentos com data após este dia',
            child: _RelationshipEndDateSection(timeline: timeline),
          ),
          kSpacerHeight16,
          _SettingsSection(
            icon: Icons.notifications_active_outlined,
            title: 'Lembrete "Neste dia"',
            subtitle: 'Receba uma lembrança diária das suas memórias',
            child: const _OnThisDayReminderToggle(),
          ),
          if (getIt<PremiumService>().isStoreAvailable) ...[
            kSpacerHeight16,
            _SettingsSection(
              icon: Icons.workspace_premium_outlined,
              title: 'Gerenciar assinatura',
              subtitle: 'Veja, restaure ou cancele seu plano premium',
              child: const _ManageSubscriptionButton(),
            ),
          ],
          kSpacerHeight16,
          _DangerZoneSection(timeline: timeline, currentEmail: state.email!),
        ],
      ),
    );
  }
}

/// Opens the RevenueCat-hosted Customer Center. Only shown when the store SDK
/// is available (mobile + configured).
class _ManageSubscriptionButton extends StatelessWidget {
  const _ManageSubscriptionButton();

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await getIt<PresentCustomerCenterUseCase>().call(NoParams.instance);
    if (result.isError) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Não foi possível abrir o gerenciamento da assinatura.')));
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

/// Couple-only section to set a cover photo and per-member nicknames. Gated:
/// editing requires the couple tier — otherwise the paywall opens on interaction.
class _CoupleHeaderSection extends StatefulWidget {
  const _CoupleHeaderSection({required this.timeline, required this.emails});

  final TimeLine timeline;
  final List<String> emails;

  @override
  State<_CoupleHeaderSection> createState() => _CoupleHeaderSectionState();
}

class _CoupleHeaderSectionState extends State<_CoupleHeaderSection> {
  late final Map<String, TextEditingController> _controllers = {
    for (final email in widget.emails) email: TextEditingController(text: widget.timeline.nicknames[email] ?? ''),
  };

  /// A freshly picked local cover (file path on mobile, data URL on web), if any.
  String? _localCover;

  /// The existing remote cover URL to keep when no new photo was picked.
  late String _keepCoverUrl = widget.timeline.coverPhotoUrl;

  bool get _unlocked => getIt<PremiumService>().can(PremiumFeature.coupleCover);

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<bool> _ensureUnlocked() async {
    if (_unlocked) return true;
    return showPremiumPlaceholder(context, PremiumFeature.coupleCover);
  }

  Future<void> _pickCover() async {
    if (!await _ensureUnlocked()) return;
    final media = await getIt<PhotosRepository>().getMedia();
    if (!mounted || media.isEmpty) return;
    setState(() => _localCover = media.first.url);
  }

  void _removeCover() {
    setState(() {
      _localCover = null;
      _keepCoverUrl = '';
    });
  }

  Future<void> _save() async {
    if (!await _ensureUnlocked()) return;
    if (!mounted) return;
    FocusScope.of(context).unfocus();

    final nicknames = <String, String>{};
    _controllers.forEach((email, controller) {
      final value = controller.text.trim();
      if (value.isNotEmpty) nicknames[email] = value;
    });

    context.read<SettingsBloc>().add(
      UpdateCoupleHeaderEvent(nicknames: nicknames, localCoverPath: _localCover, keepCoverUrl: _keepCoverUrl),
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Capa e apelidos atualizados.')));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final hasNewCover = _localCover != null;
    final hasCover = hasNewCover || _keepCoverUrl.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickCover,
          child: Container(
            height: 150,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: palette.outline),
            ),
            child: hasCover
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      _CoverPreview(localCover: _localCover, remoteUrl: _keepCoverUrl),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _removeCover,
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(Icons.close_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, color: palette.onSurfaceMuted, size: 30),
                      kSpacerHeight8,
                      Text(
                        'Adicionar foto de capa',
                        style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
                      ),
                    ],
                  ),
          ),
        ),
        kSpacerHeight24,
        Text('Apelidos do casal', style: textTheme.titleSmall?.copyWith(color: palette.onSurfaceMuted)),
        kSpacerHeight12,
        ..._controllers.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: entry.value,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: entry.key,
                hintText: 'Apelido',
                prefixIcon: const Icon(Icons.favorite_outline_rounded),
              ),
            ),
          );
        }),
        kSpacerHeight12,
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded, size: 20),
            label: const Text('Salvar alterações'),
          ),
        ),
      ],
    );
  }
}

/// Renders either a freshly picked local cover or the persisted remote one.
class _CoverPreview extends StatelessWidget {
  const _CoverPreview({required this.localCover, required this.remoteUrl});

  final String? localCover;
  final String remoteUrl;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: context.palette.surfaceAlt,
      alignment: Alignment.center,
      child: Icon(Icons.broken_image_outlined, color: context.palette.onSurfaceMuted),
    );

    final local = localCover;
    if (local != null) {
      final bytes = decodeDataUrl(local);
      if (bytes != null) {
        return Image.memory(bytes, fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback);
      }
      return Image.file(File(local), fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback);
    }

    return AppNetworkImage(url: remoteUrl, fit: BoxFit.cover, errorWidget: fallback);
  }
}

/// Premium toggle for the daily "Neste dia" reminder. Reads/writes the
/// preference through [NotificationService]; when the couple is not premium,
/// turning it on opens the paywall instead.
class _OnThisDayReminderToggle extends StatefulWidget {
  const _OnThisDayReminderToggle();

  @override
  State<_OnThisDayReminderToggle> createState() => _OnThisDayReminderToggleState();
}

class _OnThisDayReminderToggleState extends State<_OnThisDayReminderToggle> {
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

    // Premium gate: turning the reminder on requires premium. Free users get
    // the paywall; on success, schedule and reflect the new state.
    if (value && !getIt<PremiumService>().can(PremiumFeature.onThisDayPush)) {
      final unlocked = await showPremiumPlaceholder(context, PremiumFeature.onThisDayPush);
      if (!unlocked) return;
    }

    if (value) {
      final granted = await service.enableReminder();
      if (!mounted) return;
      if (!granted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Ative as notificações nas configurações do aparelho.')));
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

class _DangerZoneSection extends StatelessWidget {
  const _DangerZoneSection({required this.timeline, required this.currentEmail});

  final TimeLine timeline;
  final String currentEmail;

  Future<void> _openDeleteSheet(BuildContext context) async {
    final bloc = context.read<SettingsBloc>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeleteTimelineConfirmationSheet(
        timelineName: timeline.name,
        onConfirm: () => bloc.add(RequestTimelineDeletionEvent()),
      ),
    );
  }

  Future<void> _openDeleteAccountSheet(BuildContext context) async {
    final bloc = context.read<SettingsBloc>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeleteAccountConfirmationSheet(onConfirm: () => bloc.add(DeleteAccountEvent())),
    );
  }

  Future<void> _openLeaveSheet(BuildContext context) async {
    final bloc = context.read<SettingsBloc>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LeaveTimelineSheet(
        timelineName: timeline.name,
        onConfirm: (deleteAuthoredMoments) =>
            bloc.add(LeaveTimelineEvent(deleteAuthoredMoments: deleteAuthoredMoments)),
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
          kSpacerHeight24,
          // Deleting the whole timeline is an owner-only action.
          if (TimelinePermissions.canDeleteTimeline(timeline, currentEmail))
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openDeleteSheet(context),
                icon: const Icon(Icons.delete_forever_rounded, size: 20),
                label: const Text('Deletar linha do tempo'),
                style: ElevatedButton.styleFrom(backgroundColor: errorColor, foregroundColor: Colors.white),
              ),
            ),
          if (timeline.emails.length > 1) ...[
            if (TimelinePermissions.canDeleteTimeline(timeline, currentEmail)) kSpacerHeight12,
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openLeaveSheet(context),
                icon: const Icon(Icons.logout_rounded, size: 20, color: Colors.white),
                label: Text('Sair da timeline', style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: errorColor,
                  side: BorderSide(color: errorColor.withValues(alpha: 0.6)),
                ),
              ),
            ),
          ],
          kSpacerHeight24,
          Divider(color: errorColor.withValues(alpha: 0.2), height: 1),
          kSpacerHeight24,
          Text('Excluir conta', style: textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(
            'Apaga sua conta e os dados que pertencem só a você',
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

/// A titled rounded card grouping a settings area.
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.icon, required this.title, required this.subtitle, required this.child});

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
                decoration: BoxDecoration(color: palette.primarySoft, borderRadius: BorderRadius.circular(12)),
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

class _AccessList extends StatelessWidget {
  const _AccessList({required this.emails, required this.state, required this.usernameController});

  final List<String> emails;
  final SettingsState state;
  final TextEditingController usernameController;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        ...emails.map((item) {
          final isOwner = state.timeLine?.owners.contains(item) ?? false;
          final isSelf = item == state.email;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(color: palette.surfaceAlt, borderRadius: BorderRadius.circular(AppRadii.input)),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: palette.primarySoft, shape: BoxShape.circle),
                  child: Text(
                    item.isNotEmpty ? item[0].toUpperCase() : '?',
                    style: textTheme.titleSmall?.copyWith(color: palette.primary, fontWeight: FontWeight.w700),
                  ),
                ),
                kSpacerWidth12,
                Expanded(
                  child: Text(item, style: textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                ),
                if (isOwner || isSelf)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Text(isOwner ? 'Admin' : 'Você', style: textTheme.bodySmall),
                  )
                else
                  InkWell(
                    onTap: () => context.read<SettingsBloc>().add(DeleteEmailEvent(email: item)),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.delete_outline_rounded, color: palette.danger),
                    ),
                  ),
              ],
            ),
          );
        }),
        kSpacerHeight12,
        LoginTextField(
          startIcon: Icons.person_add_alt_1,
          endIcon: Icons.send,
          endIconPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            context.read<SettingsBloc>().add(AddEmailEvent(email: usernameController.text));
            usernameController.clear();
          },
          hint: 'exemplo@email.com',
          controller: usernameController,
        ),
      ],
    );
  }
}

class _TimelineDetailsSection extends StatefulWidget {
  const _TimelineDetailsSection({required this.timeline});

  final TimeLine timeline;

  @override
  State<_TimelineDetailsSection> createState() => _TimelineDetailsSectionState();
}

class _TimelineDetailsSectionState extends State<_TimelineDetailsSection> {
  late final TextEditingController _nameController = TextEditingController(text: widget.timeline.name);
  late int? _accentColor = widget.timeline.accentColor;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    context.read<SettingsBloc>().add(
      UpdateTimeLineDetailsEvent(name: _nameController.text.trim(), accentColor: _accentColor),
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Linha do tempo atualizada.')));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final accent = _accentColor != null ? Color(_accentColor!) : palette.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AccentPreview(accent: accent, name: _nameController.text),
        kSpacerHeight24,
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Nome da linha do tempo',
            prefixIcon: Icon(Icons.drive_file_rename_outline),
          ),
        ),
        kSpacerHeight24,
        Text('Cor de destaque', style: textTheme.titleSmall?.copyWith(color: palette.onSurfaceMuted)),
        kSpacerHeight12,
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _Swatch(
              selected: _accentColor == null,
              background: palette.surfaceAlt,
              onTap: () => setState(() => _accentColor = null),
              child: Icon(Icons.format_color_reset_outlined, size: 20, color: palette.onSurfaceMuted),
            ),
            ..._kAccentColors.map((color) {
              final value = color.toARGB32();
              return _Swatch(
                selected: _accentColor == value,
                background: color,
                onTap: () => setState(() => _accentColor = value),
                child: _accentColor == value ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
              );
            }),
          ],
        ),
        kSpacerHeight24,
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded, size: 20),
            label: const Text('Salvar alterações'),
          ),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.selected,
    required this.background,
    required this.onTap,
    this.locked = false,
    this.child,
  });

  final bool selected;
  final Color background;
  final VoidCallback onTap;
  final bool locked;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: Border.all(color: selected ? palette.onSurface : palette.outline, width: selected ? 3 : 1),
        ),
        child: locked ? Icon(Icons.lock_rounded, color: Colors.white.withValues(alpha: 0.9), size: 18) : child,
      ),
    );
  }
}

/// Row that lets the user set or clear the relationship end date.
/// Dispatches [UpdateRelationshipEndDateEvent] to [SettingsBloc].
class _RelationshipEndDateSection extends StatelessWidget {
  const _RelationshipEndDateSection({required this.timeline});

  final TimeLine timeline;

  Future<void> _pickDate(BuildContext context) async {
    final endDate = timeline.relationshipEndDate;
    final startDate = timeline.relationshipStartDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null && context.mounted) {
      context.read<SettingsBloc>().add(UpdateRelationshipEndDateEvent(date: picked));
    }
  }

  void _clearDate(BuildContext context) {
    context.read<SettingsBloc>().add(UpdateRelationshipEndDateEvent(date: null));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final endDate = timeline.relationshipEndDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          endDate == null ? 'Nenhuma data definida' : DateFormat('dd/MM/yyyy').format(endDate),
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'O contador "Juntos há" usará esta data como fim.',
          style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
        ),
        kSpacerHeight12,
        Row(
          children: [
            Expanded(child: Text('Impedir momentos após essa data', style: textTheme.bodyMedium)),
            Switch.adaptive(
              value: endDate != null && timeline.enforceEndDate,
              onChanged: endDate == null
                  ? null
                  : (value) => context.read<SettingsBloc>().add(
                      UpdateRelationshipEndDateEvent(date: endDate, enforceEndDate: value),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _pickDate(context),
            icon: const Icon(Icons.edit_calendar_outlined, size: 18),
            label: Text(endDate == null ? 'Definir data de término' : 'Alterar data de término'),
          ),
        ),
        if (endDate != null) ...[
          kSpacerHeight8,
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _clearDate(context),
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text('Remover data de término'),
              style: TextButton.styleFrom(foregroundColor: palette.onSurfaceMuted),
            ),
          ),
        ],
      ],
    );
  }
}

/// Live preview that mimics the real timeline header with the chosen accent.
class _AccentPreview extends StatelessWidget {
  const _AccentPreview({required this.accent, required this.name});

  final Color accent;
  final String name;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onAccent = accent.computeLuminance() > 0.55 ? const Color(0xFF2B2330) : Colors.white;
    final secondary = Color.lerp(accent, Colors.white, 0.22) ?? accent;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [accent, secondary]),
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.soft(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_rounded, color: onAccent, size: 20),
              kSpacerWidth8,
              Expanded(
                child: Text(
                  name.trim().isEmpty ? 'Sua linha do tempo' : name.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleLarge?.copyWith(color: onAccent),
                ),
              ),
            ],
          ),
          kSpacerHeight16,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: onAccent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Text(
              'Prévia da cor',
              style: textTheme.bodySmall?.copyWith(color: onAccent, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Per-member access level editor. Shown only when the timeline has >1 member.
/// Every member is listed with their role (Dono / Editor / Somente leitura).
/// Owners can promote a member to owner or toggle editor/viewer; non-owners see
/// the roles read-only.
class _AccessLevelSection extends StatelessWidget {
  const _AccessLevelSection({required this.timeline, required this.emails, required this.currentEmail});

  final TimeLine timeline;
  final List<String> emails;
  final String currentEmail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    final canManage = TimelinePermissions.canManageMembers(timeline, currentEmail);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!canManage)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Somente um dono da linha do tempo pode alterar os níveis de acesso.',
              style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
            ),
          ),
        ...emails.map((email) {
          final role = TimelinePermissions.roleOf(timeline, email);
          final isSelf = email == currentEmail;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isSelf ? '$email (você)' : email,
                        style: textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    kSpacerWidth8,
                    _RoleBadge(role: role),
                  ],
                ),
                if (canManage && role != TimelineRole.owner) ...[
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'editor', label: Text('Editor'), icon: Icon(Icons.edit_outlined, size: 16)),
                      ButtonSegment(
                        value: 'viewer',
                        label: Text('Somente leitura'),
                        icon: Icon(Icons.visibility_outlined, size: 16),
                      ),
                    ],
                    selected: {role == TimelineRole.viewer ? 'viewer' : 'editor'},
                    onSelectionChanged: (selection) {
                      context.read<SettingsBloc>().add(UpdateAccessLevelEvent(email: email, level: selection.first));
                    },
                  ),
                  const SizedBox(height: 6),
                  TextButton.icon(
                    onPressed: () {
                      context.read<SettingsBloc>().add(UpdateAccessLevelEvent(email: email, level: 'owner'));
                    },
                    icon: const Icon(Icons.workspace_premium_outlined, size: 18),
                    label: const Text('Promover a dono'),
                    style: TextButton.styleFrom(foregroundColor: palette.primary),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}

/// Shows who has approved a pending multi-owner deletion and lets the current
/// owner approve or cancel it.
class _PendingDeletionSection extends StatelessWidget {
  const _PendingDeletionSection({required this.timeline, required this.currentEmail});

  final TimeLine timeline;
  final String currentEmail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = context.palette;
    final errorColor = Theme.of(context).colorScheme.error;
    final pending = timeline.pendingDeletion ?? const {};
    final owners = TimelinePermissions.ownerEmails(timeline);
    final alreadyApproved = pending[currentEmail] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...owners.map((owner) {
          final approved = pending[owner] == true;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(
                  approved ? Icons.check_circle : Icons.hourglass_empty_rounded,
                  size: 18,
                  color: approved ? palette.primary : palette.onSurfaceMuted,
                ),
                kSpacerWidth12,
                Expanded(
                  child: Text(
                    owner == currentEmail ? '$owner (você)' : owner,
                    style: textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  approved ? 'Aprovou' : 'Pendente',
                  style: textTheme.bodySmall?.copyWith(color: approved ? palette.primary : palette.onSurfaceMuted),
                ),
              ],
            ),
          );
        }),
        kSpacerHeight12,
        if (!alreadyApproved)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.read<SettingsBloc>().add(ApproveTimelineDeletionEvent()),
              icon: const Icon(Icons.check_rounded, size: 20),
              label: const Text('Aprovar deleção'),
              style: ElevatedButton.styleFrom(backgroundColor: errorColor, foregroundColor: Colors.white),
            ),
          ),
        if (!alreadyApproved) kSpacerHeight8,
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.read<SettingsBloc>().add(RejectTimelineDeletionEvent()),
            icon: const Icon(Icons.close_rounded, size: 20),
            label: const Text('Cancelar deleção'),
          ),
        ),
      ],
    );
  }
}

/// Small pill showing a member's [TimelineRole].
class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final TimelineRole role;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (String label, Color bg, Color fg) = switch (role) {
      TimelineRole.owner => ('Dono', palette.primarySoft, palette.primary),
      TimelineRole.editor => ('Editor', palette.surfaceAlt, palette.onSurfaceMuted),
      TimelineRole.viewer => ('Somente leitura', palette.surfaceAlt, palette.onSurfaceMuted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
