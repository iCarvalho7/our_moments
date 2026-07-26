// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/stories/domain/entity/story.dart';
import 'package:nossos_momentos/modules/stories/presenter/widget/story_image.dart';
import 'package:video_player/video_player.dart';

import '../bloc/story_bloc.dart';

class StoryPage extends StatelessWidget {
  const StoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<StoryBloc>(),
      child: const _StoryPage(),
    );
  }
}

class _StoryPage extends StatefulWidget {
  const _StoryPage();

  @override
  State<_StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<_StoryPage> with TickerProviderStateMixin {
  AnimationController? controller;
  VideoPlayerController? _videoPlayerController;
  // True while the photo is pinch-zoomed. In this state the story timer is
  // paused and left/right tap navigation is suppressed so panning around the
  // zoomed image does not jump to the next/previous story.
  bool _isImageZoomed = false;

  void _handleZoomChanged(bool zoomed) {
    _isImageZoomed = zoomed;
    if (zoomed) {
      controller?.stop(canceled: false);
    } else {
      controller?.forward(from: controller?.value ?? 0);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _setUpArgs();
    });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No outer SafeArea: the media is full-bleed (edge-to-edge, under the status
    // bar/notch) like an Instagram story. Only the controls respect the safe
    // area, inside _buildPage.
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<StoryBloc, StoryState>(
        listener: _handleState,
        buildWhen: (_, state) => state is! StoryStatePause,
        builder: (context, state) {
          if (state is StoryStateSetUpControllers) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (state is StoryStateLoaded) {
            return _buildPage(state, context);
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildPage(StoryStateLoaded state, BuildContext context) {
    return GestureDetector(
      onLongPressUp: () async {
        await _videoPlayerController?.play();
        controller?.forward(from: controller!.value);
      },
      onLongPress: () async {
        await _videoPlayerController?.pause();
        controller?.stop(canceled: false);
      },
      onTapUp: (details) {
        if (_isImageZoomed) return;
        final width = MediaQuery.of(context).size.width;
        if (details.globalPosition.dx < width / 3) {
          context.read<StoryBloc>().add(const StoryEventPreviousStory());
        } else {
          context.read<StoryBloc>().add(const StoryEventNextStory());
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          _MediaSection(
            story: state.story,
            controller: controller,
            videoController: _videoPlayerController,
            onZoomChanged: _handleZoomChanged,
          ),
          Positioned(
            top: 0,
            left: 5.0,
            right: 5.0,
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: state.stories
                        .asMap()
                        .map((i, e) {
                          return MapEntry(
                            i,
                            _AnimatedBar(
                              animController: controller,
                              position: i,
                              currentIndex: state.stories.indexOf(state.story),
                            ),
                          );
                        })
                        .values
                        .toList(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleState(BuildContext context, StoryState state) async {
    if (state is StoryStateSetUpControllers) {
      await _videoPlayerController?.dispose();
      _videoPlayerController = null;

      if (state.story.type == StoryType.video) {
        _videoPlayerController =
            state.story.isNetwork || state.story.url.startsWith('data:')
            ? VideoPlayerController.networkUrl(Uri.parse(state.story.url))
            : VideoPlayerController.file(File(state.story.url));
        await _videoPlayerController!.initialize();
        if (!mounted) return;
      }

      controller?.dispose();
      final newCtrl = AnimationController(
        vsync: this,
        duration:
            _videoPlayerController?.value.duration ??
            const Duration(seconds: 4),
      );
      controller = newCtrl;
      newCtrl.addStatusListener((status) {
        if (status == AnimationStatus.completed && newCtrl == controller) {
          context.read<StoryBloc>().add(const StoryEventNextStory());
        }
      });

      if (state.story.type == StoryType.video) {
        await _videoPlayerController!.play();
        if (!mounted) return;
        newCtrl.forward();
      }

      _start(context, state);
    }

    if (state is StoryStateFinished) {
      if (!context.mounted) return;
      Navigator.pop(context);
    }
  }

  void _start(BuildContext context, StoryStateSetUpControllers state) {
    context.read<StoryBloc>().add(
      StoryEventPlay(currentStory: state.story, stories: state.stories),
    );
  }

  void _setUpArgs() {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final list = args['list'] as List<String>;
    final currentIndex = args['index'] as int;
    context.read<StoryBloc>().add(
      StoryEventInit(currentIndex: currentIndex, stories: list),
    );
  }
}

class _MediaSection extends StatefulWidget {
  final Story story;
  final AnimationController? controller;
  final VideoPlayerController? videoController;

  /// Called when the photo crosses in/out of the zoomed state (scale > 1).
  final ValueChanged<bool>? onZoomChanged;

  const _MediaSection({
    required this.story,
    required this.controller,
    required this.videoController,
    this.onZoomChanged,
  });

  @override
  State<_MediaSection> createState() => _MediaSectionState();
}

class _MediaSectionState extends State<_MediaSection> {
  ImageStreamListener? _imageListener;
  ImageStream? _imageStream;
  bool _animationStarted = false;

  final TransformationController _transformationController =
      TransformationController();
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformChanged);
    _attachImageListener();
  }

  @override
  void didUpdateWidget(_MediaSection old) {
    super.didUpdateWidget(old);
    if (old.story.url != widget.story.url || old.controller != widget.controller) {
      // Reset zoom so a newly shown photo always starts fit-to-screen.
      _transformationController.value = Matrix4.identity();
      _detachImageListener();
      _animationStarted = false;
      _attachImageListener();
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    _detachImageListener();
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    final zoomed = scale > 1.01;
    if (zoomed != _isZoomed) {
      _isZoomed = zoomed;
      widget.onZoomChanged?.call(zoomed);
    }
  }

  void _attachImageListener() {
    // Both image and undefined types need the listener; undefined covers legacy
    // Firebase paths that have no recognizable file extension.
    if (widget.story.type == StoryType.video) return;
    final provider = storyImageProvider(widget.story.url);
    if (provider == null) return;
    _imageListener = ImageStreamListener(
      (_, __) {
        if (!_animationStarted) {
          _animationStarted = true;
          widget.controller?.forward();
        }
      },
      onError: (_, __) {
        // Image failed to load — advance the story timer anyway.
        if (!_animationStarted) {
          _animationStarted = true;
          widget.controller?.forward();
        }
      },
    );
    _imageStream = provider.resolve(const ImageConfiguration());
    _imageStream!.addListener(_imageListener!);
  }

  void _detachImageListener() {
    if (_imageListener != null) {
      _imageStream?.removeListener(_imageListener!);
      _imageListener = null;
      _imageStream = null;
    }
  }

  Widget _buildImageWidget(ImageProvider provider) {
    return ColoredBox(
      color: Colors.black,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0,
        maxScale: 4.0,
        child: Image(
          image: provider,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, event) {
            if (event == null) return child;
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: Colors.white,
              ),
            );
          },
          errorBuilder: (_, __, ___) => const _ImageErrorBox(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.story.type) {
      case StoryType.video:
        return VideoPlayer(widget.videoController!);
      case StoryType.image:
      case StoryType.undefined:
        // undefined = no recognizable extension (legacy Firebase path, etc.) —
        // attempt to render as image, matching the thumbnail carousel's fallback.
        final provider = storyImageProvider(widget.story.url);
        if (provider == null) return const _ImageErrorBox();
        return _buildImageWidget(provider);
    }
  }
}

class _ImageErrorBox extends StatelessWidget {
  const _ImageErrorBox();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black,
      child: Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.white38, size: 48),
      ),
    );
  }
}

class _AnimatedBar extends StatelessWidget {
  final AnimationController? animController;
  final int position;
  final int currentIndex;

  const _AnimatedBar({
    required this.animController,
    required this.position,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                _buildContainer(
                  double.infinity,
                  position < currentIndex
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                ),
                position == currentIndex
                    ? AnimatedBuilder(
                        animation: animController!,
                        builder: (context, child) {
                          return _buildContainer(
                            constraints.maxWidth * animController!.value,
                            Colors.white,
                          );
                        },
                      )
                    : const SizedBox.shrink(),
              ],
            );
          },
        ),
      ),
    );
  }

  Container _buildContainer(double width, Color color) {
    return Container(
      height: 5.0,
      width: width,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black26, width: 0.8),
        borderRadius: BorderRadius.circular(3.0),
      ),
    );
  }
}
