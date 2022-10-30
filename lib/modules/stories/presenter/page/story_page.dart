import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/stories/presenter/bloc/story_bloc.dart';
import 'package:nossos_momentos/modules/stories/presenter/bloc/story_event.dart';
import 'package:nossos_momentos/modules/stories/presenter/bloc/story_state.dart';

class StoryPage extends StatefulWidget {
  const StoryPage({Key? key}) : super(key: key);

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> with TickerProviderStateMixin {
  late AnimationController controller;
  final StoryBloc storyBloc = getIt<StoryBloc>();

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          storyBloc.add(const StoryEventNextStory());
        }
      });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _setUpArgs();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocConsumer<StoryBloc, StoryState>(
            bloc: storyBloc,
            listener: _handleState,
            buildWhen: (_, state) => state is! StoryStatePause,
            builder: (context, state) {
              if (state is StoryStateLoaded) {
                return _buildPage(state, context);
              } else {
                return const SizedBox.shrink();
              }
            }),
      ),
    );
  }

  Widget _buildPage(StoryStateLoaded state, BuildContext context) {
    return GestureDetector(
      onLongPressUp:() => controller.forward(from: controller.value),
      onLongPress: () => controller.stop(canceled: false),
      onTap: () => storyBloc.add(const StoryEventNextStory()),
      child: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.cover,
              child: !state.story.isNetwork
                  ? Image.file(File(state.story.url))
                  : Image.network(state.story.url)
                ..image.resolve(const ImageConfiguration()).addListener(
                      ImageStreamListener((__, _) => controller.forward()),
                    ),
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
                  icon: const Icon(Icons.clear, color: Colors.white,),
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

  void _handleState(BuildContext context, StoryState state) {
    if (state is StoryStateLoaded) {
      controller.reset();
    }

    if (state is StoryStatePause) {
    }

    if (state is StoryStateFinished) {
      Navigator.pop(context);
    }
  }

  void _setUpArgs() {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final list = args['list'] as List<String>;
    final currentIndex = args['index'] as int;
    storyBloc.add(
      StoryEventInit(
        currentIndex: currentIndex,
        stories: list,
      ),
    );
  }
}

class _AnimatedBar extends StatelessWidget {
  final AnimationController animController;
  final int position;
  final int currentIndex;

  const _AnimatedBar({
    Key? key,
    required this.animController,
    required this.position,
    required this.currentIndex,
  }) : super(key: key);

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
                      : Colors.white.withOpacity(0.5),
                ),
                position == currentIndex
                    ? AnimatedBuilder(
                        animation: animController,
                        builder: (context, child) {
                          return _buildContainer(
                            constraints.maxWidth * animController.value,
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
