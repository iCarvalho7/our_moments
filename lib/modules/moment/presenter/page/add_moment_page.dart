import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/add_or_edit_moment_bloc.dart';
import '../widget/history_container_loading.dart';
import '../widget/photos_container.dart';
import '../widget/moment_form_section_loading.dart';
import '../widget/select_type_toggle.dart';
import '../widget/tile_and_description_section.dart';
import '../../../core/utils/date_util.dart';

class AddOrEditMomentPage extends StatelessWidget {
  const AddOrEditMomentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              CupertinoIcons.arrow_left,
              color: Colors.black,
            ),
          ),
          actions: [
            BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
              builder: (context, state) {
                return IconButton(
                  onPressed: () => state is AddOrEditMomentStateAllFilled
                      ? _createEvent(context)
                      : null,
                  icon: Icon(
                    Icons.done,
                    color: state is AddOrEditMomentStateAllFilled
                        ? Colors.green
                        : Colors.grey,
                  ),
                );
              },
            )
          ],
        ),
        body: BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
          buildWhen: (_, current) => current is! AddOrEditMomentStateAllFilled,
          builder: (context, state) {
            return _buildPage(state, context);
          },
        ),
      ),
    );
  }

  Widget _buildPage(AddOrEditMomentState state, BuildContext context) {
    if (state is AddOrEditMomentStateLoading) {
      return _buildLoadingState();
    }

    if (state is AddOrEditMomentStateEmpty) {
      return _buildEmptyPage(state, context);
    }

    if (state is AddOrEditMomentStateLoaded) {
      return _buildFilledPage(state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyPage(AddOrEditMomentState state, BuildContext context) {
    return Column(
      children: const [
        SelectTypeToggle(),
        Divider(),
        PhotosContainer(),
        MomentFormSection(),
      ],
    );
  }

  Widget _buildFilledPage(AddOrEditMomentStateLoaded state) {
    return Column(
      children: [
        SelectTypeToggle(index: state.moment.type.index),
        const Divider(),
        PhotosContainer(photosUrlList: state.moment.downloadUrlList),
        MomentFormSection(
          title: state.moment.title,
          bodyText: state.moment.body,
          date: DateUtil.getFormattedDate(state.moment.dateTime),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          HistoryContainerLoading(),
          MomentFormSectionLoading(),
        ],
      ),
    );
  }

  void _createEvent(BuildContext context) {
    BlocProvider.of<AddOrEditMomentBloc>(context)
        .add(const AddOrEditMomentEventCreateOrUpdateMoment());
  }
}
