// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/stories/domain/entity/story.dart';
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
    return SafeArea(
      child: Scaffold(
        body: BlocConsumer<StoryBloc, StoryState>(
          listener: _handleState,
          buildWhen: (_, state) => state is! StoryStatePause,
          builder: (context, state) {
            if (state is StoryStateSetUpControllers) {
              return Container(
                alignment: Alignment.center,
                color: Colors.grey,
                child: const CircularProgressIndicator(),
              );
            }
            if (state is StoryStateLoaded) {
              return _buildPage(state, context);
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
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
      onTap: () => context.read<StoryBloc>().add(const StoryEventNextStory()),
      child: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: _MediaSection(
              story: state.story,
              controller: controller,
              videoController: _videoPlayerController,
            ),
          ),
          Positioned(
            top: 10.0,
            left: 5.0,
            right: 5.0,
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
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleState(BuildContext context, StoryState state) async {
    if (state is StoryStateSetUpControllers) {
      if (state.story.type == StoryType.video) {
        _videoPlayerController = state.story.isNetwork
            ? VideoPlayerController.networkUrl(Uri.parse(state.story.url))
            : VideoPlayerController.file(File(state.story.url));
        await _videoPlayerController!.initialize();
        await _videoPlayerController!.play();
      }

      controller = AnimationController(
        vsync: this,
        duration: _videoPlayerController?.value.duration ?? const Duration(seconds: 4),
      )..addStatusListener(
          (status) {
            if (status == AnimationStatus.completed && controller?.toStringDetails() != 'DISPOSED') {
              context.read<StoryBloc>().add(const StoryEventNextStory());
            }
          },
        );

      if (state.story.type == StoryType.video) {
        if (!_videoPlayerController!.value.isPlaying) {
          await _videoPlayerController!.play();
        }
        controller!.forward();
      }

      _start(context, state);
    }

    if (state is StoryStateFinished) {
      if (!context.mounted) return;
      Navigator.pop(context);
    }
  }

  void _start(BuildContext context, StoryStateSetUpControllers state) {
    context
        .read<StoryBloc>()
        .add(StoryEventPlay(currentStory: state.story, stories: state.stories));
  }

  void _setUpArgs() {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final list = args['list'] as List<String>;
    final currentIndex = args['index'] as int;
    context.read<StoryBloc>().add(StoryEventInit(currentIndex: currentIndex, stories: list));
  }
}

class _MediaSection extends StatelessWidget {
  final Story story;
  final AnimationController? controller;
  final VideoPlayerController? videoController;

  const _MediaSection({
    required this.story,
    required this.controller,
    required this.videoController,
  });

  @override
  Widget build(BuildContext context) {
    switch (story.type) {
      case StoryType.video:
        return VideoPlayer(videoController!);
      case StoryType.image:
        return FittedBox(
          fit: BoxFit.cover,
          child: !story.isNetwork
              ? Image.file(File(story.url))
              : Image.network(
                  story.url,
                  loadingBuilder: (context, widget, event) {
                    if (event == null) return widget;
                    return Container(
                      color: Colors.grey,
                      padding: const EdgeInsets.all(250),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: Colors.white,
                      ),
                    );
                  },
                )
            ..image.resolve(const ImageConfiguration()).addListener(
                  ImageStreamListener((__, _) => controller?.forward()),
                ),
        );
      case StoryType.undefined:
        return const Placeholder();
    }
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
                  position < currentIndex ? Colors.white : Colors.white.withOpacity(0.5),
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
        border: Border.all(
          color: Colors.black26,
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(3.0),
      ),
    );
  }
}
