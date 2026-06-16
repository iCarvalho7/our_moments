import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/loading_effect.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/primary_app_bar.dart';
import 'package:nossos_momentos/modules/login/presentation/widget/login_text_field.dart';
import 'package:nossos_momentos/modules/settings/presentation/bloc/settings_bloc.dart';
import 'package:nossos_momentos/modules/time_line/domain/entity/time_line.dart';

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

  @override
  Widget build(BuildContext context) {
    final timeLineId = ModalRoute.of(context)?.settings.arguments as String;

    return BlocProvider<SettingsBloc>(
      create: (context) => getIt<SettingsBloc>()..add(FetchEmailEvent(timeLineId: timeLineId)),
      child: Stack(
        children: [
          const BackgroundGradient(),
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return SafeArea(
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: PrimaryAppBar(title: 'Gerenciar acesso'),
                  body: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Builder(
                      builder: (_) {
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
              );
            },
          )
        ],
      ),
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    final surface = context.palette.surface;
    BoxDecoration deco() => BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
        );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoadingEffect(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 260,
              decoration: deco(),
            ),
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
  const _SuccessContent({
    required this.state,
    required this.timeline,
    required this.usernameController,
  });

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
            child: _AccessList(
              emails: emails,
              state: state,
              usernameController: usernameController,
            ),
          ),
        ],
      ),
    );
  }
}

/// A titled rounded card grouping a settings area.
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
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
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(color: palette.onSurfaceMuted),
                    ),
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
  const _AccessList({
    required this.emails,
    required this.state,
    required this.usernameController,
  });

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
          final isOwner = item == state.timeLine?.owner;
          final isSelf = item == state.email;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadii.input),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: palette.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    item.isNotEmpty ? item[0].toUpperCase() : '?',
                    style: textTheme.titleSmall?.copyWith(
                      color: palette.primary,
                      fontWeight: FontWeight.w700,
                    ),
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
  late final TextEditingController _nameController =
      TextEditingController(text: widget.timeline.name);
  late int? _accentColor = widget.timeline.accentColor;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    context.read<SettingsBloc>().add(UpdateTimeLineDetailsEvent(
          name: _nameController.text.trim(),
          accentColor: _accentColor,
        ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Linha do tempo atualizada.')),
    );
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
        Text(
          'Cor de destaque',
          style: textTheme.titleSmall?.copyWith(color: palette.onSurfaceMuted),
        ),
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
                child: _accentColor == value
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
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
    this.child,
  });

  final bool selected;
  final Color background;
  final VoidCallback onTap;
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
          border: Border.all(
            color: selected ? palette.onSurface : palette.outline,
            width: selected ? 3 : 1,
          ),
        ),
        child: child,
      ),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent, secondary],
        ),
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
