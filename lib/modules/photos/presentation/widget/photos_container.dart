import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/loading_effect.dart';
import 'package:nossos_momentos/modules/core/utils/string_ext/string_ext.dart';
import 'package:video_player/video_player.dart';
import '../../../core/presenter/widgets/custom_delete_dialog.dart';
import '../../../moment/presenter/bloc/add_or_edit_moment_bloc.dart';
import '../../../stories/domain/entity/story.dart';
import '../bloc/photos_bloc.dart';
import '../../../core/presenter/routes.dart';
import '../../../core/presenter/widgets/gradient_mask.dart';
import '../../../core/utils/theme/app_theme.dart';

class PhotosContainer extends StatelessWidget {
  const PhotosContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PhotosBloc>(),
      child: BlocListener<PhotosBloc, PhotosState>(
        listener: _handleStateChanges,
        child: Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(left: 16.0),
          padding: const EdgeInsets.only(top: 16.0),
          child: BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
            builder: (context, state) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _AddPhotoIcon(),
                    SizedBox(
                      height: kToolbarHeight,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: state.moment.downloadUrlList.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return _StorySection(
                            storyUrl: state.moment.downloadUrlList[index],
                            index: index,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, PhotosState state) {
    if (state is PhotosStateMediaFound) {
      context
          .read<AddOrEditMomentBloc>()
          .add(AddOrEditMomentEventAddMedia(medias: state.mediaFound.map((e) => e.url).toList()));
    }
  }
}

class _StorySection extends StatefulWidget {
  const _StorySection({required this.storyUrl, required this.index});

  final String storyUrl;
  final int index;

  @override
  State<_StorySection> createState() => _StorySectionState();
}

class _StorySectionState extends State<_StorySection> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.storyUrl.isHttpUrl
        ? VideoPlayerController.networkUrl(Uri.parse(widget.storyUrl))
        : VideoPlayerController.file(File(widget.storyUrl));
    _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showDeleteDialog(context),
      onTap: () => _goToStoryPage(context),
      child: _ColoredContainer(
        child: _createMedia(context),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    CustomDeleteDialog.show(
      context,
      text: 'Deseja deletar essa foto?',
      onTapPositive: () {
        final photo =
            context.read<AddOrEditMomentBloc>().state.moment.downloadUrlList[widget.index];
        context.read<AddOrEditMomentBloc>().add(AddOrEditMomentEventDeletePhoto(photo: photo));
        Navigator.pop(context);
      },
    );
  }

  void _goToStoryPage(BuildContext context) {
    Navigator.pushNamed(context, AppRoute.story.tag, arguments: {
      'list': context.read<AddOrEditMomentBloc>().state.moment.downloadUrlList,
      'index': widget.index,
    });
  }

  Widget _createMedia(BuildContext context) {
    final story = Story(url: widget.storyUrl);
    switch (story.type) {
      case StoryType.video:
        return VideoPlayer(_controller);
      case StoryType.image:
        return !story.isNetwork
            ? Image.file(File(story.url), fit: BoxFit.fitWidth)
            : Image.network(
                story.url,
                fit: BoxFit.fitWidth,
                loadingBuilder: (_, widget, event) {
                  if (event == null) return widget;
                  return ClipOval(
                    child: LoadingEffect(
                      child: Container(
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              );
      case StoryType.undefined:
        return const Placeholder();
    }
  }
}

class _AddPhotoIcon extends StatelessWidget {
  const _AddPhotoIcon();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => BlocProvider.of<PhotosBloc>(context).add(PhotosEventOpenGallery()),
      child: const _ColoredContainer(
        child: GradientMask(
          colors: AppColors.instagramGradient,
          child: Icon(
            Icons.add_photo_alternate,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _ColoredContainer extends StatelessWidget {
  const _ColoredContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      decoration: AppThemes.coloredBorder,
      height: kToolbarHeight,
      width: kToolbarHeight,
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(40),
        ),
        child: ClipOval(child: child),
      ),
    );
  }
}
