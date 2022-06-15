import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_date_bloc.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_date_event.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_bloc.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_event.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/add_or_edit_moment_state.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/photos_bloc.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/photos_event.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/select_type_bloc.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/bloc/select_type_event.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/widget/history_container_loading.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/widget/stories_container.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/widget/moment_form_section_loading.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/widget/select_type_toggle.dart';
import 'package:nossos_momentos/modules/add_moment/presenter/widget/tile_and_description_section.dart';
import 'package:nossos_momentos/modules/core/utils/date_util.dart';

class AddOrEditMomentPage extends StatefulWidget {
  const AddOrEditMomentPage({Key? key}) : super(key: key);

  @override
  State<AddOrEditMomentPage> createState() => _AddOrEditMomentPageState();
}

class _AddOrEditMomentPageState extends State<AddOrEditMomentPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              CupertinoIcons.arrow_left,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            BlocBuilder<AddOrEditMomentBloc, AddOrEditMomentState>(
              builder: (context, state) {
                return IconButton(
                  onPressed: () => state is AddOrEditMomentStateAllFilled
                      ? _createEvent()
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
          buildWhen: (previous, current) {
            return current is! AddOrEditMomentStateAllFilled;
          },
          builder: (context, state) {
            return _buildPage(state);
          },
        ),
      ),
    );
  }

  Widget _buildPage(AddOrEditMomentState state) {
    if (state is AddOrEditMomentStateLoading) {
      return _buildLoadingState();
    }

    if (state is AddOrEditMomentStateEmpty) {
      return _buildEmptyPage(state);
    }

    if (state is AddOrEditMomentStateLoaded) {
      return _buildFilledPage(state);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildEmptyPage(AddOrEditMomentState state) {
    BlocProvider.of<PhotosBloc>(context).add(PhotosEventInit());

    BlocProvider.of<SelectTypeBloc>(context)
        .add(const SelectTypeEventSelectType(index: 0));
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: const [
            SelectTypeToggle(),
            Divider(),
            PhotosContainer(),
            MomentFormSection(),
          ],
        ),
      ),
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

  Widget _buildFilledPage(AddOrEditMomentStateLoaded state) {
    BlocProvider.of<SelectTypeBloc>(context)
        .add(SelectTypeEventSelectType(index: state.moment.type.index));

    BlocProvider.of<PhotosBloc>(context).add(PhotosEventAddPhotos(
      photos: state.moment.downloadUrlList,
      needClearList: true,
    ));

    BlocProvider.of<AddDateBloc>(context).add(
      AddDateEventAddDateToLabel(
          dateLabel: DateUtil.getFormattedDate(state.moment.dateTime)),
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SelectTypeToggle(),
            const Divider(),
            const PhotosContainer(),
            MomentFormSection(
              title: state.moment.title,
              bodyText: state.moment.body,
            ),
          ],
        ),
      ),
    );
  }

  void _createEvent() {
    BlocProvider.of<AddOrEditMomentBloc>(context)
        .add(const AddOrEditMomentEventCreateOrUpdateMoment());
  }
}
