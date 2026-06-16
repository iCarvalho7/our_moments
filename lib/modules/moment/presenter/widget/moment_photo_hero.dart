import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/custom_delete_dialog.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/loading_effect.dart';
import 'package:nossos_momentos/modules/photos/presentation/bloc/photos_bloc.dart';
import 'package:nossos_momentos/modules/stories/domain/entity/story.dart';

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
            onLongPress: () => _confirmDelete(photos[index]),
            child: _Media(url: photos[index]),
          ),
        ),

        // Bottom scrim so controls/dots stay legible over bright photos.
        const _BottomScrim(),

        // Page dots.
        if (photos.length > 1)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(photos.length, (i) {
                final active = i == safePage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: active ? 0.95 : 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),

        // Add / remove controls.
        Positioned(
          right: 16,
          bottom: 36,
          child: Row(
            children: [
              _HeroButton(
                icon: Icons.delete_outline_rounded,
                onTap: () => _confirmDelete(photos[safePage]),
              ),
              kSpacerWidth8,
              _HeroButton(
                icon: Icons.add_photo_alternate_rounded,
                onTap: () => context.read<PhotosBloc>().add(PhotosEventOpenGallery()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Media extends StatelessWidget {
  const _Media({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final story = Story(url: url);
    switch (story.type) {
      case StoryType.image:
        return story.isNetwork
            ? Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, event) =>
                    event == null ? child : LoadingEffect(child: Container(color: Colors.grey)),
              )
            : Image.file(File(url), fit: BoxFit.cover);
      case StoryType.video:
        return Container(
          color: Colors.black87,
          child: const Center(
            child: Icon(Icons.play_circle_outline_rounded, color: Colors.white, size: 56),
          ),
        );
      case StoryType.undefined:
        return Container(color: context.palette.surfaceAlt);
    }
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
