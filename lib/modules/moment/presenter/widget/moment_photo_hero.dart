import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/premium/premium_feature.dart';
import 'package:nossos_momentos/modules/core/premium/premium_service.dart';
import 'package:nossos_momentos/modules/core/premium/widget/premium_gate.dart';
import 'package:nossos_momentos/modules/core/presenter/routes.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/custom_delete_dialog.dart';
import 'package:nossos_momentos/modules/photos/presentation/bloc/photos_bloc.dart';
import 'package:nossos_momentos/modules/stories/domain/entity/story.dart';
import 'package:nossos_momentos/modules/stories/presenter/widget/story_image.dart';

import '../../../core/utils/theme/app_theme.dart';
import '../../domain/entities/moment.dart';
import '../bloc/add_or_edit_moment_bloc.dart';

/// Image-forward header for the moment screen: a full-bleed carousel of the
/// moment's photos (or a type-colored placeholder when empty), with controls to
/// add more and remove the current one. Sits behind the transparent app bar.
class MomentPhotoHero extends StatelessWidget {
  const MomentPhotoHero({super.key, this.height = 360});

  final double height;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PhotosBloc>(),
      child: BlocListener<PhotosBloc, PhotosState>(
        listener: (context, state) {
          if (state is PhotosStateMediaFound) {
            context.read<AddOrEditMomentBloc>().add(
                  AddOrEditMomentEventAddMedia(
                    medias: state.mediaFound.map((e) => e.url).toList(),
                  ),
                );
          }
        },
        child: BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
          buildWhen: (p, c) =>
              p.moment.downloadUrlList.length != c.moment.downloadUrlList.length ||
              p.moment.type != c.moment.type,
          builder: (context, state) {
            final photos = state.moment.downloadUrlList;
            return SizedBox(
              height: height,
              width: double.infinity,
              child: photos.isEmpty
                  ? _Placeholder(moment: state.moment)
                  : _Carousel(photos: photos),
            );
          },
        ),
      ),
    );
  }
}

/// Empty-state hero: a soft gradient tinted by the selected moment type, with a
/// centered "add photos" affordance.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.moment});

  final Moment moment;

  @override
  Widget build(BuildContext context) {
    final colors = moment.type.colors(context);
    return GestureDetector(
      onTap: () => context.read<PhotosBloc>().add(PhotosEventOpenGallery()),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.bg, colors.accent.withValues(alpha: 0.35)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_a_photo_rounded, color: colors.accent, size: 30),
              ),
              kSpacerHeight12,
              Text(
                'Adicionar fotos e vídeos',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colors.onBg,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Carousel extends StatefulWidget {
  const _Carousel({required this.photos});

  final List<String> photos;

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addPhotos(BuildContext context) {
    // Free tier caps photos per moment; over the limit, show the premium CTA.
    if (widget.photos.length >= getIt<PremiumService>().maxPhotosPerMoment) {
      showPremiumPlaceholder(context, PremiumFeature.unlimitedPhotos);
      return;
    }
    context.read<PhotosBloc>().add(PhotosEventOpenGallery());
  }

  void _confirmDelete(String photo) {
    CustomDeleteDialog.show(
      context,
      text: 'Deseja remover essa mídia?',
      onTapPositive: () {
        context.read<AddOrEditMomentBloc>().add(AddOrEditMomentEventDeletePhoto(photo: photo));
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    final safePage = _page.clamp(0, photos.length - 1);

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: photos.length,
          onPageChanged: (i) => setState(() => _page = i),
          itemBuilder: (context, index) => GestureDetector(
            onTap: () => _openStory(index),
            onLongPress: () => _confirmDelete(photos[index]),
            child: _Media(url: photos[index]),
          ),
        ),

        // Bottom scrim so controls/thumbnails stay legible over bright photos.
        const _BottomScrim(),

        // Photo count badge (top, under the app bar) — makes it obvious there
        // is more than one photo.
        if (photos.length > 1)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_library_rounded, color: Colors.white, size: 13),
                  kSpacerWidth8,
                  Text(
                    '${safePage + 1}/${photos.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Thumbnail strip (jump to any photo) + add/remove controls.
        Positioned(
          left: 12,
          right: 12,
          bottom: 30,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (photos.length > 1)
                Expanded(
                  child: _ThumbStrip(
                    photos: photos,
                    current: safePage,
                    onTap: _goToPage,
                  ),
                )
              else
                const Spacer(),
              kSpacerWidth8,
              _HeroButton(
                icon: Icons.delete_outline_rounded,
                onTap: () => _confirmDelete(photos[safePage]),
              ),
              kSpacerWidth8,
              _HeroButton(
                icon: Icons.add_photo_alternate_rounded,
                onTap: () => _addPhotos(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _goToPage(int i) {
    _controller.animateToPage(
      i,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  /// Opens the full-screen Instagram-style story viewer at [index].
  void _openStory(int index) {
    Navigator.pushNamed(
      context,
      AppRoute.story.tag,
      arguments: {
        'list': widget.photos,
        'index': index,
      },
    );
  }
}

/// Horizontal strip of photo thumbnails; the active one is highlighted and
/// tapping any jumps the carousel to it.
class _ThumbStrip extends StatelessWidget {
  const _ThumbStrip({required this.photos, required this.current, required this.onTap});

  final List<String> photos;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, __) => kSpacerWidth8,
        itemBuilder: (context, index) {
          final selected = index == current;
          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? Colors.white : Colors.white.withValues(alpha: 0.35),
                  width: selected ? 2.5 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _Media(url: photos[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Media extends StatelessWidget {
  const _Media({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final story = Story(url: url);
    if (story.type == StoryType.video) {
      return Container(
        color: Colors.black87,
        child: const Center(
          child: Icon(Icons.play_circle_outline_rounded, color: Colors.white, size: 56),
        ),
      );
    }
    // image or undefined (e.g. no extension / legacy Firebase path) — attempt
    // to render as image with a neutral fallback on error.
    return StoryImage(url: url, fit: BoxFit.cover);
  }
}

class _BottomScrim extends StatelessWidget {
  const _BottomScrim();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.35)],
          ),
        ),
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
