import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/premium/premium_feature.dart';
import 'package:nossos_momentos/modules/core/premium/premium_service.dart';
import 'package:nossos_momentos/modules/core/premium/widget/premium_gate.dart';
import 'package:nossos_momentos/modules/core/utils/string_ext/string_ext.dart';
import 'package:nossos_momentos/modules/stories/presenter/widget/story_image.dart';
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
    final story = Story(url: widget.storyUrl);
    if (story.type == StoryType.video) {
      // Data URLs (web) and remote URLs both go through the network controller;
      // only a real file path uses the file controller (mobile).
      _controller = widget.storyUrl.isHttpUrl || widget.storyUrl.startsWith('data:')
          ? VideoPlayerController.networkUrl(Uri.parse(widget.storyUrl))
          : VideoPlayerController.file(File(widget.storyUrl));
      _controller.initialize();
    }
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
        return StoryImage(url: story.url, fit: BoxFit.fitWidth);
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
      onTap: () => _onTap(context),
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

  void _onTap(BuildContext context) {
    // Free tier caps photos per moment; over the limit, show the premium CTA.
    final count = context.read<AddOrEditMomentBloc>().state.moment.downloadUrlList.length;
    if (count >= getIt<PremiumService>().maxPhotosPerMoment) {
      showPremiumPlaceholder(context, PremiumFeature.unlimitedPhotos);
      return;
    }
    BlocProvider.of<PhotosBloc>(context).add(PhotosEventOpenGallery());
  }
}

class _ColoredContainer extends StatelessWidget {
  const _ColoredContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final surface = context.palette.surface;
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      decoration: AppThemes.coloredBorder,
      height: kToolbarHeight,
      width: kToolbarHeight,
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: surface,
          border: Border.all(color: surface),
          shape: BoxShape.circle,
        ),
        child: ClipOval(child: child),
      ),
    );
  }
}
