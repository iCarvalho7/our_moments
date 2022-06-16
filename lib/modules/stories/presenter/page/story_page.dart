import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/utils/string_ext/string_ext.dart';
import 'package:nossos_momentos/modules/stories/domain/story.dart';
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
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
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
            builder: (context, state) {
              if (state is StoryStateLoaded) {
                return _buildPage(state);
              } else {
                return const SizedBox.shrink();
              }
            }),
      ),
    );
  }

  Stack _buildPage(StoryStateLoaded state) {
    return Stack(
      children: [
        SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: FittedBox(
            child: !state.story.isNetwork
                ? Image.file(File(state.story.url))
                : Image.network(state.story.url),
            fit: BoxFit.cover,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 6),
          child: LinearProgressIndicator(
            value: controller.value,
            color: Colors.white,
            backgroundColor: const Color(0xFFBFBFBF),
          ),
        ),
      ],
    );
  }

  void _handleState(BuildContext context, StoryState state) {
    if (state is StoryStateLoaded) {
      controller.reset();
      controller.forward();
    }

    if(state is StoryStateFinished){
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
        stories: list.map(
              (path) => Story(
                url: path,
                isNetwork: path.isHttpUrl(),
              ),
            ).toList(),
      ),
    );
  }
}
