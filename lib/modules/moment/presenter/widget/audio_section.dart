import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../core/premium/premium_feature.dart';
import '../../../core/premium/widget/premium_gate.dart';
import '../../../core/utils/string_ext/string_ext.dart';
import '../../../core/utils/theme/app_theme.dart';
import '../bloc/add_or_edit_moment_bloc.dart';

/// Records, plays and removes a single voice note for a moment.
/// Recording works on mobile (records to a temp file) and on web (records to
/// an in-memory blob that is later read as bytes and uploaded).
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

  /// Live microphone level bars (||||). Each value is a 0..1 loudness sample;
  /// the list scrolls left as new samples arrive while recording.
  static const int _barCount = 28;
  // Amplitude arrives in dBFS. Real web-mic speech sits roughly between these
  // two values, so we map that window to the full bar height — a wider floor
  // (e.g. -160..0) would squash normal speech into a nearly flat line.
  static const double _minDb = -55.0;
  static const double _maxDb = -18.0;
  final List<double> _levels = List<double>.filled(_barCount, 0.0);
  StreamSubscription<Amplitude>? _amplitudeSub;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _amplitudeSub?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  void _onAmplitude(Amplitude amp) {
    if (!mounted) return;
    // `current` is in dBFS (can be -Infinity at full silence): ~0 is loud, very
    // negative is silence. Map the speech window to 0..1.
    final raw = (amp.current - _minDb) / (_maxDb - _minDb);
    final level = raw.isNaN ? 0.0 : raw.clamp(0.0, 1.0);
    setState(() {
      _levels.removeAt(0);
      _levels.add(level);
    });
  }

  void _resetLevels() {
    for (var i = 0; i < _levels.length; i++) {
      _levels[i] = 0.0;
    }
  }

  Future<void> _startRecording() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (!await _recorder.hasPermission()) {
        messenger.showSnackBar(const SnackBar(content: Text('Permissão de microfone negada.')));
        return;
      }
      if (kIsWeb) {
        // No file system on web: record to an in-memory blob. Most browsers
        // record opus/webm, but Safari only supports AAC/mp4 — so probe the
        // encoder and fall back instead of assuming a format. `path` is ignored
        // by the web impl.
        final encoder = await _recorder.isEncoderSupported(AudioEncoder.opus)
            ? AudioEncoder.opus
            : AudioEncoder.aacLc;
        await _recorder.start(RecordConfig(encoder: encoder), path: '');
      } else {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/recado_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
      }
      _resetLevels();
      _amplitudeSub?.cancel();
      _amplitudeSub = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 80))
          .listen(_onAmplitude);
      setState(() => _isRecording = true);
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Não foi possível gravar.')));
    }
  }

  Future<void> _stopRecording() async {
    await _amplitudeSub?.cancel();
    _amplitudeSub = null;
    final path = await _recorder.stop();
    if (!mounted) return;
    setState(() {
      _isRecording = false;
      _resetLevels();
    });
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

    return Row(
      children: [
        Icon(
          _isRecording ? Icons.fiber_manual_record : Icons.mic_none_rounded,
          color: _isRecording ? palette.danger : palette.primary,
          size: 22,
        ),
        kSpacerWidth12,
        Expanded(
          child: _isRecording
              ? _buildWaveform(palette)
              : Text('Gravar recado de voz', style: textTheme.bodyLarge),
        ),
        PremiumGate(
          feature: PremiumFeature.voiceNotes,
          child: IconButton(
            icon: Icon(
              _isRecording ? Icons.stop_circle_rounded : Icons.mic_rounded,
              color: _isRecording ? palette.danger : palette.primary,
              size: 30,
            ),
            onPressed: _isRecording ? _stopRecording : _startRecording,
          ),
        ),
      ],
    );
  }

  /// Real-time microphone level visualizer — a row of bars (||||) whose
  /// heights follow the live loudness and scroll left as recording continues.
  Widget _buildWaveform(AppPalette palette) {
    return SizedBox(
      height: 30,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final level in _levels)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  height: 4 + level * 24,
                  decoration: BoxDecoration(
                    color: palette.primary.withValues(alpha: 0.35 + level * 0.65),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
        ],
      ),
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
