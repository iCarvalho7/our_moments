import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nossos_momentos/di/injection.dart';
import 'package:nossos_momentos/modules/core/presenter/widgets/loading_effect.dart';
import '../../../core/presenter/widgets/custom_delete_dialog.dart';
import '../bloc/add_or_edit_moment_bloc.dart';
import '../bloc/photos_bloc.dart';
import '../../../core/utils/string_ext/string_ext.dart';
import '../../../core/presenter/routes.dart';
import '../../../core/presenter/widgets/gradient_mask.dart';
import '../../../core/utils/theme/app_theme.dart';

class PhotosContainer extends StatelessWidget {
  const PhotosContainer({Key? key}) : super(key: key);

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
                    _buildHistoryList(state),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, PhotosState state) async {
    if (state is PhotosStateShowGallery) {
      final photos = await ImagePicker().pickMultiImage();
      final pathList = photos.map((e) => e.path).toList();

      context.read<AddOrEditMomentBloc>().add(AddOrEditMomentEventAddPhoto(photos: pathList));
    }
  }

  Widget _buildHistoryList(AddOrEditMomentState state) {
    return SizedBox(
      height: 55,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.moment.downloadUrlList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return GestureDetector(
            onLongPress: () {
              CustomDeleteDialog.show(
                context,
                text: 'Deseja deletar essa foto?',
                onTapPositive: () {
                  final photo = state.moment.downloadUrlList[index];
                  context
                      .read<AddOrEditMomentBloc>()
                      .add(AddOrEditMomentEventDeletePhoto(photo: photo));
                  Navigator.pop(context);
                },
              );
            },
            onTap: () {
              Navigator.pushNamed(context, AppRoute.story.tag, arguments: {
                'list': state.moment.downloadUrlList,
                'index': index,
              });
            },
            child: _ColoredContainer(
              child: !state.moment.downloadUrlList[index].isHttpUrl
                  ? Image.file(
                      File(state.moment.downloadUrlList[index]),
                      fit: BoxFit.fitWidth,
                    )
                  : Image.network(
                      state.moment.downloadUrlList[index],
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
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _AddPhotoIcon extends StatelessWidget {
  const _AddPhotoIcon({
    Key? key,
  }) : super(key: key);

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
  const _ColoredContainer({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      decoration: AppThemes.coloredBorder,
      height: 55,
      width: 55,
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
