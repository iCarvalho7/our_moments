import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_bloc.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_event.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/photos_bloc.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/photos_event.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/photos_state.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/widget/colored_container.dart';
import 'package:nossos_momentos/modules/core/presenter/routes.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/gradient_mask.dart';
import 'package:nossos_momentos/modules/core/utils/string_ext/string_ext.dart';
import 'package:nossos_momentos/modules/core/utils/theme/app_theme.dart';

class PhotosContainer extends StatefulWidget {
  const PhotosContainer({Key? key}) : super(key: key);

  @override
  State<PhotosContainer> createState() => _PhotosContainerState();
}

class _PhotosContainerState extends State<PhotosContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(top: 10.0),
      child: BlocConsumer<PhotosBloc, PhotosState>(
          listener: _handleStateChanges,
          builder: (context, state) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AddPhotoIcon(),
                  _buildHistoryList(state),
                ],
              ),
            );
          }),
    );
  }

  void _handleStateChanges(BuildContext context, PhotosState state) async {
    if (state is PhotosStateShowGallery) {
      final _picker = ImagePicker();
      final photos = await _picker.pickMultiImage();
      if (photos != null) {
        final pathList = photos.map((e) => e.path).toList();
        BlocProvider.of<PhotosBloc>(context).add(
          PhotosEventAddPhotos(photos: pathList),
        );

        BlocProvider.of<AddOrEditMomentBloc>(context)
            .add(AddOrEditMomentEventAddPhoto(photos: pathList));
      }
    }
  }

  Widget _buildHistoryList(PhotosState state) {
    if (state is PhotosStateUpdateHistory) {
      return SizedBox(
        height: 55,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: state.photos.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoute.story.tag, arguments: {
                  'list': state.photos,
                  'index': index,
                });
              },
              child: ColoredContainer(
                child: !state.photos[index].isHttpUrl()
                    ? Image.file(
                        File(state.photos[index]),
                        fit: BoxFit.fitWidth,
                      )
                    : Image.network(
                        state.photos[index],
                        fit: BoxFit.fitWidth,
                      ),
              ),
            );
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

class _AddPhotoIcon extends StatelessWidget {
  const _AddPhotoIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          BlocProvider.of<PhotosBloc>(context).add(PhotosEventOpenGallery()),
      child: const ColoredContainer(
        child: GradientMask(
          child: Icon(
            Icons.add_photo_alternate,
            color: Colors.white,
            size: 30,
          ),
          colors: AppColors.instagramGradient,
        ),
      ),
    );
  }
}
