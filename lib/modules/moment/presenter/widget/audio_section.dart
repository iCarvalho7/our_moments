import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../core/utils/string_ext/string_ext.dart';
import '../../../core/utils/theme/app_theme.dart';
import '../bloc/add_or_edit_moment_bloc.dart';

/// Records, plays and removes a single voice note for a moment.
/// Recording is mobile-only; playback (e.g. of an already uploaded note)
/// works everywhere.
class AudioSection extends StatefulWidget {
  const AudioSection({super.key});

  @override
  State<AudioSection> createState() => _AudioSectionState();
}

class _AudioSectionState extends State<AudioSection> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (!await _recorder.hasPermission()) {
        messenger.showSnackBar(const SnackBar(content: Text('Permissão de microfone negada.')));
        return;
      }
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/recado_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
      setState(() => _isRecording = true);
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Não foi possível gravar.')));
    }
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    if (!mounted) return;
    setState(() => _isRecording = false);
    if (path != null) {
      context.read<AddOrEditMomentBloc>().add(AddOrEditMomentEventSetAudio(path: path));
    }
  }

  Future<void> _togglePlay(String audioUrl) async {
    if (_isPlaying) {
      await _player.pause();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }
    await _player.play(audioUrl.isHttpUrl ? UrlSource(audioUrl) : DeviceFileSource(audioUrl));
    if (mounted) setState(() => _isPlaying = true);
  }

  void _remove() {
    _player.stop();
    setState(() => _isPlaying = false);
    context.read<AddOrEditMomentBloc>().add(const AddOrEditMomentEventRemoveAudio());
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
      buildWhen: (p, c) => p.moment.audioUrl != c.moment.audioUrl,
      builder: (context, state) {
        final audioUrl = state.moment.audioUrl;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadii.input),
            ),
            child: audioUrl.isNotEmpty ? _buildPlayer(context, audioUrl) : _buildRecorder(context),
          ),
        );
      },
    );
  }

  Widget _buildRecorder(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    if (kIsWeb) {
      return Row(
        children: [
          Icon(Icons.mic_off_outlined, color: palette.onSurfaceMuted, size: 20),
          kSpacerWidth12,
          Expanded(
            child: Text(
              'Grave um recado de voz pelo app no celular.',
              style: textTheme.bodyMedium?.copyWith(color: palette.onSurfaceMuted),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Icon(
          _isRecording ? Icons.fiber_manual_record : Icons.mic_none_rounded,
          color: _isRecording ? palette.danger : palette.primary,
          size: 22,
        ),
        kSpacerWidth12,
        Expanded(
          child: Text(
            _isRecording ? 'Gravando…' : 'Gravar recado de voz',
            style: textTheme.bodyLarge,
          ),
        ),
        IconButton(
          icon: Icon(
            _isRecording ? Icons.stop_circle_rounded : Icons.mic_rounded,
            color: _isRecording ? palette.danger : palette.primary,
            size: 30,
          ),
          onPressed: _isRecording ? _stopRecording : _startRecording,
        ),
      ],
    );
  }

  Widget _buildPlayer(BuildContext context, String audioUrl) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause_circle_rounded : Icons.play_circle_rounded,
            color: palette.primary,
            size: 34,
          ),
          onPressed: () => _togglePlay(audioUrl),
        ),
        kSpacerWidth8,
        Expanded(child: Text('Recado de voz', style: textTheme.bodyLarge)),
        IconButton(
          icon: Icon(Icons.delete_outline_rounded, color: palette.danger),
          onPressed: _remove,
        ),
      ],
    );
  }
}
